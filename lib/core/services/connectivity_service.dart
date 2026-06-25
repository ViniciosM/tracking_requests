import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class ConnectivityService {
  Future<bool> get isOnline;
  Stream<bool> get onStatusChange;
}

class InternetConnectivityService implements ConnectivityService {
  final InternetConnection _connection;
  InternetConnectivityService([InternetConnection? connection])
    : _connection = connection ?? InternetConnection();

  @override
  Future<bool> get isOnline => _connection.hasInternetAccess;

  @override
  Stream<bool> get onStatusChange => _connection.onStatusChange.map(
    (status) => status == InternetStatus.connected,
  );
}
