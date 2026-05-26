import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<Result<void>> updateReportStatus({
    required String reportId,
    required ReportStatus newStatus,
    String? adminNote,
  }) async {
    final result = await _service.updateReportStatus(reportId, newStatus, adminNote);
    return result;
  }

  /// Add admin note to a report.
  Future<Result<void>> addAdminNote({required String reportId, required String note}) async {
    final result = await _service.addAdminNote(reportId, note);
    return result;
  }

  /// Delete a report.
  Future<Result<void>> deleteReport(String reportId) async {
    final result = await _service.deleteReport(reportId);
    return result;
  }

  /// Get the Firestore document for a report.
  Future<DocumentSnapshot?> getReportDocument(String reportId) {
    return _service.getReportDocument(reportId);
  }

  /// Fetch the next page of admin reports.
  Future<Result<List<ReportModel>>> fetchMoreReports({
    required DocumentSnapshot lastDocument,
    int limit = 15,
  }) {
    return _service.fetchMoreReports(lastDocument: lastDocument, limit: limit);
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
