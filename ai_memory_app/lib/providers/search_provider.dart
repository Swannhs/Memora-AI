import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item_model.dart';
import '../services/search_service.dart';
import 'file_provider.dart';
import 'auth_provider.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(ref.watch(firestoreServiceProvider));
});

// Using StateProvider from riverpod is correct, let's make sure it's exported properly
// by explicitly importing riverpod or just changing to Notifier. Let's use StateProvider.
// Actually, flutter_riverpod exports StateProvider. The issue might be missing import or version.
// In riverpod 3+, StateProvider might be deprecated or behaves differently? Wait, no, StateProvider is still there.
// Let's use Notifier to be safe and modern with Riverpod 3.0
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void updateQuery(String newQuery) => state = newQuery;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

final searchResultsProvider = FutureProvider<List<FileItemModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final user = ref.watch(userProvider);

  if (user == null || query.isEmpty) {
    return [];
  }

  return ref.watch(searchServiceProvider).performSearch(user.uid, query);
});
