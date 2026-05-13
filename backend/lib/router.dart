import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'database.dart';
import 'models/trial.dart';

Router createRouter() {
  final router = Router();

  // ====================== HEALTH ======================
  router.get('/health', (Request request) {
    return Response.ok('{"status": "healthy", "service": "clinical-trials-eu"}',
        headers: {'Content-Type': 'application/json'});
  });

  // ====================== PAGE D'ACCUEIL HTML ======================
  router.get('/', (Request request) async {
    try {
      final countResult = await Database.connection.execute('SELECT COUNT(*) FROM trials');
      final total = countResult.first.first as int;

      final result = await Database.connection.execute(
        'SELECT * FROM trials ORDER BY updated_at DESC LIMIT 20',
      );

      final trials = result.map((row) => Trial.fromMap(row.toColumnMap())).toList();

      final html = '''
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Essais Cliniques EU - Backend</title>
  <style>
    body { font-family: system-ui, sans-serif; margin: 40px; background: #f8f9fa; }
    h1 { color: #1a73e8; }
    .card { background: white; padding: 20px; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); margin-bottom: 20px; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
    th { background: #f1f3f4; }
    .badge { padding: 4px 10px; border-radius: 9999px; font-size: 0.85em; }
    .refresh { padding: 10px 20px; background: #1a73e8; color: white; border: none; border-radius: 8px; cursor: pointer; }
  </style>
</head>
<body>
  <h1>📊 Essais Cliniques Européens</h1>
  <div class="card">
    <p><strong>Total d'essais stockés :</strong> $total</p>
    <button class="refresh" onclick="window.location.reload()">🔄 Rafraîchir</button>
    <a href="/trials" style="margin-left: 10px; text-decoration: none;">Voir tout en JSON →</a>
  </div>

  <h2>Derniers essais</h2>
  <table>
    <thead>
      <tr><th>ID</th><th>Titre</th><th>Phase</th><th>Statut</th><th>Vulgarisé ?</th></tr>
    </thead>
    <tbody>
      ${trials.map((t) => '''
        <tr>
          <td>${t.id}</td>
          <td>${t.title.length > 80 ? '${t.title.substring(0, 77)}...' : t.title}</td>
          <td>${t.phase ?? '-'}</td>
          <td><span class="badge" style="background:${t.status == 'Recruiting' ? '#34a853' : '#fbbc04'};">${t.status ?? '-'}</span></td>
          <td>${t.vulgarizedSummary != null ? '✅' : '❌'}</td>
        </tr>
      ''').join()}
    </tbody>
  </table>

  <p style="margin-top: 30px; color: #666;">
    Backend Shelf • Port 8081 • <a href="/health">Health check</a>
  </p>
</body>
</html>
''';

      return Response.ok(html, headers: {'Content-Type': 'text/html; charset=utf-8'});
    } catch (e) {
      return Response.internalServerError(body: 'Erreur : $e');
    }
  });

  // ====================== JSON API ======================
  router.get('/trials', (Request request) async {
    try {
      final result = await Database.connection.execute(
        'SELECT * FROM trials ORDER BY updated_at DESC LIMIT 50',
      );
      final trials = result.map((row) => Trial.fromMap(row.toColumnMap())).toList();

      return Response.ok(
        '{"total": ${trials.length}, "trials": ${trials.map((t) => t.toJson())}}',
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: '{"error": "$e"}');
    }
  });

  return router;
}