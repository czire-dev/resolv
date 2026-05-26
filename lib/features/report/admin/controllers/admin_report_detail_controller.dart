// report/admin/controllers/admin_report_detail_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/core/utils/result.dart';
import 'package:resolv/models/report_model.dart';
import '../../providers/user_report_providers.dart';

class AdminReportDetailController extends ChangeNotifier {
  final Ref _ref;
  final ReportModel report;

  AdminReportDetailController(this._ref, this.report) {
    // Pre-fill with current values
    _selectedStatus = report.status;
    _noteController.text = report.adminNote ?? '';
  }

  late ReportStatus _selectedStatus;
  final _noteController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  ReportStatus get selectedStatus => _selectedStatus;
  bool get isSubmitting => _isSubmitting;
  TextEditingController get noteController => _noteController;
  String? get errorMessage => _errorMessage;

  bool get hasChanges =>
      _selectedStatus != report.status || _noteController.text.trim() != (report.adminNote ?? '');

  void selectStatus(ReportStatus status) {
    _selectedStatus = status;
    _errorMessage = null;
    notifyListeners();
  }

  Future<Result<void>> submitUpdate() async {
    if (!hasChanges) return Result.success(null);

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _ref
        .read(reportRepositoryProvider)
        .updateReportStatus(
          reportId: report.id,
          newStatus: _selectedStatus,
          adminNote: _noteController.text.trim(),
        );

    if (result.isFailure) {
      _errorMessage = result.error!.message;
    }

    _isSubmitting = false;
    notifyListeners();

    return result;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}

// autoDispose: cleans up when detail screen is popped
final adminReportDetailControllerProvider = ChangeNotifierProvider.autoDispose
    .family<AdminReportDetailController, ReportModel>(
      (ref, report) => AdminReportDetailController(ref, report),
    );
