import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/file_item_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createFileMetadata(FileItemModel fileItem) async {
    await _firestore.collection('files').doc(fileItem.id).set(fileItem.toMap());
  }

  Stream<List<FileItemModel>> getUserFiles(String userId) {
    return _firestore
        .collection('files')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FileItemModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteFileMetadata(String id) async {
    await _firestore.collection('files').doc(id).delete();
  }

  Future<List<FileItemModel>> searchFiles(String userId, String query) async {
    // Basic exact text search implementation for MVP
    // This will check if filename, summary, category or keywords contain the query

    // In a real app we'd use Algolia or Typesense, or do a vector search on the 'embedding' array
    final snapshot = await _firestore
        .collection('files')
        .where('userId', isEqualTo: userId)
        .get();

    final queryLower = query.toLowerCase();

    final files = snapshot.docs
        .map((doc) => FileItemModel.fromMap(doc.data(), doc.id))
        .toList();

    return files.where((file) {
      final matchFileName = file.fileName.toLowerCase().contains(queryLower);
      final matchSummary = (file.summary ?? '').toLowerCase().contains(queryLower);
      final matchCategory = (file.category ?? '').toLowerCase().contains(queryLower);
      final matchKeywords = file.keywords.any((k) => k.toLowerCase().contains(queryLower));

      return matchFileName || matchSummary || matchCategory || matchKeywords;
    }).toList();
  }
}
