import 'package:flutter/material.dart';
import 'package:project_google/services/connectivity_service.dart';

class OfflineScreen extends StatefulWidget {
  final VoidCallback? onRetry;

  const OfflineScreen({super.key, this.onRetry});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> with TickerProviderStateMixin {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isRetrying = false;

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _waveController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for wifi icon
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Fade animation for content
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Wave animation
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat();

    _fadeController.forward();

    // Auto-retry when connectivity is restored
    _connectivityService.connectionStatus.listen((isConnected) {
      if (isConnected && mounted) {
        widget.onRetry?.call();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _retryConnection() async {
    setState(() => _isRetrying = true);
    await Future.delayed(const Duration(seconds: 1));
    final isConnected = await _connectivityService.checkConnection();
    setState(() => _isRetrying = false);

    if (isConnected) {
      widget.onRetry?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top section with centered animated icon
            Expanded(
              flex: 2, // Icon gets 2/3 of the space
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: 200, // Fixed width to prevent layout shifts
                    height: 200, // Fixed height to prevent layout shifts
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none, // Allow waves to extend beyond container
                      children: [
                        // Animated waves
                        ...List.generate(3, (index) {
                          return AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, child) {
                              final delay = index * 0.33;
                              final progress = (_waveController.value + delay) % 1.0;
                              return Positioned(
                                left: -((progress * 60) / 2),
                                top: -((progress * 60) / 2),
                                child: Container(
                                  width: 140 + (progress * 60),
                                  height: 140 + (progress * 60),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey[300]!.withOpacity(1 - progress), width: 2),
                                  ),
                                ),
                              );
                            },
                          );
                        }),

                        // Main icon container with pulse animation
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [Colors.grey[100]!, Colors.grey[50]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                  boxShadow: [BoxShadow(color: Colors.grey[300]!.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
                                ),
                                child: Icon(Icons.wifi_off_rounded, size: 70, color: Colors.grey[400]),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom section with content
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: SingleChildScrollView(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Title
                      Text(
                        'No Internet Connection',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a), letterSpacing: -0.5),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Description with icon
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!, width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.info_outline_rounded, size: 24, color: Colors.orange[400]),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('Please check your internet connection and try again.', style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Help tips
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50]?.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[100]!, width: 1),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline_rounded, color: Colors.blue[700], size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Troubleshooting Tips',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildTip('Check WiFi or mobile data'),
                            _buildTip('Try airplane mode on/off'),
                            _buildTip('Restart your device'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Retry Button
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(colors: _isRetrying ? [Colors.grey[400]!, Colors.grey[500]!] : [const Color(0xFF129247), const Color(0xFF0d6d33)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          boxShadow: [BoxShadow(color: (_isRetrying ? Colors.grey[400]! : const Color(0xFF129247)).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                        ),
                        child: ElevatedButton(
                          onPressed: _isRetrying ? null : _retryConnection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            disabledBackgroundColor: Colors.transparent,
                            disabledForegroundColor: Colors.white,
                          ),
                          child: _isRetrying
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                                    const SizedBox(width: 12),
                                    Text('Checking...', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.refresh_rounded, size: 22),
                                    const SizedBox(width: 8),
                                    const Text('Try Again', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: Colors.blue[400], shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, color: Colors.blue[700])),
          ),
        ],
      ),
    );
  }
}
