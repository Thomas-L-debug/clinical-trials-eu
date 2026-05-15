// backend/lib/database.dart
import 'package:postgres/postgres.dart';

class Database {
  static Connection? _connection;

  static Connection get connection {
    if (_connection == null) {
      throw StateError('Database not connected. Call Database.connect() first.');
    }
    return _connection!;
  }

  static Future<void> connect() async {
    if (_connection != null) return;

    _connection = await Connection.open(
      Endpoint(
        host: 'postgres',           // nom du service Docker
        port: 5432,
        database: 'clinical_trials',
        username: 'dev',
        password: 'dev123',
      ),
      settings: ConnectionSettings(
        sslMode: SslMode.disable,   // important en dev Docker
      ),
    );

    print('✅ Connexion PostgreSQL réussie (host: postgres)');
  }
}