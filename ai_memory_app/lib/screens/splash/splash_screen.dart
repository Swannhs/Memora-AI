import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      authState.when(
        data: (user) {
          if (user != null) {
            context.go('/home');
          } else {
            context.go('/login');
          }
        },
        loading: () {},
        error: (error, stackTrace) {
          // If Firebase is not configured, we'll just go to login for now
          // to allow the UI to be explored even without a backend.
          context.go('/login');
        },
      );
    });

    return const Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.memory, size: 80, color: Color(0xFF020229)),
            SizedBox(height: 24),
            Text(
              'Memory Vault',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF020229),
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(color: Color(0xFF4B41E1)),
          ],
        ),
      ),
    );
  }
}
