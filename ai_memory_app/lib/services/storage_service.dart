import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String userId, File file, String fileName) async {
    final ref = _storage.ref().child('users/$userId/files/$fileName');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteFile(String userId, String fileName) async {
    final ref = _storage.ref().child('users/$userId/files/$fileName');
    await ref.delete();
  }
}
