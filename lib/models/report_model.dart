// report/models/report_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resolv/core/enums/report_enums.dart';

class AiAnalysis {
  final String? predictedCategory;
  final String? priority; // 'low' | 'medium' | 'high'
  final List<String> tags;

  const AiAnalysis({this.predictedCategory, this.priority, this.tags = const []});

  factory AiAnalysis.fromMap(Map<String, dynamic> map) {
    return AiAnalysis(
      predictedCategory: map['predictedCategory'] as String?,
      priority: map['priority'] as String?,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'predictedCategory': predictedCategory,
    'priority': priority,
    'tags': tags,
  };
}

class ReportRemark {
  final String status;
  final String remark;
  final DateTime updatedAt;

  const ReportRemark({required this.status, required this.remark, required this.updatedAt});

  factory ReportRemark.fromMap(Map<String, dynamic> map) {
    return ReportRemark(
      status: map['status'] as String,
      remark: map['remark'] as String? ?? '',
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'status': status,
    'remark': remark,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}

class ReportModel {
  final String id;
  final String title;
  final String description;
  final ReportCategory category;
  final ReportStatus status; // 'pending' | 'in_progress' | 'resolved'
  final DateTime submittedAt;
  final String submittedByName;
  final String submittedByUid;
  final String address;
  final String? imageUrl;
  final String? adminNote; // legacy single note — keep for backwards compat
  final DateTime? updatedAt;
  final AiAnalysis? aiAnalysis;
  final List<ReportRemark> remarks;

  const ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.submittedAt,
    required this.submittedByName,
    required this.submittedByUid,
    required this.address,
    this.imageUrl,
    this.adminNote,
    this.updatedAt,
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
      adminNote: data['adminNote'] as String?,
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      aiAnalysis: data['aiAnalysis'] != null
          ? AiAnalysis.fromMap(data['aiAnalysis'] as Map<String, dynamic>)
          : null,
      remarks: data['remarks'] != null
          ? (data['remarks'] as List)
                .map((r) => ReportRemark.fromMap(r as Map<String, dynamic>))
                .toList()
          : [],
    );
  }
}
