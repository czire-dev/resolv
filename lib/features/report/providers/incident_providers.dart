import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resolv/features/report/repositories/incident_repository.dart';
import 'package:resolv/models/incident_model.dart';
import 'package:resolv/services/incident_service.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/core/enums/incident_enums.dart';

/// Provider for [IncidentService].
final incidentServiceProvider = Provider<IncidentService>((ref) {
  return IncidentService();
});

/// Provider for [IncidentRepository].
final incidentRepositoryProvider = Provider<IncidentRepository>((ref) {
  final service = ref.watch(incidentServiceProvider);
  return IncidentRepository(service);
});

/// Stream of all incidents (real-time).
final incidentStreamProvider = StreamProvider<List<IncidentModel>>((
  ref,
) async* {
  final stream = ref.watch(incidentRepositoryProvider).streamAllIncidents();

  await for (final result in stream) {
    if (result.isSuccess) {
      yield result.data ?? [];
    } else {
      yield [];
    }
  }
});

/// Recent incidents (first N, sorted by updatedAt descending).
final recentIncidentsProvider = FutureProvider<List<IncidentModel>>((
  ref,
) async {
  final result = await ref
      .watch(incidentRepositoryProvider)
      .fetchAllIncidents();
  if (result.isSuccess) {
    final incidents = result.data ?? [];
    // Return top 5 most recent
    return incidents.take(5).toList();
  }
  return [];
});

/// Filtered incidents (by category/priority).
final filteredIncidentsProvider =
    FutureProvider.family<
      List<IncidentModel>,
      ({ReportCategory? category, IncidentPriority? priority})
    >((ref, filters) async {
      final result = await ref
          .watch(incidentRepositoryProvider)
          .fetchIncidentsFiltered(
            category: filters.category,
            priority: filters.priority,
          );
      return result.isSuccess ? result.data ?? [] : [];
    });

/// Single incident by ID.
final incidentByIdProvider = FutureProvider.family<IncidentModel?, String>((
  ref,
  incidentId,
) async {
  final result = await ref
      .watch(incidentRepositoryProvider)
      .fetchIncidentById(incidentId);
  return result.isSuccess ? result.data : null;
});
