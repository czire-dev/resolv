## AI Classification and Incident Deduplication - Implementation Guide

This document outlines the complete implementation of AI-powered report classification and incident deduplication for the RESOLV application.

---

## Architecture Overview

The implementation follows a layered architecture pattern:

```
UI Layer (Flutter Widgets)
    ↓
Notifiers (Riverpod StateNotifier)
    ↓
Controllers (Business Logic Orchestration)
    ↓
Repositories (Data Transformation)
    ↓
Services (External API Integration)
    ↓
Firebase AI / Firestore
```

---

## File Structure

```
lib/
├── services/
│   ├── ai/
│   │   ├── prompt_builder.dart          # Prompt generation
│   │   └── duplicate_check_result.dart  # Result model
│   ├── ai_service.dart                   # Updated with implementations
│   └── report_service.dart               # Updated with updateReport()
│
├── features/report/
│   ├── repositories/
│   │   ├── ai_repository.dart            # AI repository layer
│   │   └── report_repository.dart        # (existing)
│   │
│   ├── controllers/
│   │   ├── ai_controller.dart            # Workflow orchestration
│   │   └── ai_notifier.dart              # State management
│   │
│   ├── providers/
│   │   ├── ai_providers.dart             # All providers
│   │   └── user_report_providers.dart    # (existing)
│   │
│   └── presentation/
│       └── examples/
│           └── ai_ui_examples.dart       # UI integration examples
```

---

## Key Components

### 1. PromptBuilder (`services/ai/prompt_builder.dart`)

Generates prompts for Gemini AI:
- **Classification Prompt**: Analyzes report and returns category, priority, tags, summary
- **Duplicate Detection Prompt**: Compares report with incident to find duplicates

**Output Format (JSON)**:
```json
{
  "predictedCategory": "infrastructure",
  "priority": "high",
  "tags": ["pothole", "road", "damage"],
  "incidentSummary": "Large pothole in Main St",
  "confidence": 85
}
```

### 2. AiService (`services/ai_service.dart`)

Direct Firebase AI integration:
- **classifyReport()**: Takes title + description, returns AiAnalysisModel
- **checkDuplicate()**: Compares report with incident, returns DuplicateCheckResult
- Handles JSON extraction from markdown-wrapped Gemini responses
- Error handling for API failures

### 3. AiRepository (`features/report/repositories/ai_repository.dart`)

Clean API layer wrapping services:
- **classifyReport()**: Returns Result<AiAnalysisModel>
- **checkDuplicate()**: Returns Result<DuplicateCheckResult>
- Transforms exceptions into Result objects for consistent error handling

### 4. AiController (`features/report/controllers/ai_controller.dart`)

Orchestrates the complete workflow:

**Main Method**: `analyzeAndProcessReport(ReportModel report)`

**Workflow**:
1. Classify report using AI
2. Query active incidents (within 2 hours, same category)
3. Check for duplicates against active incidents
4. If duplicate found (confidence >= 80):
   - Attach report to existing incident
   - Increment incident reportCount
   - Mark report.isDuplicate = true
5. If no duplicate:
   - Create new incident with AI analysis
   - Link report to new incident
6. Update Firestore with analysis data

**Duplicate Criteria**:
- Only compare same category
- Only compare incidents created within 2 hours
- Only consider match if: `sameIncident == true AND confidence >= 80`

### 5. AiNotifier (`features/report/controllers/ai_notifier.dart`)

Riverpod AsyncNotifier managing analysis state:
- **State**: AiAnalysisState (reportId, incidentId, isDuplicate, confidence, error)
- **Methods**:
  - `analyzeReport(ReportModel)`: Triggers workflow
  - `clearState()`: Resets state
- Exposes loading/success/error states automatically

### 6. Providers (`features/report/providers/ai_providers.dart`)

All Riverpod providers:

**Service Providers**:
- `aiServiceProvider`
- `reportServiceProvider`
- `incidentServiceProvider`

**Repository Providers**:
- `aiRepositoryProvider`

**Controller Providers**:
- `aiControllerProvider`

**Notifier Providers**:
- `aiNotifierProvider` - Main state management

**Stream Providers** (Real-time Firestore data):
- `incidentsStreamProvider` - All incidents (filterable)
- `reportsStreamProvider` - All reports
- `userReportsStreamProvider(userId)` - User's reports
- `duplicateReportsStreamProvider` - Duplicate reports
- `openIncidentsStreamProvider` - Open incidents only

---

## Data Models

### AiAnalysisModel
```dart
{
  "predictedCategory": String,    // Infrastructure, public_safety, etc.
  "priority": String,              // low, medium, high, critical
  "tags": List<String>,            // Descriptive tags
  "incidentSummary": String,      // Public-facing summary
  "confidence": double             // 0-100, confidence level
}
```

### DuplicateCheckResult
```dart
{
  "sameIncident": bool,            // Whether it's a duplicate
  "confidence": int,               // 0-100, confidence level
  "reason": String                 // Explanation of decision
}
```

### AnalysisWorkflowResult
```dart
{
  "reportId": String,
  "incidentId": String,
  "isDuplicate": bool,
  "aiAnalysis": AiAnalysisModel,
  "confidence": int
}
```

---

## Integration Steps

### Step 1: Update Report Submission Flow

When a report is submitted, trigger AI analysis:

```dart
// In your report submission controller
final reportResult = await _reportRepository.submitReport(...);
if (reportResult.isSuccess) {
  final report = await _reportService.fetchReportById(reportResult.data!);
  // Trigger AI analysis
  ref.read(aiNotifierProvider.notifier).analyzeReport(report);
}
```

### Step 2: Update UI to Display Firestore Data

Replace mock data with stream providers:

```dart
// Instead of mock incidents list:
final incidentsAsync = ref.watch(openIncidentsStreamProvider);

// Instead of mock reports:
final reportsAsync = ref.watch(userReportsStreamProvider(userId));

// Listen to AI analysis state:
final aiState = ref.watch(aiNotifierProvider);
```

### Step 3: Handle Analysis State in UI

```dart
aiState.when(
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Analysis failed: $err'),
  data: (result) {
    if (result == null) return SizedBox(); // Initial
    
    // Display result
    return Column(
      children: [
        Text('Incident: ${result.incidentId}'),
        Text('Duplicate: ${result.isDuplicate}'),
        Text('Confidence: ${result.confidence}%'),
      ],
    );
  },
);
```

---

## Firestore Collection Structure

### incidents/
```
{
  id: "auto-generated",
  title: "Large pothole in Main St",
  category: "infrastructure",
  priority: "high",
  status: "open",
  tags: ["pothole", "road", "damage"],
  reportCount: 3,
  reportIds: ["report1", "report2", "report3"],
  createdAt: Timestamp,
  updatedAt: Timestamp,
  lastReportAt: Timestamp,
  aiGenerated: true
}
```

### reports/
```
{
  id: "auto-generated",
  incidentId: "incident123",
  title: "Pothole on Main St",
  description: "Large pothole causing issues...",
  category: "infrastructure",
  status: "pending",
  aiAnalysis: {
    predictedCategory: "infrastructure",
    priority: "high",
    tags: [...],
    incidentSummary: "...",
    confidence: 85
  },
  isDuplicate: true,
  submittedAt: Timestamp,
  updatedAt: Timestamp,
  submittedByUid: "user123",
  submittedByName: "John Doe",
  address: "123 Main St",
  imageUrl: "gs://...",
  remarks: []
}
```

---

## Example Firestore Queries

### Query Active Incidents by Category

```dart
final snapshot = await firestore
    .collection('incidents')
    .where('category', isEqualTo: 'infrastructure')
    .where('status', isEqualTo: 'open')
    .where('lastReportAt', isGreaterThan: Timestamp.fromDate(cutoffTime))
    .get();
```

### Get All Duplicate Reports

```dart
final snapshot = await firestore
    .collection('reports')
    .where('isDuplicate', isEqualTo: true)
    .orderBy('submittedAt', descending: true)
    .get();
```

### Get Incident with All Reports

```dart
// Get incident
final incident = await firestore
    .collection('incidents')
    .doc(incidentId)
    .get();

// Get all reports for incident
final reports = await firestore
    .collection('reports')
    .where('incidentId', isEqualTo: incidentId)
    .get();
```

---

## Testing Checklist

- [ ] AI classification returns correct category and priority
- [ ] Duplicate detection works with confidence threshold
- [ ] Reports correctly attached to incidents
- [ ] Incident reportCount increments properly
- [ ] Firestore data persists and syncs
- [ ] Stream providers update in real-time
- [ ] Markdown-wrapped JSON responses parsed correctly
- [ ] Error handling for API failures
- [ ] UI updates when analysis completes
- [ ] No duplicate incidents created unnecessarily

---

## Performance Considerations

1. **AI Model Selection**: Using `gemini-2.0-flash-lite` for faster response times
2. **Time Window**: 2-hour window for active incidents minimizes comparisons
3. **Category Filtering**: Reduces duplicate check iterations
4. **Stream Subscriptions**: Only subscribe to needed data in UI
5. **Caching**: AI results stored in Firestore to avoid redundant calls

---

## Future Enhancements

- Add response caching to avoid redundant AI calls
- Implement confidence threshold tuning
- Add image analysis for better classification
- Support vector embeddings for semantic similarity
- Cloud Functions for background processing
- Batch processing for bulk report ingestion

---

## Troubleshooting

### AI Model Returns Empty Response
- Verify Firebase AI is properly initialized
- Check internet connection
- Verify API credentials in firebase.json

### Duplicate Detection Not Working
- Ensure activeIncidents query returns results
- Check confidence threshold (default: 80)
- Verify Gemini response format matches expected JSON

### Firestore Updates Not Appearing
- Ensure proper collection/field names
- Check write permissions in Firestore rules
- Verify Timestamps are properly formatted

### Providers Not Updating
- Ensure StreamProvider subscriptions are active
- Check Firestore real-time sync is enabled
- Verify no exceptions in provider builders

