import 'package:flutter/material.dart';
import 'dart:io';

class AppConstants {
  // App General
  static const String appTitle = 'Google';
  static const String homeUrl = 'https://www.isselo.com';

  // UI Styling
  static const Color primaryColor = Color(0xFF129247);
  static const Color primaryColorDark = Color(0xFF0d6d33);

  // WebView Configuration
  static String? get userAgent => Platform.isWindows ? "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" : null;

  // Error Screen Strings
  static const String errorTitle = 'Oops! Something Went Wrong';
  static const String defaultErrorMessage = 'We couldn\'t load the page. Please check your connection and try again.';
  static const String retryButtonText = 'Try Again';
  static const String troubleshootingHelpText = 'Still having trouble? Check your internet connection';

  // Offline Screen Strings
  static const String noInternetTitle = 'No Internet Connection';
  static const String noInternetMessage = 'Please check your internet connection and try again.';
  static const String troubleshootingTitle = 'Troubleshooting Tips';
  static const List<String> troubleshootingTips = ['Check WiFi or mobile data', 'Try airplane mode on/off', 'Restart your device'];
  static const String checkingText = 'Checking...';

  // Exit Confirmation Dialog Strings
  static const String exitAppTitle = 'Exit App?';
  static const String exitAppMessage = 'Are you sure you want to exit the app?';
  static const String cancelText = 'Cancel';
  static const String exitText = 'Exit';
}
