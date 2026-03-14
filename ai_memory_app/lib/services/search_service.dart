import '../models/file_item_model.dart';
import 'firestore_service.dart';

class SearchService {
  final FirestoreService _firestoreService;

  SearchService(this._firestoreService);

  Future<List<FileItemModel>> performSearch(String userId, String query) async {
     return await _firestoreService.searchFiles(userId, query);
  }
}
