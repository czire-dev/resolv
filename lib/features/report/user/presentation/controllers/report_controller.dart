import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/features/auth/presentation/controllers/auth_controller.dart';
import 'package:resolv/features/report/providers/user_report_providers.dart' as report_providers;
import 'package:resolv/features/report/repositories/report_repository.dart';
import 'package:resolv/models/report_model.dart';

final reportControllerProvider = ChangeNotifierProvider<ReportController>((ref) {
  return ReportController();
});

class ReportController extends ChangeNotifier {
  // ── Form ──────────────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();

  // ── UI State ──────────────────────────────────────────────────────────────
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get canSubmit =>
      !_isSubmitting &&
      titleController.text.trim().isNotEmpty &&
      descriptionController.text.trim().isNotEmpty;
  ReportCategory _selectedCategory = ReportCategory.other;
  ReportCategory get selectedCategory => _selectedCategory;
  set selectedCategory(ReportCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // ── Inline validation flags ───────────────────────────────────────────────
  bool _titleTouched = false;
  bool _descriptionTouched = false;
  bool _addressTouched = false;
  String? get titleError =>
      _titleTouched ? (titleController.text.trim().isEmpty ? 'Title is required' : null) : null;
  String? get descriptionError => _descriptionTouched
      ? (descriptionController.text.trim().isEmpty ? 'Description is required' : null)
      : null;
  String? get addressError => _addressTouched
      ? (addressController.text.trim().isEmpty ? 'Address is required' : null)
      : null;

  // ── Listeners ─────────────────────────────────────────────────────────────
  void onTitleChanged(String _) {
    _titleTouched = true;
    _clearErrorIfPresent();
    notifyListeners();
  }

  void onDescriptionChanged(String _) {
    _descriptionTouched = true;
    _clearErrorIfPresent();
    notifyListeners();
  }

  void onAddressChanged(String _) {
    _addressTouched = true;
    _clearErrorIfPresent();
    notifyListeners();
  }

  void onTitleUnfocus() {
    _titleTouched = true;
    notifyListeners();
  }

  void onDescriptionUnfocus() {
    _descriptionTouched = true;
    notifyListeners();
  }

  void onAddressUnfocus() {
    _addressTouched = true;
    notifyListeners();
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> onSubmit(WidgetRef ref, BuildContext context) async {
    _titleTouched = true;
    _descriptionTouched = true;
    _addressTouched = true;

    if (!formKey.currentState!.validate()) {
      return;
    }

    _setSubmitting(true);

    try {
      final authState = ref.read(authControllerProvider);
      final user = authState.whenData((user) => user).value;

      if (user == null) {
        setError('User not authenticated');
        _setSubmitting(false);
        return;
      }

      final result = await ref
          .read(report_providers.reportRepositoryProvider)
          .submitReport(
            title: titleController.text.trim(),
            description: descriptionController.text.trim(),
            category: selectedCategory,
            submittedByName: user.displayName,
            submittedByUid: user.id,
            address: addressController.text.trim(),
          );

      if (result.isSuccess) {
        resetForm();
        ref.invalidate(report_providers.reportControllerProvider);
      } else {
        setError(result.error?.message ?? 'Failed to submit report. Please try again.');
      }
    } catch (e) {
      setError('An unexpected error occurred');
    } finally {
      _setSubmitting(false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearErrorIfPresent() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    addressController.clear();
    _titleTouched = false;
    _descriptionTouched = false;
    _addressTouched = false;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    super.dispose();
  }
}

class ReportNotifier extends AsyncNotifier<List<ReportModel>?> {
  ReportRepository get _repository => ref.read(report_providers.reportRepositoryProvider);

  @override
  FutureOr<List<ReportModel>?> build() {
    final userId = ref.watch(authControllerProvider).whenData((user) => user?.id).value;
    if (userId != null) {
      return _repository.fetchUserReports(userId: userId).then((result) {
        if (result.isSuccess) {
          print('Fetched ${result.data?.length} reports for user $userId');
          return result.data;
        } else {
          throw Exception(result.error?.message ?? 'Failed to fetch reports');
        }
      });
    }

    return [];
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final userId = ref.watch(authControllerProvider).whenData((user) => user?.id).value;
    if (userId != null) {
      final result = await _repository.fetchUserReports(userId: userId);
      if (result.isSuccess) {
        state = AsyncValue.data(result.data);
      } else {
        state = AsyncValue.error(
          result.error?.message ?? 'Failed to fetch reports',
          StackTrace.current,
        );
      }
    } else {
      state = const AsyncValue.data([]);
    }
  }
}
