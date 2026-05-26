import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resolv/core/enums/user_role.dart';
import 'package:resolv/core/utils/result.dart';
import 'package:resolv/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  Future<Result<UserModel>> fetchUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();

      if (!doc.exists) {
        return Result.failure(Failure('User not found', code: 'not-found'));
      }

      final user = UserModel.fromFirestore(doc.data()!, doc.id);
      return Result.success(user);
    } on FirebaseException catch (e) {
      return Result.failure(Failure(e.message ?? 'Failed to fetch user', code: e.code));
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  Future<Result<void>> createUser(UserModel user) async {
    try {
      await _firestore.collection(_usersCollection).doc(user.id).set({
        'displayName': user.displayName,
        'email': user.email,
        'profilePictureUrl': user.profilePictureUrl,
        'role': user.role == UserRole.admin ? 'admin' : 'user',
      });
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(Failure(e.message ?? 'Failed to create user', code: e.code));
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }
}
