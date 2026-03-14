class AiService {
  Future<Map<String, dynamic>> extractMetadata(String transcript) async {
    // MVP Mock Implementation - In reality, this would send transcript to LLM via Cloud Function
    await Future.delayed(const Duration(seconds: 2));

    return {
      "summary": "Mock summary: $transcript",
      "category": "Uncategorized",
      "keywords": ["mock", "test", "data"],
      "documentType": "unknown"
    };
  }

  Future<List<double>> generateEmbedding(String text) async {
     // MVP Mock Implementation
     return [0.1, 0.2, 0.3];
  }
}
