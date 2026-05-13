import 'package:postgres/postgres.dart';
import '../models/trial.dart';
import '../database.dart';

class TrialRepository {
  Future<void> insertOrUpdate(Trial trial) async {
    await Database.connection.execute(
      Sql.named('''
        INSERT INTO trials (
          id, title, title_fr, sponsor, phase, status, 
          start_date, end_date, conditions, interventions, 
          locations, url_euctr, url_ctis, raw_data, vulgarized_summary, updated_at
        ) VALUES (
          @id, @title, @title_fr, @sponsor, @phase, @status,
          @start_date, @end_date, @conditions, @interventions,
          @locations, @url_euctr, @url_ctis, @raw_data, @vulgarized_summary, NOW()
        )
        ON CONFLICT (id) DO UPDATE SET
          title = EXCLUDED.title,
          title_fr = EXCLUDED.title_fr,
          sponsor = EXCLUDED.sponsor,
          phase = EXCLUDED.phase,
          status = EXCLUDED.status,
          start_date = EXCLUDED.start_date,
          end_date = EXCLUDED.end_date,
          conditions = EXCLUDED.conditions,
          interventions = EXCLUDED.interventions,
          locations = EXCLUDED.locations,
          url_euctr = EXCLUDED.url_euctr,
          url_ctis = EXCLUDED.url_ctis,
          raw_data = EXCLUDED.raw_data,
          vulgarized_summary = EXCLUDED.vulgarized_summary,
          updated_at = NOW()
      '''),
      parameters: {
        'id': trial.id,
        'title': trial.title,
        'title_fr': trial.titleFr,
        'sponsor': trial.sponsor,
        'phase': trial.phase,
        'status': trial.status,
        'start_date': trial.startDate,
        'end_date': trial.endDate,
        'conditions': trial.conditions,
        'interventions': trial.interventions,
        'locations': trial.locations,
        'url_euctr': trial.urlEuctr,
        'url_ctis': trial.urlCtis,
        'raw_data': trial.rawData,
        'vulgarized_summary': trial.vulgarizedSummary,
      },
    );
  }
}