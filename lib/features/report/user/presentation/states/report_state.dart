import 'package:resolv/models/report_model.dart';

class ReportState {
  final List<ReportModel?> reports;
  final bool isLoading;
  final String? errorMessage;
  ReportState({required this.reports, this.isLoading = false, this.errorMessage});

  ReportState copyWith({List<ReportModel?>? reports, bool? isLoading, String? errorMessage}) {
    return ReportState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get hasError => errorMessage != null;
  bool get isEmpty => reports.isEmpty;
  bool get hasData => reports.isNotEmpty;

  @override
  String toString() =>
      'ReportState(reports: $reports, isLoading: $isLoading, errorMessage: $errorMessage)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportState &&
        runtimeType == other.runtimeType &&
        reports == other.reports &&
        isLoading == other.isLoading &&
        errorMessage == other.errorMessage;
  }
}
