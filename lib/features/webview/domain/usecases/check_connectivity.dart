import '../repositories/connectivity_repository.dart';

class CheckConnectivity {
  final ConnectivityRepository repository;

  CheckConnectivity(this.repository);

  Future<bool> execute() {
    return repository.checkConnection();
  }
}
