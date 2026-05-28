/// Result of a duplicate incident check.
class DuplicateCheckResult {
  final bool sameIncident;
  final int confidence;
  final String reason;

  const DuplicateCheckResult({
    required this.sameIncident,
    required this.confidence,
    required this.reason,
  });

  factory DuplicateCheckResult.fromJson(Map<String, dynamic> json) {
    return DuplicateCheckResult(
      sameIncident: json['sameIncident'] as bool? ?? false,
      confidence: (json['confidence'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'sameIncident': sameIncident,
    'confidence': confidence,
    'reason': reason,
  };

  /// Whether this result indicates a duplicate with sufficient confidence.
  bool get isDuplicateWithThreshold => sameIncident && confidence >= 80;
}
