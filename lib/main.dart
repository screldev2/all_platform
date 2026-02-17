import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/webview/data/datasources/connectivity_remote_data_source.dart';
import 'features/webview/data/repositories/connectivity_repository_impl.dart';
import 'features/webview/domain/repositories/connectivity_repository.dart';
import 'features/webview/presentation/pages/webview_page.dart';
import 'core/constants/app_constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final connectivityDataSource = ConnectivityRemoteDataSource();
  final connectivityRepository = ConnectivityRepositoryImpl(connectivityDataSource);

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

  runApp(MyApp(connectivityRepository: connectivityRepository));
}

class MyApp extends StatelessWidget {
  final ConnectivityRepository connectivityRepository;
  const MyApp({super.key, required this.connectivityRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
      title: AppConstants.appTitle,
      theme: ThemeData(
        primaryColor: AppConstants.primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor, brightness: Brightness.light),
      ),
      home: WebViewPage(connectivityRepository: connectivityRepository),
    );
  }
}
