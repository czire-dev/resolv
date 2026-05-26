import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resolv/core/utils/result.dart';
import 'package:resolv/services/auth_service.dart';
import 'package:resolv/models/user_model.dart';
import 'package:resolv/features/auth/presentation/utils/auth_validators.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final service = AuthService();
  return AuthRepository(service);
});

class AuthRepository {
  final AuthService _service;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _usersCollection = 'users';

  AuthRepository(this._service);

  Future<UserModel> _hydrateUser(UserModel baseUser) async {
    final doc = await _firestore.collection(_usersCollection).doc(baseUser.id).get();

    if (!doc.exists || doc.data() == null) {
      return baseUser;
    }

    return UserModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<Result<UserModel>> signInWithEmailAndPassword(String email, String password) async {
    final result = await _service.signInWithEmailAndPassword(email, password);
    if (result.isSuccess) {
      return Result.success(await _hydrateUser(UserModel.fromFirebase(result.data!)));
    } else {
      final msg = AuthValidators.mapFirebaseError(result.error!.code ?? "");
      return Result.failure(Failure(msg, code: result.error?.code));
    }
  }

  Future<Result<UserModel>> registerWithEmailAndPassword(
    String displayName,
    String email,
    String password,
  ) async {
    final result = await _service.registerWithEmailAndPassword(displayName, email, password);
    if (result.isSuccess) {
      return Result.success(await _hydrateUser(UserModel.fromFirebase(result.data!)));
    } else {
      final msg = AuthValidators.mapFirebaseError(result.error!.code ?? "");
      return Result.failure(Failure(msg, code: result.error?.code));
    }
  }

  Future<Result<void>> sendPasswordResetEmail(String email) async {
    final result = await _service.sendPasswordResetEmail(email);
    print('AuthRepository.sendPasswordResetEmail result: $result');
    if (result.isSuccess) {
      return Result.success(null);
    } else {
      print('Error code: ${result.error?.code}, message: ${result.error?.message}');
      final msg = AuthValidators.mapFirebaseError(result.error!.code ?? "");
      return Result.failure(Failure(msg, code: result.error?.code));
    }
  }

  Future<Result<void>> signOut() async {
    return await _service.signOut();
  }

  Future<Result<UserModel>> getCurrentUser() async {
    final result = await _service.getCurrentUser();
    if (result.isSuccess) {
      return Result.success(await _hydrateUser(UserModel.fromFirebase(result.data!)));
    } else {
      final msg = AuthValidators.mapFirebaseError(result.error!.code ?? "");
      return Result.failure(Failure(msg, code: result.error?.code));
    }
  }
}
