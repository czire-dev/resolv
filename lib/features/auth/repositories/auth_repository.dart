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

  AuthRepository(this._service);

  Future<Result<UserModel>> signInWithEmailAndPassword(String email, String password) async {
    final result = await _service.signInWithEmailAndPassword(email, password);
    if (result.isSuccess) {
      return Result.success(UserModel.fromFirebase(result.data!));
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
      return Result.success(UserModel.fromFirebase(result.data!));
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
      return Result.success(UserModel.fromFirebase(result.data!));
    } else {
      final msg = AuthValidators.mapFirebaseError(result.error!.code ?? "");
      return Result.failure(Failure(msg, code: result.error?.code));
    }
  }
}
