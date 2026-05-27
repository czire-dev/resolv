import 'package:resolv/core/utils/result.dart';
import 'package:resolv/models/incident_model.dart';
import 'package:resolv/services/incident_service.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/core/enums/incident_enums.dart';

/// Repository layer for incidents feature.
/// Handles business logic and data transformation.
class IncidentRepository {
  final IncidentService _service;

  IncidentRepository(this._service);

  /// Fetch a single incident by ID.
  Future<Result<IncidentModel>> fetchIncidentById(String incidentId) async {
    return _service.getIncidentById(incidentId);
  }

  /// Fetch all incidents.
  Future<Result<List<IncidentModel>>> fetchAllIncidents() async {
    return _service.getAllIncidents();
  }

  /// Fetch incidents with optional filters.
  Future<Result<List<IncidentModel>>> fetchIncidentsFiltered({
    ReportCategory? category,
    IncidentPriority? priority,
  }) async {
    return _service.getIncidentsFiltered(
      category: category,
      priority: priority,
    );
  }

  /// Stream all incidents (real-time updates).
  Stream<Result<List<IncidentModel>>> streamAllIncidents() {
    return _service.streamAllIncidents();
  }

  /// Update incident status.
  Future<Result<void>> updateIncidentStatus({
    required String incidentId,
    required IncidentStatus newStatus,
  }) async {
    return _service.updateIncident(incidentId, {
      'status': newStatus.name,
      'updatedAt': DateTime.now(),
    });
  }

  /// Create a new incident.
  Future<Result<IncidentModel>> createIncident({
    required String title,
    required ReportCategory category,
    required IncidentPriority priority,
    required List<String> reportIds,
    required List<String> tags,
  }) async {
    final data = {
      'title': title,
      'category': category.name,
      'priority': priority.name,
      'status': IncidentStatus.monitoring.name,
      'reportIds': reportIds,
      'tags': tags,
      'reportCount': reportIds.length,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
      'lastReportAt': DateTime.now(),
      'aiGenerated': false,
    };
    return _service.createIncident(data);
  }
}
