class AiAnalysisModel {
  final String predictedCategory;

  final String priority;

  final List<String> tags;

  final String incidentSummary;

  final double confidence;

  const AiAnalysisModel({
    required this.predictedCategory,
    required this.priority,
    required this.tags,
    required this.incidentSummary,
    required this.confidence,
  });

  factory AiAnalysisModel.fromJson(Map<String, dynamic> json) {
    return AiAnalysisModel(
      predictedCategory: json['predictedCategory'] as String,
      priority: json['priority'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      incidentSummary: json['incidentSummary'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'predictedCategory': predictedCategory,
    'priority': priority,
    'tags': tags,
    'incidentSummary': incidentSummary,
    'confidence': confidence,
  };
}
