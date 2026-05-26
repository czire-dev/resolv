# RESOLV Audit — Quick Reference Checklist

## 📋 Executive Summary

**Audit Completed:** Navigation and screen architecture audit complete  
**Status:** Application has solid Report infrastructure, but Incident feature incomplete  
**Blocker for AI:** Yes — critical routing and infrastructure issues must be fixed first  
**Estimated Fix Time:** 4–5 hours  

---

## 🔴 CRITICAL Issues (Fix Before Any Other Work)

- [ ] **Add `/admin/incidents` routes** to `app_router.dart`
  - Routes exist in constants but not in GoRouter
  - Takes 15 minutes
  
- [ ] **Complete IncidentService** — missing read/stream methods
  - Need: `getIncidentById()`, `getAllIncidents()`, `streamAllIncidents()`
  - Takes 30 minutes
  
- [ ] **Create IncidentRepository**
  - New file: `lib/features/report/repositories/incident_repository.dart`
  - Copy pattern from ReportRepository
  - Takes 45 minutes

---

## 🟠 HIGH Priority (This Week)

- [ ] **Delete dead code**
  - [ ] Delete `AdminReportListScreen` (redundant)
  - [ ] Delete `ProfileScreen` (unused)
  - [ ] Archive `ReportListsScreen2` to examples/
  - Takes 15 minutes total

- [ ] **Move ReportUiModel**
  - From: `report_mock_data.dart`
  - To: `lib/models/report_ui_model.dart`
  - Update 8 imports
  - Takes 20 minutes

- [ ] **Create Incident Providers**
  - New file: `lib/features/report/providers/incident_providers.dart`
  - Takes 30 minutes

---

## 🟡 MEDIUM Priority (Before AI Integration)

- [ ] **Replace mock data in production screens**
  - [ ] HomeScreen: Use real incident provider
  - [ ] AdminDashboardScreen: Use Firestore queries for KPIs
  - [ ] AdminIncidentDetailScreen: Use real IncidentModel
  - Takes 1.5 hours

---

## ✅ Currently Working (Keep As-Is)

- [x] Authentication (all 3 screens routed and working)
- [x] Report submission (connected to Firestore)
- [x] Report listing (connected to Firestore)
- [x] Report details (connected to Firestore)
- [x] Riverpod state management
- [x] GoRouter configuration (role-based guards working)

---

## 📊 Screens Inventory

### ✅ KEEP (7 screens)
- LoginScreen
- RegisterScreen
- ForgotPasswordScreen
- HomeScreen
- ReportListScreen (v1)
- ReportDetailScreen
- CreateReportScreen
- AdminReportDetailScreen

### 🗑️ DELETE (2 screens)
- AdminReportListScreen (redundant with AdminDashboardScreen)
- ProfileScreen (unreachable)

### 🔄 MERGE (1 implementation)
- ReportListsScreen2 (archive as demo, don't use in routing)

### 📝 REFACTOR (3 screens)
- HomeScreen (replace mock data)
- AdminDashboardScreen (replace mock KPIs)
- AdminIncidentDetailScreen (connect to real data)

---

## 🛣️ Route Structure

### Current (Working)
```
/auth/login ✅
/auth/register ✅
/auth/forgot-password ✅
/home ✅
/user/reports ✅
/user/reports/:id ✅
/user/create-report ✅
/admin/reports ✅
/admin/reports/:reportId ✅
```

### Missing (Critical)
```
/admin/incidents ❌ (defined in constants, not in GoRouter)
/admin/incidents/:incidentId ❌ (same)
```

### To Add (Phase 2)
```
/user/incidents (when UserIncidentListScreen created)
/user/incidents/:id (when UserIncidentDetailScreen created)
```

---

## 📁 File Changes Summary

### New Files to Create
```
lib/models/report_ui_model.dart
lib/features/report/repositories/incident_repository.dart
lib/features/report/providers/incident_providers.dart
lib/features/report/examples/report_list_screen_with_incidents_demo.dart (MOVED)
```

### Files to Update
```
lib/routing/app_router.dart (ADD incident routes)
lib/services/incident_service.dart (ADD missing methods)
lib/features/report/user/repositories/report_mock_data.dart (remove ReportUiModel)
lib/features/report/user/presentation/screens/home_screen.dart (replace mock data)
lib/features/report/admin/screens/admin_dashboard_screen.dart (replace mock data)
lib/features/report/admin/screens/admin_incident_detail_screen.dart (use real IncidentModel)
```

### Files to Delete
```
lib/features/report/admin/screens/admin_report_list_screen.dart
lib/features/profile/presentation/screens/profile_screen.dart
```

### Files to Move
```
lib/features/report/user/presentation/screens/report_lists_screen_2.dart
  → lib/features/report/examples/report_list_screen_with_incidents_demo.dart
```

---

## 🧪 Testing Checklist

After making changes, verify:

### Routes
- [ ] `/auth/login` accessible
- [ ] `/home` redirects logged-out users to login
- [ ] `/admin/reports` only accessible to admins
- [ ] `/admin/incidents` works (after adding)
- [ ] Role-based redirects working

### Data
- [ ] HomeScreen shows real incidents (or empty state if none)
- [ ] AdminDashboard shows real KPI data
- [ ] Can navigate to incident details
- [ ] No hardcoded mock data visible in production screens

### Code Quality
- [ ] No unused imports
- [ ] No compiler errors
- [ ] No orphaned references to deleted files

---

## 🎯 Success Criteria

✅ **You're done when:**

1. No duplicate screen implementations
2. All routes routed and working
3. No unreachable screens
4. All mock data replaced with real Firestore queries (in production screens)
5. Incident infrastructure complete (service → repository → providers)
6. No dead code in codebase
7. All imports organized correctly
8. Application builds without errors
9. Navigation flows work for all roles (user, admin)

---

## 📖 Reference Documents

1. **NAVIGATION_AUDIT_REPORT.md** — Detailed audit findings (this is comprehensive)
2. **NAVIGATION_REFACTOR_GUIDE.md** — Step-by-step implementation guide with code

---

## 🚀 Next Steps After This Audit

1. **Immediate (Today)**
   - Read this checklist and the audit report
   - Prioritize the CRITICAL items

2. **This Sprint (Days 1-2)**
   - Complete critical infrastructure (Tasks 1.1–1.3)
   - Delete dead code (Task 2.1–2.3)
   - Reorganize files (Task 2.4)

3. **This Sprint (Days 3-4)**
   - Create incident providers (Task 3.1)
   - Replace mock data in 3 screens (Tasks 4.1–4.3)

4. **Before AI Integration**
   - Run full test suite
   - Test all navigation flows
   - Verify no compiler warnings
   - Then proceed with AI feature development

---

## 📞 Questions?

Refer to detailed documents:
- **What to delete?** → NAVIGATION_AUDIT_REPORT.md Phase 1 (MERGE/DELETE section)
- **How to implement?** → NAVIGATION_REFACTOR_GUIDE.md (code examples provided)
- **Why this matters?** → NAVIGATION_AUDIT_REPORT.md Executive Summary
- **What's the route tree?** → NAVIGATION_AUDIT_REPORT.md Phase 3

---

**Audit Prepared:** May 26, 2026  
**Auditor:** Senior Flutter Architect  
**Status:** Ready for implementation
