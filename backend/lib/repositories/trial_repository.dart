// backend/lib/repositories/trial_repository.dart
import 'package:postgres/postgres.dart';
import '../database.dart';
import '../models/trial.dart';

class TrialRepository {
  Future<void> insertOrUpdate(Trial trial) async {
    final db = Database.connection!;

    const sql = '''
      INSERT INTO trials (
        id, title, title_fr, sponsor, sponsor_country, sponsor_type, phase, status,
        ct_public_status_code, start_date, end_date, decision_date, publish_date,
        conditions, therapeutic_areas, interventions, countries, locations,
        url_euctr, url_ctis, raw_data, vulgarized_summary, vulgarized_fr, last_fetched_at
      )
      VALUES (
        @id, @title, @title_fr, @sponsor, @sponsor_country, @sponsor_type, @phase, @status,
        @ct_public_status_code, @start_date, @end_date, @decision_date, @publish_date,
        @conditions, @therapeutic_areas, @interventions, @countries, @locations,
        @url_euctr, @url_ctis, @raw_data, @vulgarized_summary, @vulgarized_fr, @last_fetched_at
      )
      ON CONFLICT (id) DO UPDATE SET
        title = EXCLUDED.title,
        sponsor = EXCLUDED.sponsor,
        sponsor_country = EXCLUDED.sponsor_country,
        sponsor_type = EXCLUDED.sponsor_type,
        phase = EXCLUDED.phase,
        status = EXCLUDED.status,
        ct_public_status_code = EXCLUDED.ct_public_status_code,
        start_date = EXCLUDED.start_date,
        end_date = EXCLUDED.end_date,
        decision_date = EXCLUDED.decision_date,
        publish_date = EXCLUDED.publish_date,
        conditions = EXCLUDED.conditions,
        therapeutic_areas = EXCLUDED.therapeutic_areas,
        interventions = EXCLUDED.interventions,
        countries = EXCLUDED.countries,
        locations = EXCLUDED.locations,
        url_ctis = EXCLUDED.url_ctis,
        raw_data = EXCLUDED.raw_data,
        last_fetched_at = EXCLUDED.last_fetched_at,
        updated_at = NOW()
    ''';

    await db.execute(Sql.named(sql), parameters: {
      'id': trial.id,
      'title': trial.title,
      'title_fr': trial.titleFr,
      'sponsor': trial.sponsor,
      'sponsor_country': trial.sponsorCountry,
      'sponsor_type': trial.sponsorType,
      'phase': trial.phase,
      'status': trial.status,
      'ct_public_status_code': trial.ctPublicStatusCode,
      'start_date': trial.startDate,
      'end_date': trial.endDate,
      'decision_date': trial.decisionDate,
      'publish_date': trial.publishDate,
      'conditions': trial.conditions,
      'therapeutic_areas': trial.therapeuticAreas,
      'interventions': trial.interventions,
      'countries': trial.countries,
      'locations': trial.locations,
      'url_euctr': trial.urlEuctr,
      'url_ctis': trial.urlCtis,
      'raw_data': trial.rawData,
      'vulgarized_summary': trial.vulgarizedSummary,
      'vulgarized_fr': trial.vulgarizedFr,
      'last_fetched_at': trial.lastFetchedAt,
    });
  }

  // === Lecture ===
  Future<List<Trial>> getAll({int limit = 20}) async {
    final db = Database.connection!;
    final result = await db.execute(
      r'SELECT * FROM trials ORDER BY decision_date DESC NULLS LAST, created_at DESC LIMIT $1',
      parameters: [limit],
    );
    return result.map((row) => Trial.fromMap(row.toColumnMap())).toList();
  }

  Future<List<Trial>> searchAndGet({
    String search = '',
    int limit = 20,
    int offset = 0,
  }) async {
    final db = Database.connection!;
    String sql = 'SELECT * FROM trials WHERE 1=1';
    final params = <String, dynamic>{};

    if (search.isNotEmpty) {
      sql += '''
        AND (
          title ILIKE @search 
          OR conditions::text ILIKE @search 
          OR sponsor ILIKE @search
        )
      ''';
      params['search'] = '%$search%';
    }

    sql += ' ORDER BY decision_date DESC NULLS LAST, created_at DESC LIMIT @limit OFFSET @offset';
    params['limit'] = limit;
    params['offset'] = offset;

    final result = await db.execute(
      Sql.named(sql),
      parameters: params,
    );

    return result.map((row) => Trial.fromMap(row.toColumnMap())).toList();
  }

  Future<int> count({String search = ''}) async {
    final db = Database.connection!;
    String sql = 'SELECT COUNT(*) FROM trials WHERE 1=1';
    final params = <String, dynamic>{};

    if (search.isNotEmpty) {
      sql += ' AND (title ILIKE @search OR conditions::text ILIKE @search OR sponsor ILIKE @search)';
      params['search'] = '%$search%';
    }

    final result = await db.execute(
      Sql.named(sql),
      parameters: params,
    );

    return result.first[0] as int;
  }
}