## Integration Guide: Adding AI Analysis to Report Submission

This guide shows exactly how to integrate the AI analysis workflow into your existing report submission process.

---

## Current Flow

```
User submits report
    ↓
ReportService.submitReport() 
    ↓
Report stored in Firestore
    ↓
Done
```

---

## New Flow with AI

```
User submits report
    ↓
ReportService.submitReport() 
    ↓
Report stored in Firestore (initial, without incident)
    ↓
AiNotifier.analyzeReport() triggered
    ↓
AiController orchestrates workflow:
  - Classify report
  - Query active incidents
  - Check for duplicates
  - Create incident or attach to existing
  - Update report with analysis + incident ID
    ↓
Firestore updated with:
  - report.incidentId
  - report.aiAnalysis
  - report.isDuplicate
  - incident created/updated
    ↓
UI updates via stream providers
    ↓
Done
```

---

## Code Changes Required

### 1. Update ReportService.submitReport()

**File**: `lib/services/report_service.dart`

The current submitReport() must initialize `incidentId` and `isDuplicate`:

```dart
Future<Result<String>> submitReport({
  required String title,
  required String description,
  required ReportCategory category,
  required String submittedByName,
  required String submittedByUid,
  String? address,
  String? imageUrl,
}) async {
  try {
    final docRef = await _firestore.collection(_reportsCollection).add({
      'title': title,
      'description': description,
      'category': category.value,
      'status': ReportStatus.pending.value,
      'submittedAt': FieldValue.serverTimestamp(),
      'submittedByName': submittedByName,
      'submittedByUid': submittedByUid,
      'address': address,
      'imageUrl': imageUrl,
      'adminNote': null,
      'updatedAt': null,
      'incidentId': '',              // NEW: Initialize empty
      'isDuplicate': false,          // NEW: Initialize false
      'aiAnalysis': null,            // NEW: Will be filled by AI
      'remarks': [],                 // NEW: Initialize empty
    });

    return Result.success(docRef.id);
  } on FirebaseException catch (e) {
    return Result.failure(Failure(e.message ?? 'Failed to submit report', code: e.code));
  } catch (e) {
    return Result.failure(Failure('An unexpected error occurred'));
  }
}
```

---

### 2. Update Report Submission Controller/Handler

**Where**: Your report submission UI controller or screen

After successful report submission, fetch the report and trigger AI analysis:

```dart
// In your ReportController or report submission handler
Future<void> submitReport() async {
  try {
    _isSubmitting = true;
    notifyListeners();

    // Step 1: Submit report to Firestore
    final reportResult = await _reportRepository.submitReport(
      title: titleController.text,
      description: descriptionController.text,
      category: _selectedCategory,
      submittedByName: currentUser.displayName,
      submittedByUid: currentUser.uid,
      address: addressController.text,
      imageUrl: null, // or upload image
    );

    if (reportResult.isFailure) {
      _errorMessage = reportResult.error!.message;
      notifyListeners();
      return;
    }

    // Step 2: Fetch the submitted report
    final reportId = reportResult.data!;
    final fetchResult = await _reportService.fetchReportById(reportId);
    
    if (fetchResult.isFailure) {
      _errorMessage = 'Failed to fetch submitted report';
      notifyListeners();
      return;
    }

    final submittedReport = fetchResult.data!;

    // Step 3: Trigger AI analysis (in background)
    // This will handle classification and deduplication
    // Pass the ref parameter if in a ConsumerWidget/ConsumerStatefulWidget
    _triggerAiAnalysis(submittedReport);

    // Show success message
    _errorMessage = null;
    _successMessage = 'Report submitted! AI analysis in progress...';
    notifyListeners();

    // Clear form
    titleController.clear();
    descriptionController.clear();
    addressController.clear();

  } catch (e) {
    _errorMessage = 'An error occurred: $e';
    notifyListeners();
  } finally {
    _isSubmitting = false;
    notifyListeners();
  }
}

// Helper method to trigger AI analysis
void _triggerAiAnalysis(ReportModel report) {
  // If you have access to WidgetRef:
  // ref.read(aiNotifierProvider.notifier).analyzeReport(report);
  
  // Or trigger as a future task
  Future.delayed(Duration(milliseconds: 100), () {
    ref.read(aiNotifierProvider.notifier).analyzeReport(report);
  });
}
```

---

### 3. Update Report Submission UI

**Where**: Your report submission screen/form

Add status indicator while AI analysis is running:

```dart
class ReportSubmissionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportController = ref.watch(reportControllerProvider);
    final aiState = ref.watch(aiNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Submit Report')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Existing form fields...
            TextFormField(
              controller: reportController.titleController,
              decoration: InputDecoration(labelText: 'Report Title'),
            ),
            TextFormField(
              controller: reportController.descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            // ... more fields ...

            SizedBox(height: 16),

            // AI Analysis Status Indicator
            aiState.when(
              loading: () => Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Analyzing report...'),
                    ],
                  ),
                ),
              ),
              error: (err, stack) => Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 12),
                      Expanded(child: Text('Analysis failed: $err')),
                    ],
                  ),
                ),
              ),
              data: (result) {
                if (result == null) return SizedBox();
                return Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 12),
                            Text('Analysis complete!'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Incident ID: ${result.incidentId}',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          result.isDuplicate
                              ? 'Attached to existing incident'
                              : 'Created new incident',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 16),

            // Submit Button
            ElevatedButton(
              onPressed: reportController.canSubmit
                  ? () => _handleSubmit(context, ref, reportController)
                  : null,
              child: reportController.isSubmitting
                  ? CircularProgressIndicator()
                  : Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit(BuildContext context, WidgetRef ref, ReportController controller) {
    // Call your submission logic
    controller.submitReport().then((_) {
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report submitted and queued for analysis')),
      );
    });
  }
}
```

---

### 4. Update Report Repository (if needed)

**File**: `lib/features/report/repositories/report_repository.dart`

If you're creating a custom repository method for submission with AI:

```dart
/// Submit a report and trigger AI analysis
Future<Result<ReportModel>> submitReportWithAiAnalysis({
  required String title,
  required String description,
  required ReportCategory category,
  required String submittedByName,
  required String submittedByUid,
  required AiRepository aiRepository,
  required IncidentRepository incidentRepository,
  String? address,
  String? imageUrl,
}) async {
  try {
    // Step 1: Submit base report
    final submitResult = await submitReport(
      title: title,
      description: description,
      category: category,
      submittedByName: submittedByName,
      submittedByUid: submittedByUid,
      address: address,
      imageUrl: imageUrl,
    );

    if (submitResult.isFailure) {
      return Result.failure(submitResult.error!);
    }

    // Step 2: Fetch the created report
    final reportId = submitResult.data!;
    final fetchResult = await fetchReportById(reportId);

    if (fetchResult.isFailure) {
      return Result.failure(fetchResult.error!);
    }

    final report = fetchResult.data!;

    // Step 3: AI Analysis happens asynchronously via notifier
    // Controller should trigger: ref.read(aiNotifierProvider.notifier).analyzeReport(report);

    return Result.success(report);
  } catch (e) {
    return Result.failure(Failure('Report submission failed: $e'));
  }
}
```

---

## Minimal Integration Example

If you want the absolute minimal integration:

```dart
// 1. In your report submission handler:
Future<void> onSubmitReport(ReportModel report, WidgetRef ref) async {
  // Submit to Firestore (existing code)
  final result = await reportService.submitReport(...);
  
  // 2. Get the report
  final report = await reportService.fetchReportById(result.data!);
  
  // 3. Trigger AI analysis (one line!)
  ref.read(aiNotifierProvider.notifier).analyzeReport(report);
}

// 2. In your report display UI:
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Replace this:
  // final incidents = mockIncidents;
  
  // With this:
  final incidents = ref.watch(openIncidentsStreamProvider);

  return incidents.when(
    loading: () => CircularProgressIndicator(),
    error: (e, _) => Text('Error: $e'),
    data: (incidents) => ListView(
      children: incidents.map((i) => ListTile(title: Text(i.title))).toList(),
    ),
  );
}
```

---

## Key Points

1. **Async Process**: AI analysis happens asynchronously after report submission
2. **User Feedback**: Show loading state while analysis runs
3. **Error Handling**: Display errors if AI analysis fails
4. **Firestore First**: Report is created before AI analysis starts
5. **Real-time Updates**: Use stream providers to see results as they arrive
6. **No Blocking**: User doesn't wait for AI analysis to complete

---

## Testing the Integration

1. Submit a test report
2. Check Firestore console to verify report created
3. Check AI analysis notifier state
4. Verify incident created (or report attached to existing)
5. Verify reportCount incremented
6. Check isDuplicate flag set correctly
7. Verify aiAnalysis field populated with classification

