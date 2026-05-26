import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/core/utils/result.dart';
import 'package:resolv/models/report_model.dart';

/// Service layer for interacting with Firestore reports collection.
/// Handles all CRUD operations and queries for reports.
class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _reportsCollection = 'reports';

  /// Submit a new report to Firestore.
  /// TODO: Integrate AI analysis for categorization and prioritization in future iterations.
  Future<Result<String>> submitReport({
    required String title,
    required String description,
    required ReportCategory category,
    required String submittedByName,
    required String submittedByUid,
    String? address,
    String? imageUrl,
  }) async {
    try {
      final docRef = await _firestore.collection(_reportsCollection).add({
        'title': title,
        'description': description,
        'category': category.value,
        'status': ReportStatus.pending.value,
        'submittedAt': FieldValue.serverTimestamp(),
        'submittedByName': submittedByName,
        'submittedByUid': submittedByUid,
        'address': address,
        'imageUrl': imageUrl,
        'adminNote': null,
        'updatedAt': null,
      });

      return Result.success(docRef.id);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(e.message ?? 'Failed to submit report', code: e.code),
      );
    } catch (e) {
      print('Error in submitReport: $e');
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  /// Fetch a single report by ID.
  Future<Result<ReportModel>> fetchReportById(String reportId) async {
    try {
      final doc = await _firestore
          .collection(_reportsCollection)
          .doc(reportId)
          .get();

      if (!doc.exists) {
        return Result.failure(Failure('Report not found', code: 'not-found'));
      }

      final report = ReportModel.fromDoc(doc);
      return Result.success(report);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(e.message ?? 'Failed to fetch report', code: e.code),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  /// Fetch all reports submitted by a specific user.
  Future<Result<List<ReportModel>>> fetchUserReports({
    required String userId,
    ReportStatus? status,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_reportsCollection)
          .where('submittedByUid', isEqualTo: userId)
          .get();

      final reports =
          snapshot.docs
              .map((doc) => ReportModel.fromDoc(doc))
              .where((report) => status == null || report.status == status)
              .toList()
            ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

      return Result.success(reports);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(e.message ?? 'Failed to fetch reports', code: e.code),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  /// Fetch all reports (admin endpoint).
  Future<Result<List<ReportModel>>> fetchAllReports({
    ReportStatus? status,
    ReportCategory? category,
  }) async {
    try {
      Query query = _firestore
          .collection(_reportsCollection)
          .orderBy('submittedAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category.value);
      }

      final snapshot = await query.get();
      final reports = snapshot.docs
          .map((doc) => ReportModel.fromDoc(doc))
          .toList();

      return Result.success(reports);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(e.message ?? 'Failed to fetch reports', code: e.code),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  /// Update report status (typically by admin).
  Future<Result<void>> updateReportStatus(
    String reportId,
    ReportStatus newStatus,
    String? adminNote,
  ) async {
    try {
      await _firestore.collection(_reportsCollection).doc(reportId).update({
        'status': newStatus.value,
        'adminNote': adminNote,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(e.message ?? 'Failed to update report status', code: e.code),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  /// Update report with arbitrary data (used by AI workflow).
  Future<Result<void>> updateReport(
    String reportId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(_reportsCollection)
          .doc(reportId)
          .update(data);
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(e.message ?? 'Failed to update report', code: e.code),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  /// Add admin note to a report.
  Future<Result<void>> addAdminNote(String reportId, String note) async {
    try {
      await _firestore.collection(_reportsCollection).doc(reportId).update({
        'adminNote': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(e.message ?? 'Failed to add admin note', code: e.code),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  /// Delete a report.
  Future<Result<void>> deleteReport(String reportId) async {
    try {
      await _firestore.collection(_reportsCollection).doc(reportId).delete();
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(e.message ?? 'Failed to delete report', code: e.code),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  /// Stream of reports for a specific user (real-time updates).
  Stream<Result<List<ReportModel>>> streamUserReports({
    required String userId,
    ReportStatus? status,
  }) {
    try {
      Query query = _firestore
          .collection(_reportsCollection)
          .where('submittedByUid', isEqualTo: userId);

      return query
          .snapshots()
          .map((snapshot) {
            final reports = snapshot.docs
                .map((doc) => ReportModel.fromDoc(doc))
                .where((report) => status == null || report.status == status)
                .toList();
            reports.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
            return Result.success(reports);
          })
          .handleError((error) {
            if (error is FirebaseException) {
              return Result.failure(
                Failure(
                  error.message ?? 'Failed to stream reports',
                  code: error.code,
                ),
              );
            }
            return Result.failure(Failure('An unexpected error occurred'));
          });
    } catch (e) {
      return Stream.value(
        Result.failure(Failure('An unexpected error occurred')),
      );
    }
  }

  /// one-time fetch after a cursor document
  Future<Result<List<ReportModel>>> fetchMoreReports({
    required DocumentSnapshot lastDocument,
    int limit = 15,
  }) async {
    try {
      final snap = await _firestore
          .collection(_reportsCollection)
          .orderBy('submittedAt', descending: true)
          .startAfterDocument(lastDocument)
          .limit(limit)
          .get();

      final reports = snap.docs.map(ReportModel.fromDoc).toList();
      return Result.success(reports);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(e.message ?? 'Failed to load more reports', code: e.code),
      );
    }
  }

  /// Get the raw DocumentSnapshot for pagination cursor
  Future<DocumentSnapshot?> getReportDocument(String reportId) async {
    try {
      return await _firestore.collection('reports').doc(reportId).get();
    } catch (_) {
      return null;
    }
  }

  /// Stream of all reports (admin endpoint).
  Stream<Result<List<ReportModel>>> streamAllReports({
    ReportStatus? status,
    ReportCategory? category,
    int limit = 15,
  }) {
    try {
      Query query = _firestore
          .collection(_reportsCollection)
          .orderBy('submittedAt', descending: true)
          .limit(limit);

      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category.value);
      }

      return query
          .snapshots()
          .map((snapshot) {
            final reports = snapshot.docs
                .map((doc) => ReportModel.fromDoc(doc))
                .toList();
            return Result.success(reports);
          })
          .handleError((error) {
            if (error is FirebaseException) {
              return Result.failure(
                Failure(
                  error.message ?? 'Failed to stream reports',
                  code: error.code,
                ),
              );
            }
            return Result.failure(Failure('An unexpected error occurred'));
          });
    } catch (e) {
      return Stream.value(
        Result.failure(Failure('An unexpected error occurred')),
      );
    }
  }
}
