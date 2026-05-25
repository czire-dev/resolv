/// Mock data and lightweight UI model for the Reports feature.
/// Replace with real Riverpod providers once the backend layer is wired.
library;

import 'package:resolv/core/enums/report_enums.dart';

// ── UI Model ──────────────────────────────────────────────────────────────────

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

// ── Mock Data ─────────────────────────────────────────────────────────────────

final kMockReports = <ReportUiModel>[
  ReportUiModel(
    id: 'RPT-001',
    title: 'Broken street light on Rizal Avenue',
    description:
        'The street light near the corner of Rizal Ave and Mabini St has been broken for over two weeks. The area is very dark at night and poses a safety hazard for pedestrians and motorists.',
    category: ReportCategory.streetLight,
    status: ReportStatus.inProgress,
    submittedAt: DateTime.now().subtract(const Duration(days: 3)),
    submittedByName: 'Juan dela Cruz',
    address: 'Rizal Ave cor. Mabini St, Brgy. San Antonio',
    adminNote: 'Forwarded to the engineering department for immediate repair.',
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  ReportUiModel(
    id: 'RPT-002',
    title: 'Clogged drainage causing flooding',
    description:
        'The drainage canal along Bonifacio Street is clogged with garbage and causes flooding every time it rains heavily. Several houses in the area have been affected.',
    category: ReportCategory.flooding,
    status: ReportStatus.pending,
    submittedAt: DateTime.now().subtract(const Duration(days: 1)),
    submittedByName: 'Maria Santos',
    address: 'Bonifacio St, Brgy. San Antonio',
  ),
  ReportUiModel(
    id: 'RPT-003',
    title: 'Illegal dumping near the creek',
    description:
        'Unknown individuals have been dumping construction debris and household waste near the creek behind Purok 3. This is causing a foul smell and health concerns.',
    category: ReportCategory.sanitation,
    status: ReportStatus.resolved,
    submittedAt: DateTime.now().subtract(const Duration(days: 10)),
    submittedByName: 'Pedro Reyes',
    address: 'Purok 3, Brgy. San Antonio',
    adminNote: 'Clean-up drive completed. Area is now cleared.',
    updatedAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  ReportUiModel(
    id: 'RPT-004',
    title: 'Loud videoke every night',
    description:
        'A neighbor at Block 5, Lot 12 plays extremely loud videoke almost every night from 9pm to 2am. Despite verbal requests to tone it down, they continue to disturb the entire block.',
    category: ReportCategory.noise,
    status: ReportStatus.rejected,
    submittedAt: DateTime.now().subtract(const Duration(days: 7)),
    submittedByName: 'Ana Gonzales',
    address: 'Block 5 Lot 12, Brgy. San Antonio',
    adminNote:
        'Noise ordinance hours start at 10pm. Incident reported before that time. Please resubmit with documented evidence.',
    updatedAt: DateTime.now().subtract(const Duration(days: 6)),
  ),
  ReportUiModel(
    id: 'RPT-005',
    title: 'Pothole on main road',
    description:
        'There is a large pothole on the main road near the barangay hall. It has already caused one motorcycle accident and continues to be a hazard.',
    category: ReportCategory.infrastructure,
    status: ReportStatus.pending,
    submittedAt: DateTime.now().subtract(const Duration(hours: 6)),
    submittedByName: 'Roberto Lim',
    address: 'Main Road, near Barangay Hall',
  ),
  ReportUiModel(
    id: 'RPT-006',
    title: 'Suspicious activity at the park',
    description:
        'Several individuals have been gathering at the park late at night and engaging in suspicious behavior. Residents are afraid to pass through the area.',
    category: ReportCategory.publicSafety,
    status: ReportStatus.inProgress,
    submittedAt: DateTime.now().subtract(const Duration(days: 2)),
    submittedByName: 'Carmen Villanueva',
    address: 'People\'s Park, Brgy. San Antonio',
    adminNote: 'Coordinating with Barangay Tanod for night patrol.',
    updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
  ),
];