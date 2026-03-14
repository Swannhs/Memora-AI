import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to initialize Firebase. Since we don't have valid google-services.json
  // or flutterfire config in this environment, we'll wrap it in a try-catch
  // to prevent it from crashing the app completely during testing.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Note: In a real app, you would handle this gracefully or ensure Firebase is configured properly before running.
  }

  runApp(const ProviderScope(child: AiMemoryApp()));
}

class AiMemoryApp extends StatelessWidget {
  const AiMemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Memory Vault',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF020229)),
        useMaterial3: true,
        fontFamily: 'Inter', // Assuming Inter font is added to pubspec.yaml
      ),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
