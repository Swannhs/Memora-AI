import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final userFilesProvider = StreamProvider<List<FileItemModel>>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) {
    return const Stream.empty();
  }
  return ref.watch(firestoreServiceProvider).getUserFiles(user.uid);
});

final fileListProvider = Provider<List<FileItemModel>>((ref) {
  final filesAsyncValue = ref.watch(userFilesProvider);
  return filesAsyncValue.when(
    data: (files) => files,
    loading: () => [],
    error: (_, __) => [],
  );
});
