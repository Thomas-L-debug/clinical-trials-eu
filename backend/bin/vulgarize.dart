import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';

import '../lib/database.dart';

String buildPrompt(Map<String, dynamic> trial) {
  final title = trial['title'] ?? '';
  final phase = trial['phase'] ?? 'Non disponible';
  final status = trial['status'] ?? 'Non disponible';
  final conditions = trial['conditions'] ?? 'Non disponible';
  final therapeuticAreas = trial['therapeutic_areas'] ?? 'Non disponible';
  final interventions = trial['interventions'] ?? 'Non disponible';
  final sponsor = trial['sponsor'] ?? 'Non disponible';

  return '''
Tu es un vulgarisateur médical **très prudent** pour le grand public francophone.

RÈGLES ABSOLUES :
- Réponds **EXCLUSIVEMENT** avec un JSON valide, rien d'autre.
- Ne fais **aucune promesse** de bénéfice, d'amélioration ou de résultat.
- Utilise toujours des formules prudentes : "cet essai étudie...", "cherche à évaluer...", "il n'est pas possible de garantir...".
- Phrases courtes et simples.

Données de l’essai :
- Titre : $title
- Phase : $phase
- Statut : $status
- Conditions : $conditions
- Domaines : $therapeuticAreas
- Interventions : $interventions
- Sponsor : $sponsor

Réponds uniquement avec ce JSON :
{
  "intro": "2-4 phrases simples expliquant de quoi parle l'essai",
  "objective": "Objectif principal",
  "who_can_participate": "Qui peut participer ? (critères principaux)",
  "participation_involves": "Ce que participer implique concrètement (durée, visites, examens, contraintes)",
  "current_status": "Où en est l'essai aujourd'hui",
  "key_points": ["point prudent 1", "point prudent 2"],
  "legal_note": "Ce résumé est informatif uniquement et ne remplace pas un avis médical."
}
''';
}


Future<String> callOllama(String prompt) async {
  final url = Uri.parse('http://ollama:11434/api/generate');

  final body = jsonEncode({
    'model': 'llama3.1:8b',
    'prompt': prompt,
    'stream': false,
    'options': {
      'temperature': 0.15,
      'num_predict': 1400,
      'top_p': 0.92,
    },
  });

  try {
    final response = await http
        .post(url, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(const Duration(seconds: 200));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['response'] as String? ?? '').trim();
    } else {
      print('⚠️ Ollama HTTP ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Erreur Ollama : $e');
  }
  return '';
}

Future<void> main() async {
  final stopwatch = Stopwatch()..start();

  print('🚀 Vulgarisation LLM - Batch JSON structuré\n');

  await Database.connect();
  final connection = Database.connection;

  final result = await connection.execute(
    Sql.named('''
      SELECT id, title, phase, status, conditions, therapeutic_areas, 
             interventions, sponsor
      FROM trials
      WHERE vulgarized_fr IS NULL OR vulgarized_fr = ''
      ORDER BY id ASC
      LIMIT 20
    '''),
  );

  final total = result.length;
  print('📦 $total essais à vulgariser dans ce batch\n');

  int success = 0;
  int processed = 0;

  for (final row in result) {
    final trial = row.toColumnMap();
    final id = trial['id'];
    processed++;

    print('[$processed/$total] → Traitement de l’essai #$id ...');

    final prompt = buildPrompt(trial);
    final jsonResponse = await callOllama(prompt);

    if (jsonResponse.isNotEmpty) {
      await connection.execute(
        Sql.named('''
          UPDATE trials 
          SET vulgarized_fr = @content,
              updated_at = NOW()
          WHERE id = @id
        '''),
        parameters: {'content': jsonResponse, 'id': id},
      );
      success++;
      print('   ✅ #$id vulgarisé avec succès');
    } else {
      print('   ⚠️ #$id ignoré (réponse vide)');
    }

    await Future.delayed(const Duration(milliseconds: 800));
  }

  stopwatch.stop();   // ← Fin du timer

  final duration = stopwatch.elapsed;
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;

  print('\n🎉 Batch terminé !');
  print('   $success / $total essais vulgarisés avec succès');
  print('   ⏱️  Temps total : ${minutes}min ${seconds}s');
  print('   ⏱️  Moyenne par essai : ${(duration.inMilliseconds / total).round()} ms');

  exit(0);
}

