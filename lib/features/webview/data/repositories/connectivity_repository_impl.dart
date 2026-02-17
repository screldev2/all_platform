import '../../domain/repositories/connectivity_repository.dart';
import '../datasources/connectivity_remote_data_source.dart';

class ConnectivityRepositoryImpl implements ConnectivityRepository {
  final ConnectivityRemoteDataSource dataSource;

  ConnectivityRepositoryImpl(this.dataSource);

  @override
  Future<bool> checkConnection() => dataSource.checkConnection();

  @override
  Stream<bool> get connectionStatus => dataSource.connectionStatus;

  @override
  Future<void> initialize() => dataSource.initialize();

  @override
  void dispose() => dataSource.dispose();
}
