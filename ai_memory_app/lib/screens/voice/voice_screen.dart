import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/speech_service.dart';
import '../../services/ai_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/file_provider.dart';
import '../../models/file_item_model.dart';
import 'package:uuid/uuid.dart';

class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({super.key});

  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends ConsumerState<VoiceScreen> {
  final _speechService = SpeechService();
  final _aiService = AiService();

  bool _isRecording = false;
  bool _isProcessing = false;
  String? _transcript;
  String? _audioPath;

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _speechService.stopRecord();
      setState(() {
        _isRecording = false;
        _audioPath = path;
      });
      _processAudio();
    } else {
      final started = await _speechService.startRecord();
      if (started) {
        setState(() {
          _isRecording = true;
          _transcript = null;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission required.')),
          );
        }
      }
    }
  }

  Future<void> _processAudio() async {
    if (_audioPath == null) return;

    setState(() => _isProcessing = true);

    try {
      final transcript = await _speechService.transcribeAudio(_audioPath!);
      setState(() {
        _transcript = transcript;
        _isProcessing = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveVoiceMemory() async {
    if (_transcript == null) return;

    final user = ref.read(userProvider);
    if (user == null) return;

    setState(() => _isProcessing = true);

    try {
      final metadata = await _aiService.extractMetadata(_transcript!);
      final firestoreService = ref.read(firestoreServiceProvider);

      final fileItem = FileItemModel(
        id: const Uuid().v4(),
        userId: user.uid,
        fileName: 'Voice Note ${DateTime.now().toString().split('.')[0]}',
        fileUrl: '', // Mock URL for MVP audio
        fileType: 'audio',
        voiceTranscript: _transcript,
        summary: metadata['summary'],
        category: metadata['category'],
        keywords: List<String>.from(metadata['keywords']),
        createdAt: DateTime.now(),
      );

      await firestoreService.createFileMetadata(fileItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice memory saved!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Intelligent Voice'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF020229),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),
            if (_isProcessing)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing Context...'),
                ],
              )
            else if (_transcript != null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  _transcript!,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF020229),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Text(
                _isRecording ? 'Listening...' : 'Tap to speak',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF020229),
                ),
              ),
            const Spacer(),
            GestureDetector(
              onTap: _toggleRecording,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red : const Color(0xFF020229),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording ? Colors.red : const Color(0xFF020229)).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 48),
            if (_transcript != null && !_isProcessing)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _transcript = null;
                        _audioPath = null;
                      });
                    },
                    icon: const Icon(Icons.cancel, color: Colors.grey),
                    label: const Text('Discard', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton.icon(
                    onPressed: _saveVoiceMemory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4B41E1),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm & Save'),
                  ),
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
