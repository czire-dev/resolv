/// Report status enumeration and extensions.
enum ReportStatus { pending, inProgress, resolved, rejected }

extension ReportStatusX on ReportStatus {
  String get label {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }

  String get value {
    return toString().split('.').last;
  }

  static ReportStatus fromString(String value) {
    return ReportStatus.values.firstWhere(
      (status) => status.toString().split('.').last == value,
      orElse: () => ReportStatus.pending,
    );
  }
}

/// Report category enumeration and extensions.
enum ReportCategory {
  infrastructure,
  sanitation,
  publicSafety,
  noise,
  flooding,
  streetLight,
  other,
}

extension ReportCategoryX on ReportCategory {
  String get label {
    switch (this) {
      case ReportCategory.infrastructure:
        return 'Infrastructure';
      case ReportCategory.sanitation:
        return 'Sanitation';
      case ReportCategory.publicSafety:
        return 'Public Safety';
      case ReportCategory.noise:
        return 'Noise Complaint';
      case ReportCategory.flooding:
        return 'Flooding';
      case ReportCategory.streetLight:
        return 'Street Light';
      case ReportCategory.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case ReportCategory.infrastructure:
        return '🏗️';
      case ReportCategory.sanitation:
        return '🗑️';
      case ReportCategory.publicSafety:
        return '🚨';
      case ReportCategory.noise:
        return '📢';
      case ReportCategory.flooding:
        return '🌊';
      case ReportCategory.streetLight:
        return '💡';
      case ReportCategory.other:
        return '📋';
    }
  }

  String get value {
    return toString().split('.').last;
  }

  static ReportCategory fromString(String value) {
    return ReportCategory.values.firstWhere(
      (category) => category.toString().split('.').last == value,
      orElse: () => ReportCategory.other,
    );
  }
}
