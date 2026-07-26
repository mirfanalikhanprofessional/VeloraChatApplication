import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.bio,
    this.createdAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final String? bio;
  final DateTime? createdAt;

  /// Two-letter initials from display name, or email if name is empty.
  String get initial {
    final name = displayName.trim();
    if (name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      final word = parts.first;
      if (word.length >= 2) return word.substring(0, 2).toUpperCase();
      return word[0].toUpperCase();
    }

    final local = email.trim().split('@').first;
    if (local.length >= 2) return local.substring(0, 2).toUpperCase();
    if (local.isNotEmpty) return local[0].toUpperCase();
    return '?';
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? bio,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      bio: json['bio'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName, bio, createdAt];
}
