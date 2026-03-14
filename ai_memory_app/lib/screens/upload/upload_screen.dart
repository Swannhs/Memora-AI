import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/file_provider.dart';
import '../../models/file_item_model.dart';
import 'package:uuid/uuid.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null || _fileName == null) return;

    final user = ref.read(userProvider);
    if (user == null) return;

    setState(() => _isUploading = true);

    try {
      final storageService = ref.read(storageServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);

      // Simulate progress for UI
      for (int i = 0; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) setState(() => _uploadProgress = i / 10.0);
      }

      final fileUrl = await storageService.uploadFile(user.uid, _selectedFile!, _fileName!);

      final fileItem = FileItemModel(
        id: const Uuid().v4(),
        userId: user.uid,
        fileName: _fileName!,
        fileUrl: fileUrl,
        fileType: _fileName!.split('.').last.toLowerCase(),
        createdAt: DateTime.now(),
      );

      await firestoreService.createFileMetadata(fileItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload Complete!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Digital Curator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF020229),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upload documents or images to enrich your personal AI assistant.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload, size: 64, color: Color(0xFF4B41E1)),
                    const SizedBox(height: 16),
                    Text(
                      _selectedFile != null ? _fileName! : 'Select Files',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF020229),
                      ),
                    ),
                    if (_selectedFile == null)
                      const Text(
                        'Tap to browse your device',
                        style: TextStyle(color: Colors.black54),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (_isUploading) ...[
              const Text('Uploading...', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.grey[300],
                color: const Color(0xFF4B41E1),
              ),
              const SizedBox(height: 32),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: (_selectedFile == null || _isUploading) ? null : _uploadFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF020229),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Finish Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
