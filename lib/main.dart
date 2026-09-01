// lib/main.dart
// ============================================================
// Entry point for the Disaster Survival Guide App.
// Initializes the database, sets up providers, and launches
// the app in full-screen dark mode for OLED battery saving.
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'core/theme/app_theme.dart';
import 'core/database/database_helper.dart';
import 'core/providers/first_aid_provider.dart';
import 'core/providers/kit_provider.dart';
import 'core/providers/compass_provider.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Screen orientation (handled per-platform in database_helper) ────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── System UI ───────────────────────────────────────────────
  // Immersive dark mode UI for OLED power saving
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // ── Keep screen ON during emergency ─────────────────────────
  try {
    await WakelockPlus.enable();
  } catch (_) {
    // Wakelock not supported on all platforms, ignore
  }

  // ── Pre-initialize the database (seeds data on first run) ───
  try {
    await DatabaseHelper.database;
  } catch (e) {
    debugPrint('Database initialization error: $e');
  }

  runApp(const DisasterSurvivalApp());
}

class DisasterSurvivalApp extends StatelessWidget {
  const DisasterSurvivalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // First Aid state management
        ChangeNotifierProvider(create: (_) => FirstAidProvider()),
        // Emergency Kit Builder state
        ChangeNotifierProvider(create: (_) => KitProvider()),
        // Compass / GPS navigation state
        ChangeNotifierProvider(create: (_) => CompassProvider()),
      ],
      child: MaterialApp(
        title: 'Disaster Survival Guide',
        debugShowCheckedModeBanner: false,

        // Pure dark mode - OLED battery saver
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,

        // Home screen
        home: const SplashScreen(),

        // Global scroll behavior override for better touch response
        scrollBehavior: _AppScrollBehavior(),
      ),
    );
  }
}

// ── Splash Screen ──────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Navigate to home after splash
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, animation, __) => FadeTransition(
              opacity: animation,
              child: const HomeScreen(),
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.emergency.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.emergency.withOpacity(0.5),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emergency.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '⚡',
                    style: TextStyle(fontSize: 64),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // App name
              Text(
                'DISASTER',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.emergency,
                  letterSpacing: 8,
                ),
              ),
              Text(
                'SURVIVAL',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: 6,
                ),
              ),
              Text(
                'GUIDE',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 10,
                ),
              ),

              const SizedBox(height: 48),

              // Loading indicator
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.border,
                  color: AppColors.emergency,
                  minHeight: 3,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                '100% OFFLINE · NO INTERNET NEEDED',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Custom Scroll Behavior (enables mouse drag on desktop) ─
class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
  };
}
