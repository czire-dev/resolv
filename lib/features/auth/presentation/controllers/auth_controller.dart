import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resolv/features/auth/repositories/auth_repository.dart';
import 'package:resolv/models/user_model.dart';

final authControllerProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<UserModel?> {
  late final AuthRepository _repository;
  @override
  FutureOr<UserModel?> build() async {
    _repository = ref.watch(authRepositoryProvider);
    final result = await _repository.getCurrentUser();
    if (result.isSuccess) {
      return result.data;
    }
    return null; // Not authenticated or error occurred
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _repository.signInWithEmailAndPassword(email, password);
    if (result.isSuccess) {
      state = AsyncValue.data(result.data);
    } else {
      state = AsyncValue.error(result.error!.message, StackTrace.current);
    }
  }

  Future<void> register(String displayName, String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _repository.registerWithEmailAndPassword(displayName, email, password);
    if (result.isSuccess) {
      state = AsyncValue.data(result.data);
    } else {
      state = AsyncValue.error(result.error!.message, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final result = await _repository.signOut();
    if (result.isSuccess) {
      state = const AsyncValue.data(null);
    } else {
      state = AsyncValue.error(result.error!.message, StackTrace.current);
    }
  }

  Future<void> refreshUser() async {
    state = const AsyncValue.loading();
    final result = await _repository.getCurrentUser();
    if (result.isSuccess) {
      state = AsyncValue.data(result.data);
    } else {
      state = AsyncValue.error(result.error!.message, StackTrace.current);
    }
  }
}
