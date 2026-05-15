// backend/bin/server.dart
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import '../lib/router.dart';
import '../lib/database.dart';

Future<void> main() async {
  // Connexion DB obligatoire avant de démarrer le serveur
  await Database.connect();

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final appRouter = AppRouter();

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(appRouter.router.call);

  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('🚀 Serveur démarré sur http://0.0.0.0:$port');
  print('📊 Page d\'accueil : http://localhost:$port/');
  print('📡 API JSON     : http://localhost:$port/trials');
}