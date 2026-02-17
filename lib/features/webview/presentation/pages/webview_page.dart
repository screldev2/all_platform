import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../widgets/offline_screen.dart';
import '../widgets/error_screen.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/exit_confirmation_dialog.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/connectivity_repository.dart';

class WebViewPage extends StatelessWidget {
  final ConnectivityRepository connectivityRepository;
  const WebViewPage({super.key, required this.connectivityRepository});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: _WebViewContent(connectivityRepository: connectivityRepository)),
      ),
    );
  }
}

class _WebViewContent extends StatefulWidget {
  final ConnectivityRepository connectivityRepository;
  const _WebViewContent({required this.connectivityRepository});

  @override
  State<_WebViewContent> createState() => _WebViewContentState();
}

class _WebViewContentState extends State<_WebViewContent> with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  final InAppWebViewSettings _settings = InAppWebViewSettings(isInspectable: true, mediaPlaybackRequiresUserGesture: false, allowsInlineMediaPlayback: true, iframeAllowFullscreen: true, userAgent: AppConstants.userAgent);

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
    widget.connectivityRepository.dispose();
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
    await widget.connectivityRepository.initialize();
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
    widget.connectivityRepository.connectionStatus.listen((isConnected) {
      if (mounted) {
        setState(() => _isConnected = isConnected);
        if (isConnected && _hasError) {
          _reloadWebView();
        }
      }
    });
  }

  Future<NavigationActionPolicy> _handleNavigationDecision(InAppWebViewController controller, NavigationAction navigationAction) async {
    return NavigationActionPolicy.ALLOW;
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
    final isConnected = await widget.connectivityRepository.checkConnection();
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
            OfflineScreen(onRetry: _checkConnectivityAndReload, connectivityRepository: widget.connectivityRepository)
          else if (_hasError)
            ErrorScreen(errorMessage: _errorMessage, onRetry: _reloadWebView)
          else
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(AppConstants.homeUrl)),

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
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
              },
              shouldOverrideUrlLoading: _handleNavigationDecision,
            ),

          LoadingIndicator(progress: _loadingProgress.toDouble(), isLoading: _loadingProgress < 100),
        ],
      ),
    );
  }
}
