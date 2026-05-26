// report/models/report_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/models/ai_analysis_model.dart';
import 'package:resolv/models/report_remark_model.dart';

class ReportModel {
  final String id;

  final String incidentId;

  final String title;
  final String description;

  final ReportCategory category;

  final ReportStatus status;

  final DateTime submittedAt;
  final DateTime? updatedAt;

  final String submittedByUid;
  final String submittedByName;

  final String address;

  final String? imageUrl;

  final AiAnalysisModel? aiAnalysis;

  final bool isDuplicate;

  final List<ReportRemark> remarks;

  const ReportModel({
    required this.id,
    required this.incidentId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.submittedAt,
    required this.submittedByUid,
    required this.submittedByName,
    required this.address,
    required this.isDuplicate,
    this.updatedAt,
    this.imageUrl,
    this.aiAnalysis,
    this.remarks = const [],
  });

  factory ReportModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      category: ReportCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => ReportCategory.other,
      ),
      status: ReportStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ReportStatus.pending,
      ),
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      submittedByName: data['submittedByName'] as String? ?? '',
      submittedByUid: data['submittedByUid'] as String? ?? '',
      address: data['address'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      aiAnalysis: data['aiAnalysis'] != null
          ? AiAnalysisModel.fromJson(data['aiAnalysis'] as Map<String, dynamic>)
          : null,
      remarks: data['remarks'] != null
          ? (data['remarks'] as List)
                .map((r) => ReportRemark.fromMap(r as Map<String, dynamic>))
                .toList()
          : [],
      incidentId: data['incidentId'] as String? ?? '',
      isDuplicate: data['isDuplicate'] as bool? ?? false,
    );
  }
}
