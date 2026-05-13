import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../lib/models/trial.dart';
import '../lib/repositories/trial_repository.dart';
import '../lib/database.dart';

const String ctisSearchUrl = 'https://euclinicaltrials.eu/ctis-public-api/search';

Future<void> main() async {
  print('🚀 Récupération des essais cliniques CTIS...');

  await Database.connect();           // connexion DB
  final repo = TrialRepository();

  final Map<String, dynamic> payload = {
    "pagination": {"page": 1, "size": 50},
    "sort": {"property": "decisionDate", "direction": "DESC"},
    "searchCriteria": {}
  };

  try {
    final response = await http.post(
      Uri.parse(ctisSearchUrl),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final trialsJson = data['data'] as List<dynamic>? ?? [];

      print('✅ ${trialsJson.length} essais récupérés sur cette page');

      int inserted = 0;
      for (var item in trialsJson) {
        final trial = Trial.fromCtisJson(item as Map<String, dynamic>);
        await repo.insertOrUpdate(trial);
        inserted++;
      }

      print('💾 $inserted essais insérés / mis à jour dans PostgreSQL');

      // Sauvegarde JSON (tu peux garder ça pour debug)
      final dataDir = Directory('data');
      await dataDir.create(recursive: true);
      final file = File('data/ctis_trials_page1.json');
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
      print('💾 Fichier sauvegardé → ${file.absolute.path}');
    } else {
      print('❌ Erreur HTTP ${response.statusCode}');
    }
  } catch (e, stack) {
    print('❌ Exception: $e');
    print(stack);
  }
}