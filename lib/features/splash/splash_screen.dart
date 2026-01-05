import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasidie_city_whisper/app/providers/providers.dart';
import 'package:kasidie_city_whisper/features/onboarding/onboarding_screen.dart';
import 'package:kasidie_city_whisper/features/main/main_app_shell.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await ref.read(cacheServiceProvider.future);
      await ref.read(settingsProvider.notifier).ensureInitialized();
    } catch (e) {
      // Continue even if cache initialization fails
    }
    
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;
    
    final settings = ref.read(settingsProvider);
    
    if (settings.firstRun) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainAppShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'kasidie',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -1,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'CITY WHISPER',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 48,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                minHeight: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
