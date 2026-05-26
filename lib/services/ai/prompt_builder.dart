/// Builds prompts for AI analysis of civic reports.
/// Handles classification and duplicate detection prompts.
class PromptBuilder {
  /// Builds the prompt for classifying a civic report.
  static String buildClassificationPrompt({
    required String reportTitle,
    required String reportDescription,
  }) {
    return '''You are an expert civic issue classifier. Analyze the following civic report and provide a detailed classification.

REPORT TITLE: $reportTitle
REPORT DESCRIPTION: $reportDescription

Classify this report by providing a JSON response with the following structure:
{
  "predictedCategory": "one of: infrastructure, public_safety, sanitation, traffic, utilities, health, education, parks, other",
  "priority": "one of: low, medium, high, critical",
  "tags": ["tag1", "tag2", "tag3"],
  "incidentSummary": "A brief 1-2 sentence summary of the incident",
  "confidence": 85
}

Guidelines:
- predictedCategory: Choose the most appropriate category based on the report content
- priority: Assess urgency based on public impact and severity
- tags: 2-5 relevant descriptive tags (lowercase, no spaces)
- incidentSummary: Concise summary suitable for public display
- confidence: Your confidence in this classification (0-100)

Respond ONLY with valid JSON, no additional text or markdown.''';
  }

  /// Builds the prompt for detecting duplicate incidents.
  static String buildDuplicateCheckPrompt({
    required String reportTitle,
    required String reportDescription,
    required String incidentTitle,
    required String incidentSummary,
    required String category,
  }) {
    return '''You are an expert at identifying duplicate civic incidents. Compare the following report with an existing incident to determine if they describe the same event.

INCOMING REPORT:
Title: $reportTitle
Description: $reportDescription
Category: $category

EXISTING INCIDENT:
Title: $incidentTitle
Summary: $incidentSummary
Category: $category

Determine if this report is about the SAME incident as the existing one. Respond with JSON:
{
  "sameIncident": true or false,
  "confidence": 0-100,
  "reason": "Brief explanation of your assessment"
}

Considerations:
- Same location = strong indicator of same incident
- Same timeframe (within hours) = important
- Similar description/details = match
- Different locations/times = likely different incidents
- Partial overlap might indicate related but separate incidents

Respond ONLY with valid JSON, no additional text or markdown.''';
  }
}
