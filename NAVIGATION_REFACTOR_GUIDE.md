# RESOLV Navigation Refactor — Implementation Guide

**Objective:** Clean up navigation architecture and prepare for AI integration  
**Timeline:** ~4.5 hours  
**Difficulty:** Medium (mostly copy-paste from existing patterns)

---

## Phase 1: Critical Path (90 minutes)

### Task 1.1: Add Missing Admin Incident Routes
**File:** `lib/routing/app_router.dart`  
**Time:** 15 minutes  
**Difficulty:** ⭐ Easy

```dart
// In GoRouter routes array, after AdminReportDetailScreen route, add:

GoRoute(
  path: AppRoutes.adminIncidents,
  builder: (context, state) => const AdminIncidentListScreen(), // NEW
  routes: [
    GoRoute(
      // Full path: /admin/incidents/:incidentId
      path: ':incidentId',
      builder: (context, state) {
        final incidentId = state.pathParameters['incidentId']!;
        final incident = state.extra as IncidentModel?;

        if (incident != null) return AdminIncidentDetailScreen(incident: incident);

        // TODO: Fetch incident from Firestore if not passed via extra
        return const Scaffold(
          body: SafeArea(
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    ),
  ],
),
```

**Note:** This also requires an `AdminIncidentListScreen` which is not yet created (lower priority).

---

### Task 1.2: Complete IncidentService
**File:** `lib/services/incident_service.dart`  
**Time:** 30 minutes  
**Difficulty:** ⭐ Easy (follows existing patterns)

Add these methods to `IncidentService`:

```dart
// Get single incident
Future<Result<IncidentModel>> getIncidentById(String incidentId) async {
  try {
    final doc = await _firestore.collection(_incidentsCollection).doc(incidentId).get();
    if (!doc.exists) {
      return Result.failure(Failure('Incident not found'));
    }
    return Result.success(IncidentModel.fromDoc(doc));
  } on FirebaseException catch (e) {
    return Result.failure(Failure(e.message ?? 'Failed to fetch incident', code: e.code));
  } catch (e) {
    return Result.failure(Failure('An unexpected error occurred'));
  }
}

// Get all incidents
Future<Result<List<IncidentModel>>> getAllIncidents() async {
  try {
    final snapshot = await _firestore
        .collection(_incidentsCollection)
        .orderBy('updatedAt', descending: true)
        .get();
    
    final incidents = snapshot.docs.map((doc) => IncidentModel.fromDoc(doc)).toList();
    return Result.success(incidents);
  } on FirebaseException catch (e) {
    return Result.failure(Failure(e.message ?? 'Failed to fetch incidents', code: e.code));
  } catch (e) {
    return Result.failure(Failure('An unexpected error occurred'));
  }
}

// Stream all incidents (real-time)
Stream<Result<List<IncidentModel>>> streamAllIncidents() {
  try {
    return _firestore
        .collection(_incidentsCollection)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final incidents = snapshot.docs.map((doc) => IncidentModel.fromDoc(doc)).toList();
          return Result.success(incidents);
        })
        .handleError((e) {
          if (e is FirebaseException) {
            return Result.failure(Failure(e.message ?? 'Stream failed', code: e.code));
          }
          return Result.failure(Failure('An unexpected error occurred'));
        });
  } catch (e) {
    return Stream.value(Result.failure(Failure('Failed to initialize stream')));
  }
}

// Get incidents for a specific location/category (for admin dashboard)
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
    final incidents = snapshot.docs.map((doc) => IncidentModel.fromDoc(doc)).toList();
    return Result.success(incidents);
  } on FirebaseException catch (e) {
    return Result.failure(Failure(e.message ?? 'Failed to fetch incidents', code: e.code));
  }
}
```

**Reference:** `lib/services/report_service.dart` for similar patterns

---

### Task 1.3: Create IncidentRepository
**File:** `lib/features/report/repositories/incident_repository.dart` (NEW)  
**Time:** 45 minutes  
**Difficulty:** ⭐ Easy (direct copy-adapt from ReportRepository)

```dart
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
    return _service.getIncidentsFiltered(category: category, priority: priority);
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
    return _service.updateIncident(incidentId, {'status': newStatus.name});
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
      'status': IncidentStatus.pending.name,
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
```

---

## Phase 2: Code Cleanup (30 minutes)

### Task 2.1: Delete AdminReportListScreen
**File:** `lib/features/report/admin/screens/admin_report_list_screen.dart`  
**Time:** 2 minutes  
**Action:** Delete file (confirmed redundant with AdminDashboardScreen)

Then remove import from `app_router.dart`:
```dart
// REMOVE THIS LINE:
import 'package:resolv/features/report/admin/screens/admin_report_list_screen.dart';
```

---

### Task 2.2: Delete ProfileScreen
**File:** `lib/features/profile/presentation/screens/profile_screen.dart`  
**Time:** 2 minutes  
**Action:** Delete file (currently unused)

Then remove import from `app_router.dart`:
```dart
// REMOVE THIS LINE:
import 'package:resolv/features/profile/presentation/screens/profile_screen.dart';
```

---

### Task 2.3: Archive ReportListsScreen2
**File:** `lib/features/report/user/presentation/screens/report_lists_screen_2.dart`  
**Time:** 5 minutes  
**Action:** Move to examples folder

```bash
# Move file
mkdir -p lib/features/report/examples
mv lib/features/report/user/presentation/screens/report_lists_screen_2.dart \
   lib/features/report/examples/report_list_screen_with_incidents_demo.dart
```

Add comment at top of file:
```dart
/// ARCHIVED: Example UI demonstrating incident grouping (deduplication concept).
/// 
/// This screen shows how multiple reports can be grouped into a single incident
/// for deduplication. It was used as a UI prototype and is kept for reference.
/// 
/// DO NOT use in production — replace with ReportListScreen from:
/// lib/features/report/user/presentation/screens/report_list_screen.dart
```

---

### Task 2.4: Move ReportUiModel
**File:** Create `lib/models/report_ui_model.dart`  
**Time:** 20 minutes  
**Action:** Extract and reorganize

1. Create new file:
```dart
// lib/models/report_ui_model.dart
import 'package:resolv/core/enums/report_enums.dart';

/// UI model for displaying reports in the presentation layer.
/// 
/// This separates the Firestore ReportModel from UI-specific concerns like
/// formatting and transient state.
class ReportUiModel {
  const ReportUiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.submittedAt,
    required this.submittedByName,
    this.address,
    this.imageUrl,
    this.adminNote,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final ReportCategory category;
  final ReportStatus status;
  final DateTime submittedAt;
  final String submittedByName;
  final String? address;
  final String? imageUrl;
  final String? adminNote;
  final DateTime? updatedAt;
}
```

2. Update `report_mock_data.dart` to import:
```dart
// lib/features/report/user/repositories/report_mock_data.dart
import 'package:resolv/models/report_ui_model.dart'; // ADD THIS

// Remove the ReportUiModel class definition — now imported above

final kMockReports = <ReportUiModel>[
  ReportUiModel(...),
  // ...
];
```

3. Update all imports in these files:
   - `lib/features/report/user/presentation/screens/report_list_screen.dart`
   - `lib/features/report/user/presentation/screens/report_detail_screen.dart`
   - `lib/features/report/user/presentation/widgets/report_card.dart`
   - `lib/routing/app_router.dart`

Change from:
```dart
import 'package:resolv/features/report/user/repositories/report_mock_data.dart'; // ReportUiModel was here
```

To:
```dart
import 'package:resolv/models/report_ui_model.dart';
import 'package:resolv/features/report/user/repositories/report_mock_data.dart'; // If still using kMockReports
```

---

## Phase 3: Incident Infrastructure (90 minutes)

### Task 3.1: Create Incident Providers
**File:** `lib/features/report/providers/incident_providers.dart` (NEW)  
**Time:** 30 minutes  
**Difficulty:** ⭐ Easy (follow user_report_providers.dart pattern)

```dart
// lib/features/report/providers/incident_providers.dart

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
final incidentStreamProvider = StreamProvider<List<IncidentModel>>((ref) async* {
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
final recentIncidentsProvider = FutureProvider<List<IncidentModel>>((ref) async {
  final result = await ref.watch(incidentRepositoryProvider).fetchAllIncidents();
  if (result.isSuccess) {
    final incidents = result.data ?? [];
    // Return top 5 most recent
    return incidents.take(5).toList();
  }
  return [];
});

/// Filtered incidents (by category/priority).
final filteredIncidentsProvider = FutureProvider.family<List<IncidentModel>, ({ReportCategory? category, IncidentPriority? priority})>((ref, filters) async {
  final result = await ref.watch(incidentRepositoryProvider).fetchIncidentsFiltered(
    category: filters.category,
    priority: filters.priority,
  );
  return result.isSuccess ? result.data ?? [] : [];
});

/// Single incident by ID.
final incidentByIdProvider = FutureProvider.family<IncidentModel?, String>((ref, incidentId) async {
  final result = await ref.watch(incidentRepositoryProvider).fetchIncidentById(incidentId);
  return result.isSuccess ? result.data : null;
});
```

---

### Task 3.2: Update IncidentService with Missing Methods
**Already covered in Task 1.2** — This is included in that section

---

### Task 3.3: Wire IncidentService to IncidentRepository
**Already covered in Task 1.3** — This is the repository creation task

---

## Phase 4: Mock Data Replacement (120 minutes)

### Task 4.1: Replace HomeScreen Mock Data
**File:** `lib/features/report/user/presentation/screens/home_screen.dart`  
**Time:** 20 minutes  
**Difficulty:** ⭐⭐ Medium (add Riverpod + error handling)

Replace hardcoded mock data with provider:

```dart
// BEFORE:
const _mockIncidents = [
  (id: '1', title: 'Damaged Road on Mabini Street', ...),
  // ...
];

// AFTER: In the _RecentIncidentsSection widget
class _RecentIncidentsSection extends ConsumerWidget {
  const _RecentIncidentsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(recentIncidentsProvider);

    return incidentsAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SizedBox(
        height: 200,
        child: Center(child: Text('Failed to load incidents: $error')),
      ),
      data: (incidents) {
        if (incidents.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(child: Text('No incidents yet')),
          );
        }

        return Column(
          children: [
            // Header...
            ...incidents.map((incident) => IncidentCard(
              id: incident.id,
              title: incident.title,
              category: incident.category,
              priority: incident.priority,
              status: incident.status,
              reportCount: incident.reportCount,
              lastUpdated: incident.updatedAt,
              aiGenerated: incident.aiGenerated,
              tags: incident.tags,
              onTap: () {
                // Navigate to incident detail
                context.push(AppRoutes.adminIncidentDetail(incident.id),
                  extra: incident);
              },
            )),
          ],
        );
      },
    );
  }
}
```

**Important:** Update imports:
```dart
import 'package:resolv/features/report/providers/incident_providers.dart';
```

---

### Task 4.2: Replace AdminDashboardScreen Mock Data
**File:** `lib/features/report/admin/screens/admin_dashboard_screen.dart`  
**Time:** 45 minutes  
**Difficulty:** ⭐⭐ Medium

Replace hardcoded constants with Firestore queries:

```dart
// Example for _kpiData replacement:
class AdminDashboardKPI {
  final int activeIncidents;
  final int pendingReports;
  final int highPriority;
  final int aiGrouped;
}

// In AdminDashboardScreen, add:
// Get KPI data from Firestore
Future<AdminDashboardKPI> _fetchKpis(WidgetRef ref) async {
  final incidents = await ref.read(incidentRepositoryProvider).fetchAllIncidents();
  final reports = await ref.read(reportRepositoryProvider).fetchAllReports();
  
  final activeIncidents = incidents.data?.where((i) => 
    i.status != IncidentStatus.resolved).length ?? 0;
  final pendingReports = reports.data?.where((r) =>
    r.status == ReportStatus.pending).length ?? 0;
  final highPriority = incidents.data?.where((i) =>
    i.priority == IncidentPriority.high || i.priority == IncidentPriority.critical).length ?? 0;
  final aiGrouped = incidents.data?.where((i) => i.aiGenerated).length ?? 0;

  return AdminDashboardKPI(
    activeIncidents: activeIncidents,
    pendingReports: pendingReports,
    highPriority: highPriority,
    aiGrouped: aiGrouped,
  );
}

// Use in build():
final kpiAsync = ref.watch(FutureProvider.autoDispose((ref) => _fetchKpis(ref)));

kpiAsync.when(
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
  data: (kpi) => _KpiCard(kpi: kpi),
);
```

---

### Task 4.3: Connect AdminIncidentDetailScreen to Real Data
**File:** `lib/features/report/admin/screens/admin_incident_detail_screen.dart`  
**Time:** 20 minutes  
**Difficulty:** ⭐ Easy

Replace mock data initialization:

```dart
// Update constructor to accept IncidentModel:
class AdminIncidentDetailScreen extends ConsumerWidget {
  const AdminIncidentDetailScreen({
    super.key,
    required this.incident,
  });

  final IncidentModel incident;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch linked reports from Firestore
    final reportsAsync = ref.watch(FutureProvider.autoDispose((ref) async {
      return await Future.wait(
        incident.reportIds.map((id) =>
          ref.read(reportRepositoryProvider).fetchReportById(id)),
      );
    }));

    // Use incident.title, incident.status, etc. instead of mock data
    // Use reportsAsync to get linked reports

    // Rest of the UI stays the same
  }
}
```

---

## Phase 5: Create Missing Incident Screens (Optional — Can Be Done Later)

### Task 5.1: Create UserIncidentListScreen
**Time:** 1 hour  
**Priority:** MEDIUM (can add in Phase 2)

Follow the pattern of ReportListScreen:
- Connect to `recentIncidentsProvider` or `incidentStreamProvider`
- Add filter by status, priority
- Navigate to detail on tap

### Task 5.2: Create UserIncidentDetailScreen
**Time:** 45 minutes  
**Priority:** MEDIUM (can add in Phase 2)

Follow the pattern of ReportDetailScreen:
- Accept `IncidentModel`
- Show linked reports
- Show timeline

---

## Testing Checklist

After each task, verify:

### After Task 1.1 (Routes)
- [ ] Deep link to `/admin/incidents` works
- [ ] Deep link to `/admin/incidents/123` works
- [ ] No route errors in console

### After Task 1.2 & 1.3 (Services & Repository)
- [ ] Can instantiate `IncidentRepository`
- [ ] Can call `fetchAllIncidents()`
- [ ] Can stream incidents with `streamAllIncidents()`
- [ ] Firestore returns real data (check Firebase console)

### After Task 3.1 (Providers)
- [ ] `recentIncidentsProvider` returns incidents
- [ ] `incidentByIdProvider` can fetch by ID
- [ ] Providers properly dispose

### After Task 4.1, 4.2, 4.3 (Mock Replacement)
- [ ] HomeScreen shows real incidents (or empty if none in Firestore)
- [ ] AdminDashboard shows real KPI data
- [ ] AdminIncidentDetailScreen accepts and displays real IncidentModel

### Final Verification
- [ ] No unused imports
- [ ] All routes reachable
- [ ] No navigation errors
- [ ] Firestore reads/writes working
- [ ] Tests pass (if any exist)

---

## Common Pitfalls to Avoid

1. **Forgetting to update imports after moving files**
   - Always search for old import paths
   - Use IDE's "Refactor > Rename" feature when possible

2. **Mixing mock and real data in same screen**
   - Decide: either 100% mock or 100% real
   - HomeScreen, AdminDashboard, AdminIncidentDetailScreen should all use real data

3. **Not handling async/loading states**
   - Always include `.when()` for AsyncValue
   - Show loading indicator, error message, and data

4. **Breaking existing navigation**
   - Test role-based redirects after route changes
   - Verify admin can't access user routes and vice versa

5. **Firestore security rules**
   - Ensure rules allow reading incidents/reports
   - Test with production data if available

---

## Quick Reference: File Locations

```
lib/
├── routing/
│   ├── app_router.dart        (ADD incident routes)
│   └── app_routes.dart        (already has incident route constants)
├── services/
│   ├── report_service.dart    (reference for patterns)
│   └── incident_service.dart  (ADD missing methods)
├── models/
│   ├── report_model.dart
│   ├── report_ui_model.dart   (NEW — move ReportUiModel here)
│   └── incident_model.dart
├── features/report/
│   ├── repositories/
│   │   ├── report_repository.dart    (reference)
│   │   └── incident_repository.dart  (NEW)
│   ├── providers/
│   │   ├── user_report_providers.dart
│   │   └── incident_providers.dart   (NEW)
│   ├── admin/screens/
│   │   ├── admin_report_list_screen.dart  (DELETE)
│   │   └── admin_incident_detail_screen.dart (UPDATE)
│   ├── user/presentation/screens/
│   │   ├── home_screen.dart          (UPDATE)
│   │   ├── report_list_screen.dart   (keep — reference)
│   │   └── report_lists_screen_2.dart (MOVE to examples/)
│   └── examples/
│       └── report_list_screen_with_incidents_demo.dart (NEW)
└── features/profile/
    └── presentation/screens/
        └── profile_screen.dart  (DELETE)
```

---

## Summary

**What This Refactor Achieves:**
- ✅ Fixes incomplete Incident infrastructure
- ✅ Removes dead/unused code
- ✅ Consolidates duplicate implementations
- ✅ Replaces mock data with real Firestore queries
- ✅ Prepares codebase for AI features
- ✅ Improves code organization and maintainability

**What's NOT Changed:**
- ✅ Authentication flow (working perfectly)
- ✅ Report submission/viewing (already connected to Firestore)
- ✅ Overall app structure (minimal disruption)
- ✅ UI components (keep existing design system)

**After This Refactor:**
The application will be production-ready for AI integration with:
- Clean navigation
- Consistent data sources
- Complete feature infrastructure
- No technical debt blocking new features

---

**Questions?** Refer back to `NAVIGATION_AUDIT_REPORT.md` for detailed context.
