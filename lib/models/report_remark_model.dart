import 'package:cloud_firestore/cloud_firestore.dart';

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