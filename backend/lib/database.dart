import 'package:postgres/postgres.dart';

class Database {
  static late Connection _connection;

  static Future<void> connect() async {
    final host = const String.fromEnvironment('DB_HOST', defaultValue: 'postgres');

    _connection = await Connection.open(
      Endpoint(
        host: host,
        database: 'clinical_trials',
        username: 'dev',
        password: 'dev123',
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
    print('✅ Connexion PostgreSQL réussie (host: $host)');
  }

  static Connection get connection => _connection;

  static Future<void> close() async {
    await _connection.close();
  }
}