import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/features/report/controllers/ai_controller.dart';
import 'package:resolv/features/report/controllers/ai_notifier.dart';
import 'package:resolv/features/report/repositories/ai_repository.dart';
import 'package:resolv/models/incident_model.dart';
import 'package:resolv/models/report_model.dart';
import 'package:resolv/services/ai_service.dart';
import 'package:resolv/services/incident_service.dart';
import 'package:resolv/services/report_service.dart';

// ─── SERVICE PROVIDERS ───────────────────────────────────────────────────────

/// Provider for [AiService].
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

/// Provider for [ReportService].
final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService();
});

/// Provider for [IncidentService].
final incidentServiceProvider = Provider<IncidentService>((ref) {
  return IncidentService();
});

// ─── REPOSITORY PROVIDERS ────────────────────────────────────────────────────

/// Provider for [AiRepository].
final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return AiRepository(aiService);
});

// ─── CONTROLLER PROVIDERS ────────────────────────────────────────────────────

/// Provider for [AiController].
final aiControllerProvider = Provider<AiController>((ref) {
  final aiRepository = ref.watch(aiRepositoryProvider);
  final reportService = ref.watch(reportServiceProvider);
  final incidentService = ref.watch(incidentServiceProvider);

  return AiController(
    aiRepository: aiRepository,
    reportService: reportService,
    incidentService: incidentService,
  );
});

// ─── NOTIFIER PROVIDERS ──────────────────────────────────────────────────────

/// Provider for [AiNotifier].
/// Manages the state of AI analysis operations.
final aiNotifierProvider = AsyncNotifierProvider<AiNotifier, AiAnalysisState?>(() => AiNotifier());

// ─── DATA STREAM PROVIDERS ───────────────────────────────────────────────────

/// Stream provider for all incidents (real-time updates).
/// Filters by category and status.
final incidentsStreamProvider =
    StreamProvider.family<List<IncidentModel>, ({String? category, String? status})>((ref, params) {
      final firestore = FirebaseFirestore.instance;
      final collectionRef = firestore.collection('incidents');

      Query query = collectionRef;

      if (params.category != null) {
        query = query.where('category', isEqualTo: params.category);
      }

      if (params.status != null) {
        query = query.where('status', isEqualTo: params.status);
      }

      return query.snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => IncidentModel.fromDoc(doc)).toList(),
      );
    });

/// Stream provider for all reports (real-time updates).
final reportsStreamProvider = StreamProvider<List<ReportModel>>((ref) {
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('reports')
      .orderBy('submittedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => ReportModel.fromDoc(doc)).toList());
});

/// Stream provider for recent unresolved reports shown on the admin dashboard.
final recentUnresolvedReportsStreamProvider = StreamProvider<List<ReportModel>>((ref) {
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('reports')
      .orderBy('submittedAt', descending: true)
      .limit(25)
      .snapshots()
      .map((snapshot) {
        final reports = snapshot.docs.map((doc) => ReportModel.fromDoc(doc)).toList();
        return reports.where((report) => report.status != ReportStatus.resolved).take(10).toList();
      });
});

/// Stream provider for reports by user (real-time updates).
final userReportsStreamProvider = StreamProvider.family<List<ReportModel>, String>((ref, userId) {
  final firestore = FirebaseFirestore.instance;
  return firestore.collection('reports').where('submittedByUid', isEqualTo: userId).snapshots().map(
    (snapshot) {
      final reports = snapshot.docs.map((doc) => ReportModel.fromDoc(doc)).toList();
      reports.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return reports;
    },
  );
});

/// Stream provider for all application users.
final usersStreamProvider = StreamProvider<List<String>>((ref) {
  final firestore = FirebaseFirestore.instance;
  return firestore.collection('users').snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => doc.id).toList(),
      );
});

/// Stream provider for duplicate reports (reports where isDuplicate == true).
final duplicateReportsStreamProvider = StreamProvider<List<ReportModel>>((ref) {
  final firestore = FirebaseFirestore.instance;
  return firestore.collection('reports').where('isDuplicate', isEqualTo: true).snapshots().map((
    snapshot,
  ) {
    final reports = snapshot.docs.map((doc) => ReportModel.fromDoc(doc)).toList();
    reports.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return reports;
  });
});

/// Stream provider for open incidents (real-time updates).
final openIncidentsStreamProvider = StreamProvider<List<IncidentModel>>((ref) {
  final firestore = FirebaseFirestore.instance;
  return firestore.collection('incidents').where('status', isEqualTo: 'active').snapshots().map((
    snapshot,
  ) {
    final incidents = snapshot.docs.map((doc) => IncidentModel.fromDoc(doc)).toList();
    incidents.sort((a, b) => b.lastReportAt.compareTo(a.lastReportAt));
    return incidents;
  });
});
