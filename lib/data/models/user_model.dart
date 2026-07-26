import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.bio,
    super.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return UserModel.fromMap(data, fallbackUid: doc.id);
  }

  factory UserModel.fromMap(
    Map<String, dynamic> data, {
    String? fallbackUid,
  }) {
    final createdAt = data['createdAt'];
    return UserModel(
      uid: (data['uid'] as String?) ?? fallbackUid ?? '',
      email: (data['email'] as String?) ?? '',
      displayName: (data['displayName'] as String?) ?? '',
      bio: data['bio'] as String?,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      if (bio != null) 'bio': bio,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  factory UserModel.fromEntity(AppUser user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      bio: user.bio,
      createdAt: user.createdAt,
    );
  }
}
