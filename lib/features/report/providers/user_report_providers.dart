import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resolv/features/report/repositories/report_repository.dart';
import 'package:resolv/features/report/user/controllers/report_controller.dart';
import 'package:resolv/models/report_model.dart';
import 'package:resolv/services/report_service.dart';

/// Provider for [ReportService].
final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService();
});

/// Provider for [ReportRepository].
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final service = ref.watch(reportServiceProvider);
  return ReportRepository(service);
});

/// Provider for the authenticated user's reports.
final reportControllerProvider =
    AsyncNotifierProvider<ReportNotifier, List<ReportModel>?>(ReportNotifier.new);
