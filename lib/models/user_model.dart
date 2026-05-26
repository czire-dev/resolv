import 'package:firebase_auth/firebase_auth.dart';
import 'package:resolv/core/enums/user_role.dart';

class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String? profilePictureUrl;
  final UserRole role;

  UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.profilePictureUrl,
    this.role = UserRole.user,
  });

  factory UserModel.fromFirebase(User user) {
    return UserModel(
      id: user.uid,
      displayName: user.displayName ?? 'User',
      email: user.email ?? '',
      profilePictureUrl: user.photoURL,
    );
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      displayName: data['displayName'] ?? 'User',
      email: data['email'] ?? '',
      profilePictureUrl: data['profilePictureUrl'],
      role: (data['role'] as String? ?? 'user') == 'admin' ? UserRole.admin : UserRole.user,
    );
  }
}
