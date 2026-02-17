import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_google/presentation/pages/google.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Performance optimizations
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

  // Set status bar to white background with black icons
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark, statusBarBrightness: Brightness.light));

  // Enable performance optimizations
  // Disable debug prints in release mode
  assert(() {
    debugPrint = (String? message, {int? wrapWidth}) {};
    return true;
  }());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
      title: 'Google',
      theme: ThemeData(
        primaryColor: const Color(0xFF129247),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF129247), brightness: Brightness.light),
      ),
      home: const Google(),
    );
  }
}
