// backend/bin/fetch_ctis.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../lib/models/trial.dart';
import '../lib/repositories/trial_repository.dart';
import '../lib/database.dart';

const String ctisSearchUrl = 'https://euclinicaltrials.eu/ctis-public-api/search';
const int pageSize = 100;

Future<void> main(List<String> args) async {
  print('🚀 Fetch CTIS complet + incrémental...');
  await Database.connect();
  final repo = TrialRepository();

  bool fullSync = args.contains('--full');
  int maxPages = fullSync ? 9999 : 10;

  int page = 1;
  int totalInserted = 0;
  int totalSkipped = 0;

  while (page <= maxPages) {
    print('📄 Récupération page $page (size=$pageSize)...');

    final payload = {
      "pagination": {"page": page, "size": pageSize},
      "sort": {"property": "decisionDate", "direction": "DESC"},
      "searchCriteria": {}
    };

    try {
      final response = await http.post(
        Uri.parse(ctisSearchUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        print('❌ Erreur HTTP ${response.statusCode}');
        break;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final pagination = data['pagination'] as Map<String, dynamic>;
      final trialsJson = data['data'] as List<dynamic>? ?? [];

      print('   → ${trialsJson.length} essais reçus (totalPages: ${pagination['totalPages']})');

      for (var item in trialsJson) {
        try {
          final trial = Trial.fromCtisJson(item as Map<String, dynamic>);
          await repo.insertOrUpdate(trial);
          totalInserted++;
        } catch (e) {
          print('   ⚠️ Erreur mapping essai : $e');
          totalSkipped++;
        }
      }

      final hasMore = pagination['nextPage'] == true || page < (pagination['totalPages'] as num? ?? 1);
      if (!hasMore) {
        print('✅ Dernière page atteinte');
        break;
      }

      page++;
      await Future.delayed(const Duration(milliseconds: 400)); // politesse API

    } catch (e, stack) {
      print('❌ Erreur page $page: $e');
      print(stack);
      break;
    }
  }

  print('🎉 Sync terminée !');
  print('   ✅ Insérés/Mis à jour : $totalInserted');
  print('   ⚠️  Skippés : $totalSkipped');
}