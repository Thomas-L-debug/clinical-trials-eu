import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'database.dart';
import 'models/trial.dart';

Router createRouter() {
  final router = Router();

  // Health check
  router.get('/health', (Request request) {
    return Response.ok('{"status": "healthy", "service": "clinical-trials-eu"}');
  });

  // Liste des essais cliniques
  router.get('/trials', (Request request) async {
    try {
      final result = await Database.connection.execute(
        'SELECT * FROM trials ORDER BY created_at DESC LIMIT 50',
      );

      final trials = result.map((row) => Trial.fromMap(row.toColumnMap())).toList();

      return Response.ok(
        '{"trials": ${trials.map((t) => t.toJson())}}',
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: '{"error": "$e"}');
    }
  });

  return router;
}
