import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';
import '../models/user_model.dart';

abstract class AuthDataSource {
  Stream<UserModel?> watchAuthState();

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser();

  Future<UserModel> updateProfile({
    required String displayName,
    String? bio,
  });

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  });
}

class AuthDataSourceImpl implements AuthDataSource {
  AuthDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required NetworkInfo networkInfo,
  })  : _auth = firebaseAuth,
        _firestore = firestore,
        _networkInfo = networkInfo;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final NetworkInfo _networkInfo;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Stream<UserModel?> watchAuthState() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        return await _fetchUser(user.uid);
      } catch (_) {
        return UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
        );
      }
    });
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await _networkInfo.ensureConnected();
    try {
      final credential = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(const Duration(seconds: 15));

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Login failed. Please try again.');
      }
      return _fetchUser(user.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthCode(e.code));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const NetworkException('Request timed out or network unavailable');
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await _networkInfo.ensureConnected();
    User? createdUser;
    try {
      final credential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(const Duration(seconds: 15));

      createdUser = credential.user;
      if (createdUser == null) {
        throw const AuthException('Registration failed. Please try again.');
      }

      final trimmedName = displayName.trim();
      await createdUser.updateDisplayName(trimmedName);

      final model = UserModel(
        uid: createdUser.uid,
        email: createdUser.email ?? email.trim(),
        displayName: trimmedName,
        createdAt: DateTime.now(),
      );

      // Guideline: store user details in Firestore `users` on registration.
      await _users.doc(createdUser.uid).set({
        'uid': model.uid,
        'email': model.email,
        'displayName': model.displayName,
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 15));

      return model;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthCode(e.code));
    } on AuthException {
      rethrow;
    } catch (_) {
      // Roll back Auth user if Firestore write failed after account creation.
      if (createdUser != null) {
        try {
          await createdUser.delete();
        } catch (_) {}
      }
      throw const ServerException(
        'Failed to save user profile. Please try again.',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut().timeout(const Duration(seconds: 10));
    } catch (_) {
      throw const AuthException('Failed to log out');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('No authenticated user');
    }
    return _fetchUser(user.uid);
  }

  @override
  Future<UserModel> updateProfile({
    required String displayName,
    String? bio,
  }) async {
    await _networkInfo.ensureConnected();
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('No authenticated user');
    }

    try {
      final trimmed = displayName.trim();
      if (trimmed.isEmpty) {
        throw const AuthException('Display name cannot be empty');
      }

      // Manage own profile only — always scoped to the signed-in uid.
      await user.updateDisplayName(trimmed);
      await _users.doc(user.uid).set(
        {
          'uid': user.uid,
          'email': user.email ?? '',
          'displayName': trimmed,
          if (bio != null) 'bio': bio.trim(),
        },
        SetOptions(merge: true),
      ).timeout(const Duration(seconds: 15));

      return _fetchUser(user.uid);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const ServerException('Failed to update profile');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _networkInfo.ensureConnected();
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || !normalized.contains('@')) {
      throw const AuthException('Enter a valid email');
    }
    try {
      await _auth
          .sendPasswordResetEmail(email: normalized)
          .timeout(const Duration(seconds: 15));
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthCode(e.code));
    } catch (_) {
      throw const NetworkException('Request timed out or network unavailable');
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    await _networkInfo.ensureConnected();
    try {
      await _auth
          .confirmPasswordReset(
            code: code.trim(),
            newPassword: newPassword,
          )
          .timeout(const Duration(seconds: 15));
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthCode(e.code));
    } catch (_) {
      throw const NetworkException('Request timed out or network unavailable');
    }
  }

  Future<UserModel> _fetchUser(String uid) async {
    try {
      final doc =
          await _users.doc(uid).get().timeout(const Duration(seconds: 15));
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }

      // Repair: Auth exists but Firestore profile is missing (e.g. old failed write).
      final authUser = _auth.currentUser;
      if (authUser == null || authUser.uid != uid) {
        throw const AuthException('No authenticated user');
      }

      final model = UserModel(
        uid: uid,
        email: authUser.email ?? '',
        displayName: authUser.displayName ?? '',
        createdAt: DateTime.now(),
      );
      await _users.doc(uid).set({
        'uid': model.uid,
        'email': model.email,
        'displayName': model.displayName,
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 15));
      return model;
    } on AuthException {
      rethrow;

    } catch (_) {
      throw const ServerException('Failed to load user profile');
    }
  }

  String _mapAuthCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found for this email';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password';
      case 'email-already-in-use':
        return 'An account already exists for this email';
      case 'weak-password':
        return 'Password is too weak (min 6 characters)';
      case 'expired-action-code':
        return 'This reset code has expired';
      case 'invalid-action-code':
        return 'Invalid reset code';
      case 'network-request-failed':
        return 'No internet connection';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
