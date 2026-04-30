import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String ctisSearchUrl = 'https://euclinicaltrials.eu/ctis-public-api/search';

Future<void> main() async {
  print('🚀 Récupération des essais cliniques CTIS...');

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
      
      final trials = data['data'] ?? [];
      final pagination = data['pagination'] ?? {};
      final totalRecords = pagination['totalRecords'] ?? 0;
      final totalPages = pagination['totalPages'] ?? 0;

      print('✅ ${trials.length} essais récupérés sur cette page');
      print('📊 Total dans la base CTIS : $totalRecords essais');
      print('📄 Pages totales : $totalPages');

      // Affichage du premier essai
      if (trials.isNotEmpty) {
        print('\n📋 Premier essai :');
        print(const JsonEncoder.withIndent('  ').convert(trials.first));
      }

      // Sauvegarde
      final dataDir = Directory('data');
      await dataDir.create(recursive: true);
      
      final file = File('data/ctis_trials_page1.json');
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(data)
      );
      print('💾 Fichier sauvegardé → ${file.absolute.path}');

    } else {
      print('❌ Erreur HTTP ${response.statusCode}');
      print(response.body);
    }
  } catch (e, stack) {
    print('❌ Exception: $e');
    print(stack);
  }
}