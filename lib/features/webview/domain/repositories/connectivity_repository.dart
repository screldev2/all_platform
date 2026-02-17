abstract class ConnectivityRepository {
  Future<bool> checkConnection();
  Stream<bool> get connectionStatus;
  Future<void> initialize();
  void dispose();
}
