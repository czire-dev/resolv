import 'package:firebase_auth/firebase_auth.dart';
import 'package:resolv/core/utils/result.dart';
import 'package:resolv/models/user_model.dart';
import 'package:resolv/services/user_service.dart';

class AuthService {
  final FirebaseAuth _service = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Future<Result<User>> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _service.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Result.success(credential.user!);
    } on FirebaseAuthException catch (e) {
      return Result.failure(Failure(e.message ?? 'Authentication failed', code: e.code));
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  Future<Result<User>> registerWithEmailAndPassword(
    String displayName,
    String email,
    String password,
  ) async {
    try {
      final credential = await _service.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      credential.user?.updateDisplayName(displayName);

      // Create user in Firestore
      await _userService.createUser(UserModel.fromFirebase(credential.user!));

      return Result.success(credential.user!);
    } on FirebaseAuthException catch (e) {
      return Result.failure(Failure(e.message ?? 'Registration failed', code: e.code));
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  Future<Result<void>> signOut() async {
    try {
      await _service.signOut();
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(Failure(e.message ?? 'Sign out failed', code: e.code));
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _service.sendPasswordResetEmail(email: email);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        Failure(e.message ?? 'Failed to send password reset email', code: e.code),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  Future<Result<void>> updatePassword(String newPassword) async {
    try {
      final user = _service.currentUser;
      if (user == null) {
        return Result.failure(Failure('No authenticated user found'));
      }
      await user.updatePassword(newPassword);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(Failure(e.message ?? 'Failed to update password', code: e.code));
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  Future<Result<User>> getCurrentUser() async {
    try {
      final user = _service.currentUser;
      if (user != null) {
        return Result.success(user);
      } else {
        return Result.failure(Failure('No authenticated user found'));
      }
    } on FirebaseAuthException catch (e) {
      return Result.failure(Failure(e.message ?? 'Failed to get current user', code: e.code));
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }
}
