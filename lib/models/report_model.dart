import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resolv/core/enums/report_enums.dart';

class ReportModel {
  const ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.submittedAt,
    required this.submittedByName,
    required this.submittedByUid,
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
  final String submittedByUid;
  final String? address;
  final String? imageUrl;
  final String? adminNote;
  final DateTime? updatedAt;

  /// Convert [ReportModel] to a Firestore-compatible Map.
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.value,
      'status': status.value,
      'submittedAt': submittedAt,
      'submittedByName': submittedByName,
      'submittedByUid': submittedByUid,
      'address': address,
      'imageUrl': imageUrl,
      'adminNote': adminNote,
      'updatedAt': updatedAt,
    };
  }

  /// Create [ReportModel] from a Firestore document.
  factory ReportModel.fromFirestore(Map<String, dynamic> data, String docId) {
    final submittedAtValue = data['submittedAt'];
    final submittedAt = submittedAtValue is Timestamp
        ? submittedAtValue.toDate()
        : submittedAtValue as DateTime? ?? DateTime.now();

    final updatedAtValue = data['updatedAt'];
    final updatedAt = updatedAtValue is Timestamp
        ? updatedAtValue.toDate()
        : updatedAtValue as DateTime?;

    return ReportModel(
      id: data['id'] as String? ?? docId,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: ReportCategoryX.fromString(data['category'] as String? ?? 'other'),
      status: ReportStatusX.fromString(data['status'] as String? ?? 'pending'),
      submittedAt: submittedAt,
      submittedByName: data['submittedByName'] as String? ?? 'Unknown',
      submittedByUid: data['submittedByUid'] as String? ?? '',
      address: data['address'] as String?,
      imageUrl: data['imageUrl'] as String?,
      adminNote: data['adminNote'] as String?,
      updatedAt: updatedAt,
    );
  }

  /// Create a copy of this model with some fields replaced.
  ReportModel copyWith({
    String? id,
    String? title,
    String? description,
    ReportCategory? category,
    ReportStatus? status,
    DateTime? submittedAt,
    String? submittedByName,
    String? submittedByUid,
    String? address,
    String? imageUrl,
    String? adminNote,
    DateTime? updatedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      submittedByName: submittedByName ?? this.submittedByName,
      submittedByUid: submittedByUid ?? this.submittedByUid,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      adminNote: adminNote ?? this.adminNote,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
