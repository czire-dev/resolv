# RESOLV Application — Navigation & Screen Architecture Audit Report

**Date:** May 26, 2026  
**Auditor Role:** Senior Flutter Architect  
**Audit Scope:** Complete navigation structure, screen inventory, routing configuration, mock data usage, and Firestore integration status  
**Objective:** Identify duplicates, dead code, unreachable screens, and prepare codebase for AI integration

---

## Executive Summary

The RESOLV application has **7 screens across 3 modules** (Auth, Report/Admin, Profile) with significant architectural issues:

- ✅ **Auth module:** Clean, 3 screens properly routed
- ⚠️ **Report module:** Contains **duplicate UI implementations** and **mock data mixed with real data**
- ❌ **Admin module:** **Incident routing incomplete**, AdminReportListScreen unused
- ❌ **Profile module:** Screen exists but **completely unreachable**
- ⚠️ **Incident feature:** Service exists, but **no screens** or **providers** defined

**Priority:** Immediate consolidation required before AI feature implementation.

---

# PHASE 1 — SCREEN AUDIT REPORT

## Complete Screen Inventory

### ✅ KEEP (Actively Used, Properly Integrated)

#### Authentication Screens
| Screen | Path | Status | Integration | Notes |
|--------|------|--------|-------------|-------|
| `LoginScreen` | `/auth/login` | ✅ Routed | Connected to `authControllerProvider` | Proper auth state management |
| `RegisterScreen` | `/auth/register` | ✅ Routed | Connected to `registerControllerProvider` | New user registration |
| `ForgotPasswordScreen` | `/auth/forgot-password` | ✅ Routed | Connected to `forgotPasswordControllerProvider` | Password recovery |

**Status:** KEEP — No changes needed. Auth is clean.

---

#### User/Resident Screens
| Screen | File | Path | Integration | Status |
|--------|------|------|-------------|--------|
| `HomeScreen` | `user/presentation/screens/home_screen.dart` | `/home` | Riverpod (auth state) | ✅ KEEP |
| `ReportListScreen` (v1) | `user/presentation/screens/report_list_screen.dart` | `/user/reports` | `reportControllerProvider` (Firestore-backed) | ✅ KEEP — Primary |
| `ReportDetailScreen` | `user/presentation/screens/report_detail_screen.dart` | `/user/reports/:id` | FutureBuilder + Firestore | ✅ KEEP |
| `CreateReportScreen` | `user/presentation/screens/create_report_screen.dart` | `/user/create-report` | `reportControllerProvider` | ✅ KEEP |

**Key Finding:** HomeScreen and ReportListScreen are **production-ready** and properly connected to Firestore.

---

#### Admin Screens
| Screen | File | Path | Integration | Status |
|--------|------|------|-------------|--------|
| `AdminDashboardScreen` | `admin/screens/admin_dashboard_screen.dart` | `/admin/reports` | **Mock data hardcoded** | ⚠️ REFACTOR |
| `AdminReportDetailScreen` | `admin/screens/admin_report_detail_screen.dart` | `/admin/reports/:reportId` | Accepts `ReportModel` via extra | ✅ KEEP (logic) |
| `AdminIncidentDetailScreen` | `admin/screens/admin_incident_detail_screen.dart` | `/admin/incidents/:incidentId` | **Mock data hardcoded** | ⚠️ REFACTOR |

**Key Finding:** Admin screens exist but are **not production-ready** — heavily dependent on mock data.

---

### 🗑️ DELETE (Unused, Redundant, or Obsolete)

#### Dead Code

| Item | Location | Reason | Priority |
|------|----------|--------|----------|
| `AdminReportListScreen` | `admin/screens/admin_report_list_screen.dart` | Exists but commented out in `app_router.dart` (line ~184). Replaced by `AdminDashboardScreen` | **HIGH** |
| `ProfileScreen` | `profile/presentation/screens/profile_screen.dart` | **Imported in app_router.dart but never used.** No route defined. | **HIGH** |

**Recommendation:** Remove both files after confirming no other dependencies.

---

### 🔄 MERGE (Duplicate Implementations)

#### Critical: Duplicate Report List Screens

```
CONFLICT: Two ReportListScreen classes in different files

❌ report_lists_screen_2.dart (StatefulWidget)
   - Uses hardcoded _mockGroupedReports
   - Implements incident grouping UI
   - NOT connected to routing
   - Shows reports grouped by incident (deduplication demo)

✅ report_list_screen.dart (ConsumerStatefulWidget)
   - Connected to reportControllerProvider
   - Real Firestore data
   - Active route: /user/reports
   - Filter support (by status)
```

**Issue:** Both define `class ReportListScreen { }` — potential import conflict.

**Resolution:**
1. Keep `report_list_screen.dart` (production)
2. Move `report_lists_screen_2.dart` to `examples/` folder or delete
3. If deduplication demo needed, rename to `ReportListScreenWithIncidentsExample`
4. This becomes a reference for Phase 6 (Incidents Module)

---

### 📝 REFACTOR (Functional but Needs Integration)

#### HomeScreen — Mock Data Dependency

**File:** `user/presentation/screens/home_screen.dart`  
**Current Status:** Uses hardcoded `_mockIncidents` and `_announcements`  
**Issue:** Should pull incidents from `IncidentService` provider  

**Refactor Plan:**
```dart
// BEFORE: Mock data
const _mockIncidents = [...];

// AFTER: Real-time from Firestore
final incidentsAsync = ref.watch(incidentListProvider);
```

**Scope:** Add `IncidentListProvider` (Phase 6).

---

#### AdminDashboardScreen — Mock Data Dependency

**File:** `admin/screens/admin_dashboard_screen.dart`  
**Current Status:** Uses hardcoded `_mockIncidents`, `_kpiData`, `_needsReview`  
**Issue:** Should pull from real Firestore incident + report collections  

**Refactor Plan:**
1. Replace mock KPI data with aggregated queries
2. Connect to incident/report providers
3. Keep UI structure intact

---

#### AdminIncidentDetailScreen — Mock Data Dependency

**File:** `admin/screens/admin_incident_detail_screen.dart`  
**Current Status:** Uses hardcoded `_mockLinkedReports` and `_mockTimeline`  
**Issue:** Should accept actual `IncidentModel` and fetch related reports  

**Integration:** Will be connected in Phase 6 (Incidents Module).

---

## Phase 1 Summary Table

| Category | Screen | Action | Priority |
|----------|--------|--------|----------|
| ✅ KEEP | LoginScreen | None | — |
| ✅ KEEP | RegisterScreen | None | — |
| ✅ KEEP | ForgotPasswordScreen | None | — |
| ✅ KEEP | HomeScreen | Refactor mock data (later) | LOW |
| ✅ KEEP | ReportListScreen (v1) | None | — |
| ✅ KEEP | ReportDetailScreen | None | — |
| ✅ KEEP | CreateReportScreen | None | — |
| 🔄 MERGE | ReportListsScreen2 | Archive/Example | HIGH |
| ✅ KEEP | AdminReportDetailScreen | None | — |
| 📝 REFACTOR | AdminDashboardScreen | Connect to Firestore | MEDIUM |
| 📝 REFACTOR | AdminIncidentDetailScreen | Connect to IncidentModel | MEDIUM |
| 🗑️ DELETE | AdminReportListScreen | Remove | HIGH |
| 🗑️ DELETE | ProfileScreen | Remove | HIGH |

---

# PHASE 2 — ROUTING AUDIT REPORT

## Current Route Structure

### ✅ Active Routes (Properly Defined)

```
/auth/login              → LoginScreen
/auth/register           → RegisterScreen
/auth/forgot-password    → ForgotPasswordScreen

/home                    → HomeScreen (resident home)
/user/reports            → ReportListScreen
/user/reports/:id        → ReportDetailScreen
/user/create-report      → CreateReportScreen

/admin/reports           → AdminDashboardScreen (was AdminReportListScreen)
/admin/reports/:reportId → AdminReportDetailScreen
```

**Status:** 11 routes active, properly guarded by role-based redirect.

---

### ❌ Routes Defined but NOT Implemented

```
AppRoutes.adminIncidents = '/admin/incidents'              ← DEFINED
AppRoutes.adminIncidentDetail(id) = '/admin/incidents/:id' ← DEFINED

❌ But NOT in GoRouter's routes[] list!
```

**Issue:** Routes exist in `app_routes.dart` but missing from `app_router.dart` GoRouter configuration.

---

### ❌ Dead Routes

```
AppRoutes.userHome = '/home'     ← Used as role-based redirect target
AppRoutes.userReports = '/user/reports'  ← OK
AppRoutes.userReportDetail = '/user/reports/:id'  ← OK (but note: this is a template)

NOTE: userReportDetail is a TEMPLATE (:id), actual navigation uses helper:
  AppRoutes.userReportPath('123') → '/user/reports/123' ✅
```

**No true dead routes, but confusing naming.**

---

## Redirect Logic Analysis

### Current Redirect Chain

```dart
// lib/routing/app_router.dart redirect() function

1. If loading → null (stay)
2. If not authenticated:
   - On /auth/* → null (stay, render auth screen)
   - Else → /auth/login (redirect to login)
3. If authenticated:
   - On /auth/* → AppRoutes.homeForRole(role)
     - Admin → /admin/reports
     - User → /home
   - If User on /admin/* → /home (bounce out)
   - If Admin on /user/* → /admin/reports (bounce out)
4. Else → null (allowed)
```

**Status:** ✅ Redirect logic is solid and comprehensive.

---

## Routing Issues Summary

| Issue | Severity | Fix |
|-------|----------|-----|
| `/admin/incidents` route missing from GoRouter | **CRITICAL** | Add GoRoute for `/admin/incidents` and `/admin/incidents/:incidentId` |
| AdminReportListScreen commented out | HIGH | Remove dead code or re-enable with clarification |
| ProfileScreen not routed | HIGH | Either route it or delete it |
| No user-facing incident routes | MEDIUM | Add `/user/incidents` and `/user/incidents/:id` (Phase 6) |
| ReportListsScreen2 not connected | HIGH | Move to examples or delete |

---

# PHASE 3 — NAVIGATION REFACTOR PLAN

## Proposed Final Route Structure

```
UNAUTHENTICATED:
├─ /auth/login
├─ /auth/register
└─ /auth/forgot-password

USER (Resident):
├─ /home (primary hub)
│  ├─ Quick actions: Recent Incidents, Reports, Submit Issue
│  └─ Navigation to child routes
├─ /user/reports
│  └─ /:id (detail)
├─ /user/incidents (NEW - Phase 6)
│  └─ /:id (detail)
└─ /user/create-report

ADMIN:
├─ /admin/reports (dashboard)
│  └─ /:reportId (detail)
├─ /admin/incidents (NEW)
│  └─ /:incidentId (detail)
└─ /admin/users (FUTURE)
```

## Refactor Steps

### Step 1: Remove Dead Code
- [ ] Delete `AdminReportListScreen` (confirmed redundant with AdminDashboardScreen)
- [ ] Delete `ProfileScreen` or move to backlog (currently unused)
- [ ] Archive `ReportListsScreen2` to `examples/` folder with documentation

### Step 2: Fix Existing Routes
- [ ] Uncomment admin routes in GoRouter
- [ ] Add `/admin/incidents` route to GoRouter (currently only in AppRoutes constants)
- [ ] Verify all path parameters match between AppRoutes and GoRouter

### Step 3: Prepare for Incident Screens (Phase 6)
- [ ] Create `UserIncidentListScreen` (mirrors ReportListScreen pattern)
- [ ] Create `UserIncidentDetailScreen`
- [ ] These are NOT built yet, but routes defined in AppRoutes ready

---

# PHASE 4 — HOME SCREEN REVIEW

## Analysis: Should HomeScreen be the Primary Hub?

**Current Status:** ✅ YES — HomeScreen is properly positioned

### Evidence

| Aspect | Status | Details |
|--------|--------|---------|
| **Route placement** | ✅ | Primary user route: `/home` |
| **Content** | ⚠️ | Has mock data (incidents, announcements) |
| **Navigation** | ⚠️ | Links to sub-features but not fully wired |
| **State management** | ✅ | Watches `authControllerProvider` for auth state |
| **Architecture** | ✅ | Clean StatelessWidget, no side effects |

### HomeScreen Mock Content

```dart
_mockIncidents = [
  (id: '1', title: 'Damaged Road on Mabini Street', ...),
  (id: '2', title: 'Overflowing Canal near Barangay Hall', ...),
  (id: '3', title: 'Broken Street Lamp — Rizal Avenue', ...),
]

_announcements = [
  (title: 'Community Clean-Up Drive This Saturday', ...),
  (title: 'Water Interruption Notice', ...),
]
```

### Recommended Refactor (Phase 6)

Replace mock data with real Firestore queries:

```dart
// CURRENT: Mock data hardcoded
const _mockIncidents = [...];

// REFACTOR: Real Firestore stream
final recentIncidentsAsync = ref.watch(recentIncidentsProvider);
```

### Navigation Exposed by HomeScreen

Based on UI sections identified in code:
1. ✅ **Recent Incidents** section → Should link to `/user/incidents` (NEW)
2. ✅ **My Report Status** section → Could link to `/user/reports`
3. ⚠️ **Quick Actions** section → "Submit Issue" → `/user/create-report` ✅
4. ⚠️ **Search bar** → Not connected

**Verdict:** HomeScreen is correctly positioned as primary hub. Refactor needed to use real data.

---

# PHASE 5 — REPORTS MODULE ANALYSIS

## Report-Related Files Inventory

### Models

```
lib/models/report_model.dart          ← Firestore-backed model
lib/models/report_remark_model.dart   ← Admin notes/remarks
lib/features/report/user/repositories/report_mock_data.dart:
  - ReportUiModel  ← UI model (should move to models/)
  - kMockReports   ← Test data
```

**Finding:** `ReportUiModel` defined in mock_data.dart instead of models/.

### Services & Repositories

```
lib/services/report_service.dart            ← Firestore queries
lib/features/report/repositories/report_repository.dart
  ├─ submitReport()
  ├─ fetchReportById()
  ├─ fetchUserReports()
  ├─ fetchAllReports() [ADMIN]
  ├─ streamUserReports()
  ├─ streamAllReports() [ADMIN]
  └─ updateReportStatus()
```

**Status:** ✅ Fully Firestore-integrated.

### Providers

```
lib/features/report/providers/user_report_providers.dart
  ├─ reportServiceProvider
  ├─ reportRepositoryProvider
  └─ reportControllerProvider

lib/features/report/providers/admin_report_providers.dart
  ├─ AdminReportListNotifier
  └─ adminReportListProvider

lib/features/report/user/presentation/controllers/report_controller.dart
  ├─ ReportNotifier (watches authControllerProvider, fetchUserReports)
  └─ reportControllerProvider
```

**Status:** ✅ Providers properly wired for real data.

### UI Models

**Issue:** `ReportUiModel` is defined in `report_mock_data.dart` but used throughout:

```
Usages:
- report_list_screen.dart:34          ← Creates ReportUiModel from ReportModel
- report_detail_screen.dart:16        ← Accepts ReportUiModel
- report_lists_screen_2.dart:421      ← Uses ReportUiModel
- app_router.dart:116                 ← Casts to ReportUiModel
- routing/app_routes.dart (indirect)
```

**Recommendation:** Move `ReportUiModel` to `lib/models/` and rename file `report_ui_model.dart`.

---

## Phase 5 Summary

| Item | Status | Action |
|------|--------|--------|
| ReportModel | ✅ OK | Keep — Firestore-backed |
| ReportUiModel | ⚠️ Misplaced | Move to `lib/models/` |
| ReportService | ✅ OK | Keep — Firestore queries |
| ReportRepository | ✅ OK | Keep — Business logic |
| reportControllerProvider | ✅ OK | Keep — State management |
| adminReportListProvider | ✅ OK | Keep — Admin paginated list |
| ReportListScreen (v1) | ✅ OK | Keep — Production |
| ReportListsScreen2 | 🗑️ REMOVE | Archive to examples/ |

---

# PHASE 6 — INCIDENTS MODULE ANALYSIS

## Current Incident Implementation Status

### Models

```
✅ lib/models/incident_model.dart
   - id, title, category, priority, status
   - tags, reportCount, reportIds
   - createdAt, updatedAt, lastReportAt
   - aiGenerated flag
   - fromDoc() factory for Firestore
```

**Status:** ✅ Model exists and is Firestore-ready.

### Services

```
✅ lib/services/incident_service.dart
   - createIncident()
   - updateIncident()
   - deleteIncident()
   (Note: Only CRUD, no read/stream operations)
```

**Issue:** IncidentService is incomplete — missing:
- `getIncidentById()`
- `getAllIncidents()`
- `streamIncidents()`
- `streamIncidentById()`

### Providers

```
❌ NO incident providers exist yet
❌ NO incident controllers exist yet
❌ NO incident repositories exist yet
```

**Critical Gap:** Incidents are not wired to Riverpod.

### Screens

```
❌ NO user-facing incident list screen
❌ NO user-facing incident detail screen
✅ admin/screens/admin_incident_detail_screen.dart (exists, uses mock data)
```

**Status:** Only admin can view incidents, and only with mock data.

---

## What's Missing (Before AI Integration)

| Component | Status | Priority |
|-----------|--------|----------|
| IncidentService completeness | ❌ Missing read operations | **CRITICAL** |
| IncidentRepository | ❌ Missing entirely | **CRITICAL** |
| incidentControllerProvider | ❌ Missing | **CRITICAL** |
| recentIncidentsProvider | ❌ Missing | **HIGH** |
| UserIncidentListScreen | ❌ Missing | **HIGH** |
| UserIncidentDetailScreen | ❌ Missing | **HIGH** |
| /user/incidents route | ❌ Missing | **HIGH** |
| /user/incidents/:id route | ❌ Missing | **HIGH** |

---

## Phase 6 Recommended Implementation Plan

### Priority Order:
1. **Complete IncidentService** (add missing read/stream methods)
2. **Create IncidentRepository** (follow ReportRepository pattern)
3. **Create incident providers** (follow user_report_providers.dart pattern)
4. **Create UserIncidentListScreen** (follow ReportListScreen pattern)
5. **Create UserIncidentDetailScreen** (follow ReportDetailScreen pattern)
6. **Add routes** (`/user/incidents`, `/user/incidents/:id`)
7. **Wire HomeScreen** to real incident data
8. **Wire AdminIncidentDetailScreen** to real IncidentModel

---

# PHASE 7 — MOCK DATA INVENTORY

## All Hardcoded Mock Data in Codebase

### 1. HomeScreen Mock Data
**File:** `user/presentation/screens/home_screen.dart` (lines 11–59)

```dart
const _mockIncidents = [3 incidents hardcoded]
const _announcements = [2 announcements hardcoded]
```

**Usage:** Display in Recent Incidents section  
**Replace With:** `recentIncidentsProvider` (TBD in Phase 6)  
**Priority:** MEDIUM (refactor after IncidentService)

---

### 2. ReportListsScreen2 Mock Data
**File:** `user/presentation/screens/report_lists_screen_2.dart` (lines 11–57)

```dart
const _mockGroupedReports = [
  (incidentTitle: 'Damaged Road on Mabini Street', reportCount: 7, ...),
  (incidentTitle: 'Overflowing Canal near Barangay Hall', reportCount: 12, ...),
]
```

**Usage:** Demo of incident grouping (deduplication concept)  
**Replace With:** Archive to `examples/` — this is a UI pattern example  
**Priority:** HIGH (this file should be archived/deleted)

---

### 3. AdminDashboardScreen Mock Data
**File:** `admin/screens/admin_dashboard_screen.dart` (lines 11–71)

```dart
const _kpiData = (activeIncidents: 14, pendingReports: 31, ...)
const _mockIncidents = [4 incidents hardcoded]
const _needsReview = [2 reports hardcoded]
```

**Usage:** KPI dashboard display  
**Replace With:** Firestore aggregation queries  
**Priority:** MEDIUM (refactor after IncidentService complete)

---

### 4. AdminIncidentDetailScreen Mock Data
**File:** `admin/screens/admin_incident_detail_screen.dart` (lines 10–50)

```dart
final _mockLinkedReports = [3 reports linked to incident]
final _mockTimeline = [4 timeline events]
```

**Usage:** Show linked reports and timeline  
**Replace With:** Fetch from Firestore when IncidentModel passed  
**Priority:** MEDIUM (refactor when AdminIncidentDetailScreen is routed)

---

### 5. ReportMockData Constants
**File:** `user/repositories/report_mock_data.dart` (lines 37–110)

```dart
final kMockReports = <ReportUiModel>[5 mock reports]
```

**Status:** ✅ KEEP — Used for testing/examples, well-isolated  
**Note:** Not actively used in production screens (they use Firestore)

---

## Mock Data Removal Strategy

| Source | Status | Action | Timeline |
|--------|--------|--------|----------|
| HomeScreen._mockIncidents | ❌ ACTIVE | Replace with real provider | Phase 6 |
| AdminDashboardScreen._mockData | ❌ ACTIVE | Replace with Firestore queries | Phase 6 |
| AdminIncidentDetailScreen._mock* | ❌ ACTIVE | Replace with IncidentModel + Firestore queries | Phase 6 |
| ReportListsScreen2._mockData | ⚠️ UNUSED | Archive entire file | Immediately |
| report_mock_data.dart::kMockReports | ✅ OK | Keep — test/example data | Keep |

**Total Active Mock Data:** 3 screens using hardcoded data  
**All Can Be Replaced:** ✅ Yes — Firestore backing exists for all

---

# PHASE 8 — INTEGRATION STATUS SUMMARY

## Data Source Coverage

### Reports Feature
```
✅ ReportModel         → Firestore
✅ ReportService       → Queries Firestore
✅ ReportRepository    → Business logic
✅ reportControllerProvider  → Riverpod state management
✅ ReportListScreen    → Connected to real data
✅ ReportDetailScreen  → Accepts ReportModel or fetches from Firestore
✅ CreateReportScreen  → Submits to Firestore
⚠️ ReportUiModel      → Firestore data → UI model (working but misplaced)
```

**Overall:** ✅ Reports are **production-ready**

---

### Incidents Feature
```
✅ IncidentModel       → Firestore model exists
❌ IncidentService     → INCOMPLETE (missing read/stream)
❌ IncidentRepository  → MISSING
❌ incidentControllerProvider  → MISSING
❌ UserIncidentListScreen → MISSING
❌ UserIncidentDetailScreen → MISSING
⚠️ AdminIncidentDetailScreen → Exists but disconnected from routing & real data
```

**Overall:** ❌ Incidents are **NOT production-ready**

---

### Admin Feature
```
✅ AdminReportDetailScreen  → Connected (accepts ReportModel via extra)
⚠️ AdminDashboardScreen     → Exists but uses mock data
⚠️ AdminReportListScreen    → Exists but unused (commented out)
❌ adminReportListProvider  → Exists but not used by current routed screen
```

**Overall:** ⚠️ Admin is **partially functional**

---

### Authentication Feature
```
✅ authControllerProvider  → Riverpod state
✅ LoginScreen  → Real auth
✅ RegisterScreen  → Real auth
✅ ForgotPasswordScreen  → Real auth
```

**Overall:** ✅ Auth is **production-ready**

---

# COMPREHENSIVE FINDINGS & RECOMMENDATIONS

## Critical Issues (Address Before Any Feature Work)

### 1. Missing Incident Routes
**Severity:** CRITICAL  
**Issue:** Routes defined in AppRoutes but not in GoRouter  
```dart
// app_routes.dart line 26-28
static const String adminIncidents = '/admin/incidents';
static String adminIncidentDetail(String incidentId) => '/admin/incidents/$incidentId';

// ❌ NOT in app_router.dart routes[]
```
**Fix:** Add to GoRouter routes array  
**Time:** 15 minutes

---

### 2. Duplicate Report List Screens
**Severity:** HIGH  
**Issue:** Two `class ReportListScreen` definitions  
```
report_list_screen.dart      ← Production (Riverpod + Firestore)
report_lists_screen_2.dart   ← Demo/example (StatefulWidget + mock)
```
**Fix:** Archive report_lists_screen_2.dart to examples/  
**Time:** 5 minutes

---

### 3. Incomplete Incident Service
**Severity:** CRITICAL  
**Issue:** Missing read/stream operations for Firestore queries  
```dart
// Has: createIncident, updateIncident, deleteIncident
// Missing: getIncidentById, getAllIncidents, streamIncidents
```
**Fix:** Implement missing methods following FirebaseFirestore patterns  
**Time:** 30 minutes

---

### 4. No Incident Repository & Providers
**Severity:** CRITICAL  
**Issue:** No repository layer or Riverpod providers for incidents  
**Fix:** Create following ReportRepository pattern  
**Time:** 1 hour

---

### 5. Unreachable Screens
**Severity:** HIGH  
**Issue:** ProfileScreen imported but not routed  
**Fix:** Delete or create route  
**Time:** 5 minutes (delete)

---

## Medium Priority Issues (Polish & Cleanup)

### 6. Remove Dead Code
- [ ] Delete `AdminReportListScreen` (redundant with AdminDashboardScreen)
- [ ] Delete `ProfileScreen` or route it
- **Time:** 10 minutes

### 7. Move ReportUiModel
- [ ] Move from `report_mock_data.dart` to `lib/models/report_ui_model.dart`
- [ ] Update imports across 8+ files
- **Time:** 20 minutes

### 8. Replace Mock Data in Production Screens
- [ ] HomeScreen: Replace `_mockIncidents` with real provider
- [ ] AdminDashboardScreen: Replace mock KPI data with Firestore queries
- [ ] AdminIncidentDetailScreen: Connect to real IncidentModel
- **Time:** 1.5 hours (after IncidentService/Repository done)

---

## Architecture Observations

### ✅ What's Done Well

1. **Firestore Integration Exists**
   - ReportService, ReportRepository fully connected
   - Real-time streams implemented
   - Error handling with Result<T> pattern

2. **Riverpod Properly Used**
   - Provider hierarchy clean
   - AsyncNotifier pattern for state
   - Proper dependency injection

3. **GoRouter Properly Configured**
   - Role-based guards working
   - Auth state synced via RouterNotifier
   - Nested routes functional

4. **UI Separation**
   - Screens well-organized by feature
   - Widgets extracted appropriately
   - Theme properly applied

---

### ⚠️ What Needs Work

1. **Incomplete Feature Implementation**
   - Incidents service/repository missing
   - No incident screens for users
   - No incident routing

2. **Mock Data Mixing**
   - Some screens use real data, others use mocks
   - Makes testing/debugging harder
   - Inconsistent source of truth

3. **Dead Code**
   - Unused screens still in codebase
   - Imported but unreachable components
   - Creates confusion during navigation

---

# FINAL NAVIGATION STRUCTURE (RECOMMENDED)

## Route Tree: Current → Proposed

### Current State
```
/ (root)
├── /auth/login
├── /auth/register
├── /auth/forgot-password
├── /home (user hub)
├── /user/reports
│   └── /:id
├── /user/create-report
└── /admin/reports (dashboard)
    └── /:reportId → AdminReportDetailScreen

MISSING: /admin/incidents routing
```

### Proposed Final State
```
/ (root)
├── /auth
│   ├── /login
│   ├── /register
│   └── /forgot-password
├── /home (resident hub)
│   └── Primary navigation to:
│       ├── Recent Incidents (→ /user/incidents)
│       ├── Reports (→ /user/reports)
│       └── Submit Issue (→ /user/create-report)
├── /user
│   ├── /reports
│   │   └── /:id
│   ├── /incidents (NEW)
│   │   └── /:id
│   └── /create-report
└── /admin
    ├── /reports (dashboard)
    │   └── /:reportId
    └── /incidents (NEW)
        └── /:incidentId
```

---

# DELIVERABLES SUMMARY

## 1. Screen Audit Report ✅
**Provided above — detailed in Phase 1**

Summary:
- ✅ **KEEP:** 7 screens (Auth ×3, Reports ×4, Admin ×0*)
- 🔄 **MERGE:** 1 (ReportListsScreen2 into ReportListScreen)
- 🗑️ **DELETE:** 2 (AdminReportListScreen, ProfileScreen)
- 📝 **REFACTOR:** 3 (HomeScreen, AdminDashboardScreen, AdminIncidentDetailScreen — mock data)

---

## 2. Route Tree ✅
**Provided above — Phase 3**

- Current: 11 routes, working
- Missing: `/admin/incidents` routes (defined but not routed)
- Proposed: Add `/user/incidents` routes (Phase 6)

---

## 3. Routing Fixes ✅
**Phase 3 — Navigation Refactor Plan**

| Fix | File | Priority |
|-----|------|----------|
| Add `/admin/incidents` routes to GoRouter | `app_router.dart` | **CRITICAL** |
| Remove `AdminReportListScreen` | Delete file | **HIGH** |
| Remove `ProfileScreen` | Delete file | **HIGH** |
| Archive `ReportListsScreen2` | Move to examples/ | **HIGH** |
| Verify all path parameter names | `app_router.dart` | **MEDIUM** |

---

## 4. Mock Data Report ✅
**Phase 7 — Mock Data Inventory**

Active mock data (3 locations):
1. HomeScreen._mockIncidents → Replace with provider (Phase 6)
2. AdminDashboardScreen._mockData → Replace with Firestore (Phase 6)
3. AdminIncidentDetailScreen._mock* → Replace with IncidentModel (Phase 6)

Inactive/safe:
- report_mock_data.dart::kMockReports → Keep (test data)
- ReportListsScreen2._mockData → Archive (demo)

---

## 5. Integration Status Report ✅
**Phase 8**

| Module | Status | Details |
|--------|--------|---------|
| **Reports** | ✅ Production-Ready | Firestore connected, providers wired, screens working |
| **Incidents** | ❌ Not Ready | Service incomplete, no providers, no user screens |
| **Admin** | ⚠️ Partially Working | Dashboard using mock data, needs Firestore integration |
| **Auth** | ✅ Production-Ready | All systems operational |

---

## 6. Recommended Final Navigation Structure ✅
**Phase 4 — Home Screen Review**

HomeScreen is correctly positioned as primary hub.

Final structure aligns with user intent:
```
Home Hub
├─ Recent Incidents     → /user/incidents (list) → /:id (detail)
├─ My Reports           → /user/reports (list) → /:id (detail)
└─ Submit Issue         → /user/create-report
```

---

# ACTION ITEMS (Priority Order)

## 🔴 CRITICAL (Do Before Any Feature Work)

- [ ] **Add `/admin/incidents` routes to GoRouter** (`app_router.dart`)
  - Add GoRoute for `/admin/incidents`
  - Add nested GoRoute for `/admin/incidents/:incidentId`
  - Est. Time: 15 min

- [ ] **Complete IncidentService** (`lib/services/incident_service.dart`)
  - Add `getIncidentById()`
  - Add `getAllIncidents()`
  - Add `streamIncidentsForUser()`
  - Add `streamAllIncidents()`
  - Est. Time: 30 min

- [ ] **Create IncidentRepository** (`lib/features/report/repositories/incident_repository.dart`)
  - Follow ReportRepository pattern
  - Implement all necessary queries
  - Est. Time: 45 min

## 🟠 HIGH (Do This Sprint)

- [ ] **Delete unused AdminReportListScreen**
  - Delete file
  - Remove imports
  - Est. Time: 5 min

- [ ] **Delete unreachable ProfileScreen**
  - Delete file
  - Remove import from `app_router.dart`
  - Est. Time: 5 min

- [ ] **Archive ReportListsScreen2**
  - Move to `lib/features/report/examples/report_list_screen_with_incidents_demo.dart`
  - Add comment explaining this is a deduplication demo
  - Est. Time: 5 min

- [ ] **Move ReportUiModel to proper location**
  - Create `lib/models/report_ui_model.dart`
  - Move ReportUiModel class
  - Update 8+ imports
  - Est. Time: 20 min

## 🟡 MEDIUM (After Core Fixes)

- [ ] **Create incident providers** (`lib/features/report/providers/incident_providers.dart`)
  - Follow user_report_providers.dart pattern
  - Est. Time: 30 min

- [ ] **Replace mock data in HomeScreen** (`user/presentation/screens/home_screen.dart`)
  - Use `recentIncidentsProvider` instead of hardcoded data
  - Est. Time: 20 min

- [ ] **Replace mock data in AdminDashboardScreen**
  - Use Firestore aggregation queries
  - Est. Time: 45 min

- [ ] **Create UserIncidentListScreen** (`user/presentation/screens/user_incident_list_screen.dart`)
  - Follow ReportListScreen pattern
  - Est. Time: 1 hour

---

# CONCLUSION

The RESOLV application has a **solid foundation** with working Reports module, proper Firestore integration, and clean authentication. However, **before proceeding with AI integration**, the following must be completed:

## Must-Do Before AI Work

1. ✅ Complete Incident infrastructure (Service → Repository → Providers)
2. ✅ Fix routing (add missing `/admin/incidents` routes)
3. ✅ Remove dead code (AdminReportListScreen, ProfileScreen, ReportListsScreen2)
4. ✅ Replace mock data with real Firestore queries in 3 screens
5. ✅ Create user-facing incident screens

## Estimated Timeline

- **Critical Issues:** 1–1.5 hours
- **High Priority:** 20 minutes
- **Medium Priority (refactoring):** 2–3 hours
- **Total:** ~4.5 hours of focused work

## Ready for AI Integration After?

✅ **Yes** — Once above completed, the application will have:
- Clean navigation structure
- Consistent data sources (Firestore, no hardcoded data)
- Complete incident infrastructure
- Proper routing for all user flows
- Foundation for AI classification and deduplication features

---

**Report Prepared By:** Senior Flutter Architect  
**Date:** May 26, 2026  
**Next Review:** After action items completed
