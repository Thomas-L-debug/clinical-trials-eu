// backend/lib/router.dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'repositories/trial_repository.dart';
import 'models/trial.dart';

class AppRouter {
  final TrialRepository _repo = TrialRepository();
  final Router _router = Router();

  AppRouter() {
    _router.get('/', _homeHandler);
    _router.get('/trials', _trialsHandler);
    _router.get('/api/stats', _statsHandler);
  }

  Router get router => _router;

  // ====================== PAGE D'ACCUEIL HTML ======================
  Future<Response> _homeHandler(Request req) async {
    try {
      final search = req.url.queryParameters['search']?.trim() ?? '';
      final limit = int.tryParse(req.url.queryParameters['limit'] ?? '20') ?? 20;
      final offset = int.tryParse(req.url.queryParameters['offset'] ?? '0') ?? 0;

      final trials = await _repo.searchAndGet(
        search: search,
        limit: limit,
        offset: offset,
      );
      final total = await _repo.count(search: search);

      final html = '''
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Essais Cliniques EU • ${total} essais</title>
  <style>
    body { font-family: system-ui, sans-serif; margin:0; background:#f8f9fa; }
    header { background:#1a73e8; color:white; padding:2rem; text-align:center; }
    .container { max-width:1200px; margin:2rem auto; padding:0 1rem; }
    .search-bar { width:100%; max-width:700px; padding:14px; font-size:1.1rem; border:1px solid #ddd; border-radius:8px; margin-bottom:1.5rem; }
    table { width:100%; border-collapse:collapse; background:white; border-radius:12px; overflow:hidden; box-shadow:0 2px 10px rgba(0,0,0,0.1); }
    th, td { padding:14px; text-align:left; border-bottom:1px solid #eee; }
    th { background:#f1f3f4; }
    tr:hover { background:#f8f9fa; }
    .pagination { margin-top:2rem; text-align:center; }
    .status { padding:4px 12px; border-radius:9999px; font-size:0.85rem; background:#e8f0fe; }
  </style>
</head>
<body>
  <header>
    <h1>Essais Cliniques Européens</h1>
    <p>${total} essais trouvés</p>
  </header>
  <div class="container">
    <input type="text" id="searchInput" class="search-bar" 
           placeholder="Rechercher par titre, maladie, sponsor..." 
           value="$search" onkeypress="if(event.key==='Enter') doSearch()">

    <table>
      <thead>
        <tr>
          <th>Titre</th>
          <th>Phase</th>
          <th>Statut</th>
          <th>Pays</th>
          <th>Date</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody>
        ${trials.map((t) => '''
          <tr>
            <td><strong>${t.title}</strong></td>
            <td>${t.phase ?? '-'}</td>
            <td><span class="status">${t.status}</span></td>
            <td>${t.countries.take(3).join(', ')}</td>
            <td>${t.decisionDate?.toString().split(' ')[0] ?? '-'}</td>
            <td><a href="${t.urlCtis ?? '#'}" target="_blank">🔗 CTIS</a></td>
          </tr>
        ''').join('')}
      </tbody>
    </table>

    <div class="pagination">
      ${offset > 0 ? '<a href="?offset=${offset-limit}&limit=$limit&search=$search">← Précédent</a>' : ''}
      <span>Page ${(offset/limit).floor() + 1}</span>
      ${(offset + limit < total) ? '<a href="?offset=${offset+limit}&limit=$limit&search=$search">Suivant →</a>' : ''}
    </div>
  </div>

  <script>
    function doSearch() {
      const q = document.getElementById('searchInput').value.trim();
      window.location.href = `/?search=\${encodeURIComponent(q)}`;
    }
  </script>
</body>
</html>
''';

      return Response.ok(html, headers: {'Content-Type': 'text/html; charset=utf-8'});
    } catch (e, stack) {
      print('❌ Erreur _homeHandler: $e');
      print(stack);
      return Response.internalServerError(body: 'Erreur serveur');
    }
  }

  // ====================== API JSON ======================
  Future<Response> _trialsHandler(Request req) async {
    final limit = int.tryParse(req.url.queryParameters['limit'] ?? '50') ?? 50;
    final offset = int.tryParse(req.url.queryParameters['offset'] ?? '0') ?? 0;

    final trials = await _repo.getAll(limit: limit);
    final total = await _repo.count();

    final response = {
      'total': total,
      'limit': limit,
      'offset': offset,
      'trials': trials.map((t) => t.toJson()).toList(),
    };

    return Response.ok(
      jsonEncode(response),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _statsHandler(Request req) async {
    final total = await _repo.count();
    return Response.ok(jsonEncode({'total_trials': total}));
  }
}