# AI Workflow Integration Summary

## ✅ Complete AI Orchestration Implementation

This document outlines the full AI workflow integration for the RESOLV civic incident reporting system.

---

## Architecture Overview

```
User submits report
    ↓
CreateReportScreen.onSubmit()
    ↓
ReportService.submitReport() → Firestore (incidentId='', isDuplicate=false, aiAnalysis=null)
    ↓
reportId returned
    ↓
AiNotifier.analyzeReport(report)
    ↓
AiController.analyzeAndProcessReport()
    ├─ 1. CLASSIFY: AiService.classifyReport()
    ├─ 2. QUERY: fetchCandidateIncidents() - active incidents in same category (2hr window)
    ├─ 3. DEDUPLICATE: AiService.checkDuplicate() loop (max 10 incidents)
    ├─ 4. DECISION:
    │   ├─ IF duplicate found (confidence ≥ 80):
    │   │   └─ attachReportToIncident() - Update report + incident in Firestore
    │   └─ ELSE:
    │       └─ createNewIncident() - Use AI analysis data
    └─ 5. UPDATE: Firestore updates with FieldValues
    ↓
Stream providers auto-update UI
    ↓
Done ✓
```

---

## Implemented Components

### 1. **ReportService.submitReport()** [FIXED]
**File**: `lib/services/report_service.dart`

- ✅ Initializes AI-related fields on report creation:
  - `incidentId: ''` (empty initially)
  - `isDuplicate: false` (default)
  - `aiAnalysis: null` (no analysis yet)
- ✅ Uses Firestore `FieldValue.serverTimestamp()`
- ✅ Reports are immediately available even if AI processing fails

### 2. **AiController.analyzeAndProcessReport()** [ENHANCED]
**File**: `lib/features/report/controllers/ai_controller.dart`

Complete AI orchestration workflow with:

#### Step 1: Classification
```dart
classifyResult = await _aiRepository.classifyReport(title, description)
```
- Returns: `predictedCategory`, `priority`, `tags`, `incidentSummary`, `confidence`
- Fallback: category='other', priority='low' if AI fails

#### Step 2: Query Active Incidents
```dart
activeIncidents = await _queryActiveIncidents(report.category)
```
- Filters: `category`, `status='active'`
- Time window: Last 2 hours
- Client-side filtering to avoid composite Firestore indexes
- Maximum 10 candidates

#### Step 3: Duplicate Detection Loop
```dart
for each incident:
    duplicateResult = await _aiRepository.checkDuplicate(report, incident)
    if confidence >= 80 && sameIncident == true:
        matchingIncidentId = incident.id
        break
```
- Stops immediately when duplicate found
- Returns: `sameIncident`, `confidence`, `reason`

#### Step 4: Decision Logic
**IF duplicate found:**
- Call `_attachReportToIncident(reportId, incidentId, isDuplicate=true)`

**ELSE:**
- Call `_createNewIncident(report, aiAnalysis)`
- Then attach new report to new incident with `isDuplicate=false`

#### Step 5: Firestore Updates
Uses proper Firestore patterns:
- `FieldValue.arrayUnion([reportId])` - Append to arrays
- `FieldValue.increment(1)` - Increment counters
- `FieldValue.serverTimestamp()` - Server timestamps

### 3. **Incident Creation** [IMPLEMENTED]
**File**: `lib/features/report/controllers/ai_controller.dart`

```dart
_createNewIncident(report, aiAnalysis)
```
- Uses `aiAnalysis.incidentSummary` as title
- Uses `report.category.value` as category
- Uses `aiAnalysis.priority` as priority
- Uses `aiAnalysis.tags` as tags
- Initializes:
  - `reportCount = 1`
  - `reportIds = [report.id]`
  - `status = 'active'`
  - `aiGenerated = true`
  - `createdAt/updatedAt/lastReportAt` = now

### 4. **Report Attachment** [IMPLEMENTED]
**File**: `lib/features/report/controllers/ai_controller.dart`

```dart
_attachReportToIncident(reportId, incidentId, aiAnalysis, isDuplicate)
```

Updates report:
- `incidentId` - Links to incident
- `aiAnalysis` - Full classification data
- `isDuplicate` - True/false
- `updatedAt` - Server timestamp

Updates incident:
- `reportIds` - Array append (no duplicates)
- `reportCount` - Incremented
- `lastReportAt` - Server timestamp
- `updatedAt` - Server timestamp

### 5. **Error Handling & Fallbacks** [ENHANCED]
**File**: `lib/services/ai_service.dart`

Classification fallback if AI fails:
```dart
AiAnalysisModel(
  predictedCategory: 'other',
  priority: 'low',
  tags: [],
  incidentSummary: title,
  confidence: 0.0,
)
```

Duplicate check fallback if AI fails:
```dart
DuplicateCheckResult(
  sameIncident: false,
  confidence: 0,
  reason: 'Check failed',
)
```

**Result**: Reports never lost; workflow continues even if AI fails.

### 6. **Logging & Debugging** [ADDED]
**File**: `lib/features/report/controllers/ai_controller.dart` + `ai_service.dart`

Debug logs for every step:
```
[AI] Starting analysis for report {id}
[AI] Classification result: category=..., priority=..., confidence=...
[AI] Query active incidents: found {count} candidates
[AI] Duplicate check vs {incidentId}: sameIncident=..., confidence=...
[AI] Duplicate found! Matching incident: {incidentId}
[AI] Creating incident with title: ...
[AI] New incident created: {incidentId}
[AI] Attaching report to incident: {incidentId}
[AI] Report successfully attached as duplicate
[AI] ✓ Analysis workflow complete
[AI] ✗ Workflow failed: {error}
```

Enables fast debugging of AI workflow issues.

### 7. **UI Integration** [ALREADY WORKING]
**File**: `lib/features/report/user/presentation/screens/create_report_screen.dart`

```dart
// After report submission:
final reportId = submitResult.data!;
final reportResult = await ref
    .read(report_providers.reportRepositoryProvider)
    .fetchReportById(reportId);

if (reportResult.isSuccess) {
    await ref.read(aiNotifierProvider.notifier).analyzeReport(reportResult.data!);
    // Update success sheet with AI result
}
```

User sees appropriate message:
- "Report was linked to an existing incident" (duplicate)
- "Report was analyzed and a new incident was created" (new)
- "AI processing will continue in the background" (if error)

### 8. **Stream Provider Auto-Update** [EXISTING]
**Files**: `lib/features/report/providers/ai_providers.dart`

Stream providers automatically refresh UI:
- `userReportsStreamProvider` - User's reports (client-side sorted)
- `reportsStreamProvider` - All reports (client-side sorted)
- `incidentsStreamProvider` - All incidents with filters
- `duplicateReportsStreamProvider` - Duplicate reports (client-side sorted)
- `openIncidentsStreamProvider` - Active incidents (client-side sorted)

No manual UI refresh needed.

### 9. **State Management** [WORKING]
**File**: `lib/features/report/controllers/ai_notifier.dart`

AiNotifier manages workflow state:
```dart
AiAnalysisState {
  reportId,
  incidentId,
  isDuplicate,
  confidence,
  error
}
```

UI can subscribe to state changes for real-time feedback.

---

## Data Model Updates

### ReportModel
```dart
final String incidentId;           // Initially ''
final bool isDuplicate;             // Initially false
final AiAnalysisModel? aiAnalysis;  // Initially null
```

### IncidentModel
```dart
final int reportCount;              // Updated by AI workflow
final List<String> reportIds;       // Updated by AI workflow
final DateTime lastReportAt;        // Updated on attachment
final bool aiGenerated;             // true for AI-created incidents
```

### AiAnalysisModel
```dart
final String predictedCategory;
final String priority;
final List<String> tags;
final String incidentSummary;
final double confidence;
```

---

## Error Handling Strategy

| Scenario | Behavior | Result |
|----------|----------|--------|
| Classification fails | Use fallback (other/low) | Report stored, workflow continues |
| No candidate incidents | Create new incident | New incident created |
| Duplicate check fails | Return false (not duplicate) | Continue checking or create new |
| Incident creation fails | Log error, keep report | Report stored, user notified |
| Firestore update fails | Return error, no data loss | Report stored with incomplete linking |

**Key principle**: Never lose user data. All failures are logged and handled gracefully.

---

## Performance Optimizations

1. **Firestore Queries**:
   - Limit to 50 docs, then client-side filter to 10
   - Avoid composite indexes by using single where clause + client filtering
   - Stop duplicate loop once match found

2. **AI Requests**:
   - One classification per report
   - Maximum 10 duplicate checks (not 100+)
   - Fallback immediately on error

3. **Stream Updates**:
   - Client-side sorting (no orderBy on filtered queries)
   - Automatic UI refresh via stream providers
   - No manual setState or notifyListeners

---

## Testing Checklist

- ✅ User submits report → stored immediately
- ✅ AI classifies report → uses fallback if fails
- ✅ Active incidents queried → respects 2hr window
- ✅ Duplicate check runs → finds match at confidence ≥ 80
- ✅ Report attached to incident → reportCount incremented
- ✅ New incident created → uses AI analysis title
- ✅ Firestore updates properly → arrays/counters use FieldValues
- ✅ Stream providers refresh UI → no manual refresh needed
- ✅ Logging visible → debug information complete
- ✅ Error scenarios handled → no report loss

---

## Usage Example

```dart
// In UI (CreateReportScreen)
final submitResult = await reportController.onSubmit(ref, context);
if (submitResult.isSuccess) {
    final reportId = submitResult.data!;
    
    // Fetch the created report
    final reportResult = await reportRepo.fetchReportById(reportId);
    
    // Trigger AI analysis
    if (reportResult.isSuccess) {
        await ref.read(aiNotifierProvider.notifier)
            .analyzeReport(reportResult.data!);
    }
}

// AI workflow runs automatically:
// 1. Classifies report
// 2. Queries candidate incidents
// 3. Checks for duplicates
// 4. Creates/attaches incident
// 5. Updates Firestore
// 6. Stream providers update UI
```

---

## Files Modified

1. `lib/services/report_service.dart` - Initialize AI fields on submitReport()
2. `lib/features/report/controllers/ai_controller.dart` - Full workflow + logging
3. `lib/features/report/controllers/ai_notifier.dart` - Logging + state management
4. `lib/services/ai_service.dart` - Fallback handling + logging
5. `lib/features/report/providers/ai_providers.dart` - Already configured (no changes needed)
6. `lib/features/report/user/presentation/screens/create_report_screen.dart` - Already integrated (no changes)

---

## Summary

The complete AI workflow is now integrated into the RESOLV application:

✅ Reports are submitted and immediately stored
✅ AI analysis runs automatically after submission
✅ Classification, duplicate detection, and incident management work end-to-end
✅ Firestore updates properly with FieldValues
✅ Stream providers auto-refresh UI
✅ Comprehensive logging for debugging
✅ Fallback values ensure no data loss
✅ Architecture remains clean and modular

The system is production-ready for civic incident reporting with AI-powered deduplication and incident management.
