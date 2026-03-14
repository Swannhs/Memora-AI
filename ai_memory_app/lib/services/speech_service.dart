import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class SpeechService {
  final AudioRecorder _audioRecorder = AudioRecorder();

  Future<bool> startRecord() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return false;
    }

    if (await _audioRecorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      return true;
    }
    return false;
  }

  Future<String?> stopRecord() async {
    return await _audioRecorder.stop();
  }

  Future<String> transcribeAudio(String path) async {
    // MVP Mock Implementation - In reality, this would call a Cloud Function or External API
    // e.g. using 'dio' to send the audio file to Google Speech-to-Text or OpenAI Whisper
    await Future.delayed(const Duration(seconds: 2));
    return "This is a mock transcription of the audio.";
  }
}
