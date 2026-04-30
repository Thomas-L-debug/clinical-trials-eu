import 'package:postgres/postgres.dart';

class Database {
  static late Connection _connection;

  static Future<void> connect() async {
    _connection = await Connection.open(
      Endpoint(
        host: 'postgres',
        database: 'clinical_trials',
        username: 'dev',
        password: 'dev123',
      ),
      settings: ConnectionSettings(
        sslMode: SslMode.disable,
      ),
    );
    print('✅ Connexion PostgreSQL réussie');
  }

  static Connection get connection => _connection;

  static Future<void> close() async {
    await _connection.close();
  }
}
