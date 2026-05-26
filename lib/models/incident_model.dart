import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resolv/core/enums/incident_enums.dart';
import 'package:resolv/core/enums/report_enums.dart';

class IncidentModel {
  final String id;

  final String title;

  final ReportCategory category;

  final IncidentPriority priority;

  final IncidentStatus status;

  final List<String> tags;

  final int reportCount;

  final List<String> reportIds;

  final DateTime createdAt;
  final DateTime updatedAt;

  final DateTime lastReportAt;

  final bool aiGenerated;

  const IncidentModel({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.status,
    required this.tags,
    required this.reportCount,
    required this.reportIds,
    required this.createdAt,
    required this.updatedAt,
    required this.lastReportAt,
    required this.aiGenerated,
  });

  factory IncidentModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IncidentModel(
      id: doc.id,
      title: data['title'] as String,
      category: ReportCategory.values.firstWhere((c) => c.name == data['category']),
      priority: IncidentPriority.values.firstWhere((p) => p.name == data['priority']),
      status: IncidentStatus.values.firstWhere((s) => s.name == data['status']),
      tags: List<String>.from(data['tags'] ?? []),
      reportCount: data['reportCount'] as int,
      reportIds: List<String>.from(data['reportIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastReportAt: (data['lastReportAt'] as Timestamp).toDate(),
      aiGenerated: data['aiGenerated'] as bool,
    );
  }
}
