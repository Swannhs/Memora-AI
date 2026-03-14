class FileItemModel {
  final String id;
  final String userId;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final String? voiceTranscript;
  final String? summary;
  final String? category;
  final List<String> keywords;
  final List<double> embedding;
  final DateTime createdAt;

  FileItemModel({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    this.voiceTranscript,
    this.summary,
    this.category,
    this.keywords = const [],
    this.embedding = const [],
    required this.createdAt,
  });

  factory FileItemModel.fromMap(Map<String, dynamic> data, String id) {
    return FileItemModel(
      id: id,
      userId: data['userId'] ?? '',
      fileName: data['fileName'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      fileType: data['fileType'] ?? '',
      voiceTranscript: data['voiceTranscript'],
      summary: data['summary'],
      category: data['category'],
      keywords: List<String>.from(data['keywords'] ?? []),
      embedding: List<double>.from(data['embedding'] ?? []),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'voiceTranscript': voiceTranscript,
      'summary': summary,
      'category': category,
      'keywords': keywords,
      'embedding': embedding,
      'createdAt': createdAt,
    };
  }
}
