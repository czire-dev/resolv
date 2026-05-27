import 'package:flutter_test/flutter_test.dart';
import 'package:resolv/core/enums/incident_enums.dart';
import 'package:resolv/core/enums/report_enums.dart';
import 'package:resolv/services/incident_service.dart';

void main() {
  group('incident status sync rules', () {
    test('IncidentStatus.active maps to ReportStatus.pending', () {
      expect(mapIncidentToReportStatus(IncidentStatus.active), ReportStatus.pending);
    });

    test('IncidentStatus.monitoring maps to ReportStatus.inProgress', () {
      expect(mapIncidentToReportStatus(IncidentStatus.monitoring), ReportStatus.inProgress);
    });

    test('IncidentStatus.resolved maps to ReportStatus.resolved', () {
      expect(mapIncidentToReportStatus(IncidentStatus.resolved), ReportStatus.resolved);
    });

    test('Rejected reports are preserved', () {
      expect(shouldPreserveReportStatus(ReportStatus.rejected), isTrue);
      expect(shouldPreserveReportStatus(ReportStatus.pending), isFalse);
      expect(shouldPreserveReportStatus(ReportStatus.inProgress), isFalse);
      expect(shouldPreserveReportStatus(ReportStatus.resolved), isFalse);
    });
  });
}