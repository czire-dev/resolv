import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resolv/core/utils/result.dart';
import 'package:resolv/models/incident_model.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/core/enums/incident_enums.dart';

ReportStatus mapIncidentToReportStatus(IncidentStatus incidentStatus) {
  switch (incidentStatus) {
    case IncidentStatus.active:
      return ReportStatus.pending;
    case IncidentStatus.monitoring:
      return ReportStatus.inProgress;
    case IncidentStatus.resolved:
      return ReportStatus.resolved;
  }
}

bool shouldPreserveReportStatus(ReportStatus currentStatus) {
  return currentStatus == ReportStatus.rejected;
}

class IncidentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _incidentsCollection = 'incidents';
  static const String _reportsCollection = 'reports';

  // create
  Future<Result<IncidentModel>> createIncident(
    Map<String, dynamic> incidentData,
  ) async {
    try {
      print('[Incident] Creating incident with keys: ${incidentData.keys.toList()}');
      final docRef = await _firestore
          .collection(_incidentsCollection)
          .add(incidentData);

      final doc = await docRef.get();

      final incident = IncidentModel.fromDoc(doc);
      return Result.success(incident);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(e.message ?? 'Failed to create incident', code: e.code),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  // read single
  Future<Result<IncidentModel>> getIncidentById(String incidentId) async {
    try {
      final doc = await _firestore
          .collection(_incidentsCollection)
          .doc(incidentId)
          .get();
      if (!doc.exists) {
        return Result.failure(Failure('Incident not found'));
      }
      return Result.success(IncidentModel.fromDoc(doc));
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(e.message ?? 'Failed to fetch incident', code: e.code),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  // read all
  Future<Result<List<IncidentModel>>> getAllIncidents() async {
    try {
      final snapshot = await _firestore
          .collection(_incidentsCollection)
          .orderBy('updatedAt', descending: true)
          .get();

      final incidents = snapshot.docs
          .map((doc) => IncidentModel.fromDoc(doc))
          .toList();
      return Result.success(incidents);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(e.message ?? 'Failed to fetch incidents', code: e.code),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  /// Update an incident's status and synchronize linked report statuses.
  /// This will update the incident document and batch-update all reports
  /// where `report.incidentId == incidentId`, mapping incident status
  /// to the corresponding report status. Rejected reports are preserved.
  Future<Result<void>> updateIncidentStatus({
    required String incidentId,
    required IncidentStatus newStatus,
  }) async {
    try {
      print('[IncidentSync] Updating incident $incidentId -> ${newStatus.name}');
      final mappedStatus = mapIncidentToReportStatus(newStatus);

      final incidentRef = _firestore.collection(_incidentsCollection).doc(incidentId);
      final incidentSnapshot = await incidentRef.get();
      if (!incidentSnapshot.exists) {
        return Result.failure(Failure('Incident not found'));
      }

      final reportsQuery = _firestore
          .collection(_reportsCollection)
          .where('incidentId', isEqualTo: incidentId);
      final reportsSnap = await reportsQuery.get();

      print('[IncidentSync] Found ${reportsSnap.docs.length} linked reports for $incidentId');

      final batch = _firestore.batch();
      batch.update(incidentRef, {
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      int updatedCount = 0;
      int skippedRejected = 0;

      for (final doc in reportsSnap.docs) {
        final data = doc.data();
        final currentStatusStr = (data['status'] as String?) ?? '';
        final currentStatus = ReportStatusX.fromString(currentStatusStr);

        if (shouldPreserveReportStatus(currentStatus)) {
          skippedRejected++;
          print('[ReportSync] Skipping rejected report ${doc.id}');
          continue;
        }

        if (currentStatus == mappedStatus) {
          print('[ReportSync] Report ${doc.id} already synced as ${mappedStatus.value}');
          continue;
        }

        batch.update(doc.reference, {
          'status': mappedStatus.value,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        updatedCount++;
        print('[ReportSync] Queued update for report ${doc.id} -> ${mappedStatus.value}');
      }

      await batch.commit();

      print(
        '[IncidentSync] Batch committed successfully for $incidentId -> ${newStatus.name}. reportsUpdated=$updatedCount, skippedRejected=$skippedRejected',
      );
      return Result.success(null);
    } on FirebaseException catch (e) {
      print('[IncidentSync] FirebaseException: ${e.message}');
      return Result.failure(
        Failure(e.message ?? 'Failed to update incident status', code: e.code),
      );
    } catch (e) {
      print('[IncidentSync] Exception: $e');
      return Result.failure(Failure('An unexpected error occurred during status sync'));
    }
  }

  // stream all incidents (real-time)
  Stream<Result<List<IncidentModel>>> streamAllIncidents() {
    try {
      return _firestore
          .collection(_incidentsCollection)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            final incidents = snapshot.docs
                .map((doc) => IncidentModel.fromDoc(doc))
                .toList();
            return Result.success(incidents);
          })
          .handleError((e) {
            if (e is FirebaseException) {
              return Result.failure(
                Failure(e.message ?? 'Stream failed', code: e.code),
              );
            }
            return Result.failure(Failure('An unexpected error occurred'));
          });
    } catch (e) {
      return Stream.value(
        Result.failure(Failure('Failed to initialize stream')),
      );
    }
  }

  // read filtered
  Future<Result<List<IncidentModel>>> getIncidentsFiltered({
    ReportCategory? category,
    IncidentPriority? priority,
  }) async {
    try {
      Query query = _firestore.collection(_incidentsCollection);

      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }
      if (priority != null) {
        query = query.where('priority', isEqualTo: priority.name);
      }

      final snapshot = await query.orderBy('updatedAt', descending: true).get();
      final incidents = snapshot.docs
          .map((doc) => IncidentModel.fromDoc(doc))
          .toList();
      return Result.success(incidents);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(e.message ?? 'Failed to fetch incidents', code: e.code),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  // update
  Future<Result<void>> updateIncident(
    String incidentId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      print('[Incident] Updating $incidentId with keys: ${updatedData.keys.toList()}');
      await _firestore
          .collection(_incidentsCollection)
          .doc(incidentId)
          .update(updatedData);
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(e.message ?? 'Failed to update incident', code: e.code),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  // delete
  Future<Result<void>> deleteIncident(String incidentId) async {
    try {
      await _firestore
          .collection(_incidentsCollection)
          .doc(incidentId)
          .delete();
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(e.message ?? 'Failed to delete incident', code: e.code),
      );
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }
}
