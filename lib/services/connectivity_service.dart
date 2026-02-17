import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  bool _isConnected = true;
  bool _isInitialized = false;

  bool get isConnected => _isConnected;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);

      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (error) => debugPrint('Connectivity stream error: $error'),
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing connectivity: $e');
      _isConnected = false;
      _connectionStatusController.add(false);
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected = results.any((result) => result != ConnectivityResult.none);

    // Only emit change if status actually changed
    if (wasConnected != _isConnected) {
      debugPrint('Connectivity changed: $_isConnected');
      _connectionStatusController.add(_isConnected);
    }
  }

  Future<bool> checkConnection() async {
    if (!_isInitialized) {
      await initialize();
      return _isConnected;
    }

    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
      return _isConnected;
    } catch (e) {
      debugPrint('Error checking connection: $e');
      return false;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
}
