import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:project_google/services/connectivity_service.dart';
import 'package:project_google/presentation/widgets/offline_screen.dart';
import 'package:project_google/presentation/widgets/error_screen.dart';
import 'package:project_google/presentation/widgets/loading_indicator.dart';
import 'package:project_google/presentation/widgets/exit_confirmation_dialog.dart';

class Google extends StatelessWidget {
  const Google({super.key});

  @override
  Widget build(BuildContext context) {
    return const PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: _GoogleContent()),
      ),
    );
  }
}

class _GoogleContent extends StatefulWidget {
  const _GoogleContent();

  @override
  State<_GoogleContent> createState() => _GoogleContentState();
}

class _GoogleContentState extends State<_GoogleContent> with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  InAppWebViewSettings _settings = InAppWebViewSettings(isInspectable: true, mediaPlaybackRequiresUserGesture: false, allowsInlineMediaPlayback: true, iframeAllowFullscreen: true, userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36");

  final ConnectivityService _connectivityService = ConnectivityService();

  static const String _allowedDomain = 'google.com';
  static const String _homeUrl = 'https://www.google.com';

  bool _isConnected = true;
  bool _hasError = false;
  int _loadingProgress = 0;

  String? _errorMessage;
  bool _canGoBack = false;

  Timer? _progressUpdateTimer;
  static const Duration _progressDebounceDuration = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivityService.dispose();
    _progressUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkConnectivityAndReload();
    }
  }

  Future<void> _initializeApp() async {
    await _connectivityService.initialize();
    _setupConnectivityListener();
  }

  void _debouncedProgressUpdate(int progress) {
    _progressUpdateTimer?.cancel();
    _progressUpdateTimer = Timer(_progressDebounceDuration, () {
      if (mounted) {
        setState(() {
          _loadingProgress = progress;
        });
      }
    });
  }

  void _setupConnectivityListener() {
    _connectivityService.connectionStatus.listen((isConnected) {
      if (mounted) {
        setState(() => _isConnected = isConnected);
        if (isConnected && _hasError) {
          _reloadWebView();
        }
      }
    });
  }

  Future<NavigationActionPolicy> _handleNavigationDecision(InAppWebViewController controller, NavigationAction navigationAction) async {
    final url = navigationAction.request.url;
    if (url == null) return NavigationActionPolicy.CANCEL;

    final uri = url;

    if (uri.host == _allowedDomain || uri.host == 'www.$_allowedDomain') {
      return NavigationActionPolicy.ALLOW;
    }

    if (_isExternalUrl(uri)) {
      _launchExternalUrl(uri.toString());
      return NavigationActionPolicy.CANCEL;
    }

    debugPrint('Blocked navigation to: $uri');
    return NavigationActionPolicy.CANCEL;
  }

  bool _isExternalUrl(Uri uri) {
    final externalSchemes = ['tel:', 'mailto:', 'https:', 'http:'];

    if (externalSchemes.contains(uri.scheme)) {
      if (uri.scheme == 'tel:' || uri.scheme == 'mailto:') {
        return true;
      }

      if (uri.host != _allowedDomain && uri.host != 'www.$_allowedDomain') {
        final externalHosts = ['facebook.com', 'twitter.com', 'instagram.com', 'linkedin.com', 'youtube.com', 'whatsapp.com', 'telegram.org', 'paypal.com', 'stripe.com', 'google.com', 'maps.google.com', 'play.google.com', 'apps.apple.com'];

        if (externalHosts.contains(uri.host) || uri.host.contains('facebook') || uri.host.contains('google') || uri.host.contains('whatsapp') || uri.host.contains('telegram')) {
          return true;
        }
      }
    }

    return false;
  }

  Future<void> _launchExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching external URL: $e');
    }
  }

  Future<void> _updateBackButtonState() async {
    try {
      if (_webViewController != null) {
        final canGoBack = await _webViewController!.canGoBack();
        if (mounted) {
          setState(() => _canGoBack = canGoBack);
        }
      }
    } catch (e) {
      debugPrint('Error checking back navigation: $e');
    }
  }

  Future<void> _checkConnectivityAndReload() async {
    final isConnected = await _connectivityService.checkConnection();
    if (isConnected && _hasError) {
      _reloadWebView();
    }
  }

  Future<void> _reloadWebView() async {
    setState(() {
      _hasError = false;
      _errorMessage = null;
    });
    await _webViewController?.reload();
  }

  Future<bool> _handleBackPress() async {
    if (_canGoBack) {
      await _webViewController?.goBack();
      await _updateBackButtonState();
      return false;
    }
    return await ExitConfirmationDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final shouldPop = await _handleBackPress();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Stack(
        children: [
          if (!_isConnected)
            OfflineScreen(onRetry: _checkConnectivityAndReload)
          else if (_hasError)
            ErrorScreen(errorMessage: _errorMessage, onRetry: _reloadWebView)
          else
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_homeUrl)),
              initialSettings: _settings,
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                debugPrint('Page started loading: $url');
                if (mounted) {
                  setState(() {
                    _hasError = false;
                    _errorMessage = null;
                    _loadingProgress = 0;
                  });
                }
              },
              onLoadStop: (controller, url) async {
                debugPrint('Page finished loading: $url');
                if (mounted) {
                  setState(() {
                    _loadingProgress = 100;
                  });
                  _updateBackButtonState();
                }
              },
              onReceivedError: (controller, request, error) {
                debugPrint('WebView Error: ${error.description}');
                // Only show error screen for main frame errors
                if (request.isForMainFrame == true) {
                  if (mounted) {
                    setState(() {
                      _hasError = true;
                      _errorMessage = error.description;
                    });
                  }
                }
              },
              onProgressChanged: (controller, progress) {
                _debouncedProgressUpdate(progress);
              },
              shouldOverrideUrlLoading: _handleNavigationDecision,
            ),
          LoadingIndicator(progress: _loadingProgress.toDouble(), isLoading: _loadingProgress < 100),
        ],
      ),
    );
  }
}
