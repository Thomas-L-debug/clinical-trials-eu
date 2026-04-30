import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart' as cors;
import '../lib/router.dart';
import '../lib/database.dart';

void main() async {
  await Database.connect();

  final app = createRouter();

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(cors.corsHeaders())
      .addHandler(app.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8081');
  final server = await serve(handler, InternetAddress.anyIPv4, port);

  print('🚀 Backend Clinical Trials EU démarré sur http://0.0.0.0:$port');
  print('📊 Health   → http://localhost:$port/health');
  print('📊 Trials   → http://localhost:$port/trials');
}
