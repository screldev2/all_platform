import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
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
  late final WebViewController _controller;
  final ConnectivityService _connectivityService = ConnectivityService();

  static const String _allowedDomain = 'google.com';
  static const String _homeUrl = 'https://www.google.com';

  bool _isConnected = true;
  bool _isLoading = true;
  bool _hasError = false;
  bool _controllerInitialized = false;
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
    await _initializeWebView();
  }

  void _debouncedProgressUpdate(int progress) {
    _progressUpdateTimer?.cancel();
    _progressUpdateTimer = Timer(_progressDebounceDuration, () {
      if (mounted) {
        setState(() {
          _loadingProgress = progress;
          _isLoading = progress < 100;
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

  Future<void> _initializeWebView() async {
    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(allowsInlineMediaPlayback: true, mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{});
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setBackgroundColor(const Color(0x00000000));

    await controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: _debouncedProgressUpdate,
        onPageStarted: (String url) {
          debugPrint('Page started loading: $url');
          if (mounted) {
            setState(() {
              _hasError = false;
              _errorMessage = null;
              _isLoading = true;
            });
          }
        },
        onPageFinished: (String url) async {
          debugPrint('Page finished loading: $url');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _loadingProgress = 100;
            });
            _updateBackButtonState();
          }
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('WebView Error: ${error.description}');
          if (mounted) {
            setState(() {
              _hasError = true;
              _errorMessage = error.description;
              _isLoading = false;
            });
          }
        },
        onNavigationRequest: _handleNavigationRequest,
      ),
    );

    if (controller.platform is AndroidWebViewController) {
      final androidController = controller.platform as AndroidWebViewController;
      await androidController.setMediaPlaybackRequiresUserGesture(false);
      await androidController.setGeolocationEnabled(false);
      await androidController.setAllowFileAccess(false);
    }

    await controller.loadRequest(Uri.parse(_homeUrl));

    setState(() {
      _controller = controller;
      _controllerInitialized = true;
    });
  }

  NavigationDecision _handleNavigationRequest(NavigationRequest request) {
    final uri = Uri.parse(request.url);

    if (uri.host == _allowedDomain || uri.host == 'www.$_allowedDomain') {
      return NavigationDecision.navigate;
    }

    if (_isExternalUrl(uri)) {
      _launchExternalUrl(request.url);
      return NavigationDecision.prevent;
    }

    debugPrint('Blocked navigation to: ${request.url}');
    return NavigationDecision.prevent;
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
      final canGoBack = await _controller.canGoBack();
      if (mounted) {
        setState(() => _canGoBack = canGoBack);
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
    await _controller.reload();
  }

  Future<bool> _handleBackPress() async {
    if (_canGoBack) {
      await _controller.goBack();
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
          if (!_isConnected) OfflineScreen(onRetry: _checkConnectivityAndReload) else if (_hasError) ErrorScreen(errorMessage: _errorMessage, onRetry: _reloadWebView) else if (_controllerInitialized) WebViewWidget(controller: _controller) else const Center(child: CircularProgressIndicator()),

          LoadingIndicator(progress: _loadingProgress.toDouble(), isLoading: _isLoading),
        ],
      ),
    );
  }
}
