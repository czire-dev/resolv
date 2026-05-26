import 'package:firebase_ai/firebase_ai.dart';
import 'package:resolv/core/utils/result.dart';
import 'package:resolv/models/ai_analysis_model.dart';


// TODO: Implement caching of AI results to avoid redundant calls for the same report
class AiService {
  final model = FirebaseAI.googleAI().generativeModel(model: 'gemini-3.1-flash-lite');

  // Future<Result<AiAnalysisModel>> analyzeReport({
  //   required String title,
  //   required String description,
  // }) {
  //   // build prompt

  //   // call AI

  //   // parse JSON

  //   // return model
  // }
}
