import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/core/utils/result.dart';
import 'package:resolv/models/report_model.dart';
import 'package:resolv/services/report_service.dart';

/// Repository layer for reports feature.
/// Handles all business logic and data transformation for reports.
class ReportRepository {
  final ReportService _service;

  ReportRepository(this._service);

  /// Submit a new report.
  Future<Result<String>> submitReport({
    required String title,
    required String description,
    required ReportCategory category,
    required String submittedByName,
    required String submittedByUid,
    String? address,
    String? imageUrl,
  }) async {
    final result = await _service.submitReport(
      title: title,
      description: description,
      category: category,
      submittedByName: submittedByName,
      submittedByUid: submittedByUid,
      address: address,
      imageUrl: imageUrl,
    );

    return result;
  }

  /// Fetch a single report by ID.
  Future<Result<ReportModel>> fetchReportById(String reportId) async {
    final result = await _service.fetchReportById(reportId);
    return result;
  }

  /// Fetch all reports submitted by a specific user.
  Future<Result<List<ReportModel>>> fetchUserReports({
    required String userId,
    ReportStatus? status,
  }) async {
    final result = await _service.fetchUserReports(userId: userId, status: status);
    return result;
  }

  /// Fetch all reports (admin endpoint).
  Future<Result<List<ReportModel>>> fetchAllReports({
    ReportStatus? status,
    ReportCategory? category,
  }) async {
    final result = await _service.fetchAllReports(status: status, category: category);
    return result;
  }

  /// Update report status.
  Future<Result<void>> updateReportStatus(String reportId, ReportStatus newStatus) async {
    final result = await _service.updateReportStatus(reportId, newStatus);
    return result;
  }

  /// Add admin note to a report.
  Future<Result<void>> addAdminNote(String reportId, String note) async {
    final result = await _service.addAdminNote(reportId, note);
    return result;
  }

  /// Delete a report.
  Future<Result<void>> deleteReport(String reportId) async {
    final result = await _service.deleteReport(reportId);
    return result;
  }

  /// Stream of reports for a specific user (real-time updates).
  Stream<Result<List<ReportModel>>> streamUserReports({
    required String userId,
    ReportStatus? status,
  }) {
    return _service.streamUserReports(userId: userId, status: status);
  }

  /// Stream of all reports (admin endpoint).
  Stream<Result<List<ReportModel>>> streamAllReports({
    ReportStatus? status,
    ReportCategory? category,
  }) {
    return _service.streamAllReports(status: status, category: category);
  }
}
