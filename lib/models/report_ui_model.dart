import 'package:resolv/core/enums/report_enums.dart';

/// UI model for displaying reports in the presentation layer.
///
/// This separates the Firestore ReportModel from UI-specific concerns like
/// formatting and transient state.
class ReportUiModel {
  const ReportUiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.submittedAt,
    required this.submittedByName,
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
  final String? address;
  final String? imageUrl;
  final String? adminNote;
  final DateTime? updatedAt;
}
