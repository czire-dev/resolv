import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resolv/core/utils/result.dart';
import 'package:resolv/models/incident_model.dart';

class IncidentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _incidentsCollection = 'incidents';

  // create
  Future<Result<IncidentModel>> createIncident(Map<String, dynamic> incidentData) async {
    try {
      final docRef = await _firestore.collection(_incidentsCollection).add(incidentData);

      final doc = await docRef.get();

      final incident = IncidentModel.fromDoc(doc);
      return Result.success(incident);
    } on FirebaseException catch (e) {
      return Result.failure(Failure(e.message ?? 'Failed to create incident', code: e.code));
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  // update
  Future<Result<void>> updateIncident(String incidentId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection(_incidentsCollection).doc(incidentId).update(updatedData);
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(Failure(e.message ?? 'Failed to update incident', code: e.code));
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  // delete
  Future<Result<void>> deleteIncident(String incidentId) async {
    try {
      await _firestore.collection(_incidentsCollection).doc(incidentId).delete();
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(Failure(e.message ?? 'Failed to delete incident', code: e.code));
    } catch (e) {
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }
}
