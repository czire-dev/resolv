import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resolv/features/report/providers/ai_providers.dart';
import 'package:resolv/models/report_model.dart';

/// EXAMPLE UI INTEGRATION FOR AI ANALYSIS
///
/// This file demonstrates how to integrate AI classification and deduplication
/// into your report screens. Replace mock data usage with this pattern.

// ─── EXAMPLE 1: Trigger AI Analysis on Report Submission ──────────────────

/// Example widget showing how to trigger AI analysis after report submission.
class ReportSubmissionWithAi extends ConsumerWidget {
  final ReportModel submittedReport;

  const ReportSubmissionWithAi({required this.submittedReport});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the AI notifier state
    final aiState = ref.watch(aiNotifierProvider);

    return aiState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Analysis failed: $err')),
      data: (analysisState) {
        if (analysisState == null) {
          // Initial state - trigger analysis
          Future.microtask(() {
            ref
                .read(aiNotifierProvider.notifier)
                .analyzeReport(submittedReport);
          });
          return const Center(child: CircularProgressIndicator());
        }

        // Analysis complete
        return Column(
          children: [
            Text('Report submitted and analyzed!'),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Analysis Result:'),
                    SizedBox(height: 8),
                    Text('Incident ID: ${analysisState.incidentId}'),
                    Text('Is Duplicate: ${analysisState.isDuplicate}'),
                    Text('Confidence: ${analysisState.confidence}%'),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── EXAMPLE 2: Display All Incidents from Firestore ──────────────────────

/// Example widget replacing mock incident data with Firestore stream.
class IncidentListFromFirestore extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the incidents stream from Firestore
    final incidentsAsync = ref.watch(openIncidentsStreamProvider);

    return incidentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Failed to load incidents: $err')),
      data: (incidents) {
        if (incidents.isEmpty) {
          return const Center(child: Text('No open incidents'));
        }

        return ListView.builder(
          itemCount: incidents.length,
          itemBuilder: (context, index) {
            final incident = incidents[index];
            return ListTile(
              title: Text(incident.title),
              subtitle: Text(
                'Reports: ${incident.reportCount} | '
                'Priority: ${incident.priority.name}',
              ),
              trailing: Chip(label: Text(incident.category.name)),
            );
          },
        );
      },
    );
  }
}

// ─── EXAMPLE 3: Display User's Reports with AI Analysis ────────────────────

/// Example widget showing user reports with AI analysis results.
class UserReportsWithAnalysis extends ConsumerWidget {
  final String userId;

  const UserReportsWithAnalysis({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch user's reports stream
    final reportsAsync = ref.watch(userReportsStreamProvider(userId));

    return reportsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Failed to load reports: $err')),
      data: (reports) {
        if (reports.isEmpty) {
          return const Center(child: Text('No reports submitted'));
        }

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            final aiAnalysis = report.aiAnalysis;

            return Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Report basic info
                    Text(
                      report.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text(report.description),
                    SizedBox(height: 12),

                    // AI Analysis results (if available)
                    if (aiAnalysis != null)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Analysis:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text('Category: ${aiAnalysis.predictedCategory}'),
                            Text('Priority: ${aiAnalysis.priority}'),
                            Text(
                              'Confidence: ${aiAnalysis.confidence.toStringAsFixed(1)}%',
                            ),
                            if (report.isDuplicate)
                              Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  'Marked as duplicate',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                          ],
                        ),
                      )
                    else
                      Text(
                        'Awaiting AI analysis...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: Text('Status: ${report.status.name}')),
                        Chip(label: Text('Incident: ${report.incidentId}')),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── EXAMPLE 4: Display Reports by Incident ──────────────────────────────

/// Example widget showing all reports grouped by their incidents.
class ReportsByIncident extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsStreamProvider);
    final incidentsAsync = ref.watch(openIncidentsStreamProvider);

    return reportsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (reports) {
        return incidentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (incidents) {
            return ListView.builder(
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                final incident = incidents[index];
                final incidentReports = reports
                    .where((r) => r.incidentId == incident.id)
                    .toList();

                return ExpansionTile(
                  title: Text(incident.title),
                  subtitle: Text('${incident.reportCount} reports'),
                  children: incidentReports.isEmpty
                      ? [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No reports attached'),
                          ),
                        ]
                      : incidentReports.map((report) {
                          return Padding(
                            padding: EdgeInsets.all(8),
                            child: Card(
                              child: ListTile(
                                title: Text(report.title),
                                subtitle: Text(
                                  report.isDuplicate
                                      ? 'Duplicate report'
                                      : 'Primary report',
                                ),
                                trailing: Chip(
                                  label: Text(
                                    report.isDuplicate ? 'Dup' : 'Orig',
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ─── EXAMPLE 5: Dashboard with Multiple Metrics ─────────────────────────

/// Example dashboard showing AI-powered metrics.
class AiDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsStreamProvider);
    final incidentsAsync = ref.watch(openIncidentsStreamProvider);
    final duplicatesAsync = ref.watch(duplicateReportsStreamProvider);

    return reportsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (reports) {
        return incidentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (incidents) {
            return duplicatesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (duplicates) {
                final aiGeneratedIncidents = incidents
                    .where((i) => i.aiGenerated)
                    .length;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _MetricCard(
                            label: 'Total Reports',
                            value: reports.length.toString(),
                          ),
                          _MetricCard(
                            label: 'Incidents',
                            value: incidents.length.toString(),
                          ),
                          _MetricCard(
                            label: 'Duplicates',
                            value: duplicates.length.toString(),
                          ),
                          _MetricCard(
                            label: 'AI Generated',
                            value: aiGeneratedIncidents.toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
