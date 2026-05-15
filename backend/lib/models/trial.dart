// backend/lib/models/trial.dart
class Trial {
  final String id;
  final String title;
  String? titleFr;
  final String? sponsor;
  final String? sponsorCountry;
  final String? sponsorType;
  final String? phase;
  final String status;
  final int? ctPublicStatusCode;

  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? decisionDate;
  final DateTime? publishDate;

  final List<String> conditions;
  final List<String> therapeuticAreas;
  final List<String> interventions;
  final List<String> countries;
  final List<String> locations;

  final String? urlEuctr;
  final String? urlCtis;

  final Map<String, dynamic> rawData;
  String? vulgarizedSummary;
  String? vulgarizedFr;

  final DateTime lastFetchedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Trial({
    required this.id,
    required this.title,
    this.titleFr,
    this.sponsor,
    this.sponsorCountry,
    this.sponsorType,
    this.phase,
    required this.status,
    this.ctPublicStatusCode,
    this.startDate,
    this.endDate,
    this.decisionDate,
    this.publishDate,
    this.conditions = const [],
    this.therapeuticAreas = const [],
    this.interventions = const [],
    this.countries = const [],
    this.locations = const [],
    this.urlEuctr,
    this.urlCtis,
    required this.rawData,
    this.vulgarizedSummary,
    this.vulgarizedFr,
    DateTime? lastFetchedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : lastFetchedAt = lastFetchedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Trial.fromCtisJson(Map<String, dynamic> json) {
    return Trial(
      id: json['ctNumber'] as String,
      title: (json['ctTitle'] as String? ?? json['shortTitle'] as String? ?? 'Sans titre').trim(),
      sponsor: json['sponsor'] as String?,
      sponsorType: json['sponsorType'] as String?,
      sponsorCountry: null, // on peut le remplir plus tard via le détail
      phase: json['trialPhase'] as String?,
      status: json['ctStatus'] is int 
          ? _mapStatusCode(json['ctStatus'] as int) 
          : (json['ctStatus'] as String? ?? 'Unknown'),
      ctPublicStatusCode: json['ctPublicStatusCode'] as int?,

      decisionDate: _parseDate(json['decisionDateOverall'] ?? json['decisionDate']),
      publishDate: _parseDate(json['publishDate'] ?? json['lastPublicationUpdate']),
      startDate: _parseDate(json['startDateOverall']),
      endDate: _parseDate(json['endDateOverall']),

      conditions: _toStringList(json['conditions'] ?? json['medicalConditions']),
      therapeuticAreas: _toStringList(json['therapeuticAreas']),
      interventions: _toStringList(json['product'] ?? json['interventions']),
      countries: _extractCountries(json['trialCountries']),
      locations: _toStringList(json['locations']),

      rawData: json,
      lastFetchedAt: DateTime.now(),

      urlCtis: 'https://euclinicaltrials.eu/ctis-public/search/#/?number=${json['ctNumber']}',
    );
  }

  factory Trial.fromMap(Map<String, dynamic> map) {
    return Trial(
      id: map['id'] as String,
      title: map['title'] as String,
      titleFr: map['title_fr'] as String?,
      sponsor: map['sponsor'] as String?,
      sponsorCountry: map['sponsor_country'] as String?,
      sponsorType: map['sponsor_type'] as String?,
      phase: map['phase'] as String?,
      status: map['status'] as String,
      ctPublicStatusCode: map['ct_public_status_code'] as int?,
      startDate: map['start_date'] as DateTime?,
      endDate: map['end_date'] as DateTime?,
      decisionDate: map['decision_date'] as DateTime?,
      publishDate: map['publish_date'] as DateTime?,
      conditions: (map['conditions'] as List<dynamic>?)?.cast<String>() ?? [],
      therapeuticAreas: (map['therapeutic_areas'] as List<dynamic>?)?.cast<String>() ?? [],
      interventions: (map['interventions'] as List<dynamic>?)?.cast<String>() ?? [],
      countries: (map['countries'] as List<dynamic>?)?.cast<String>() ?? [],
      locations: (map['locations'] as List<dynamic>?)?.cast<String>() ?? [],
      urlEuctr: map['url_euctr'] as String?,
      urlCtis: map['url_ctis'] as String?,
      rawData: map['raw_data'] as Map<String, dynamic>? ?? {},
      vulgarizedSummary: map['vulgarized_summary'] as String?,
      vulgarizedFr: map['vulgarized_fr'] as String?,
      lastFetchedAt: map['last_fetched_at'] as DateTime? ?? DateTime.now(),
      createdAt: map['created_at'] as DateTime? ?? DateTime.now(),
      updatedAt: map['updated_at'] as DateTime? ?? DateTime.now(),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is String) {
      try {
        final clean = v.split('T')[0].replaceAll('/', '-');
        return DateTime.parse(clean);
      } catch (_) {}
    }
    return null;
  }

  static String _mapStatusCode(int code) {
    const map = {
      1: 'Not authorised',
      2: 'Authorised',
      3: 'Withdrawn',
      4: 'Temporarily halted',
      5: 'Completed',
    };
    return map[code] ?? 'Status $code';
  }

  static List<String> _toStringList(dynamic v) {
    if (v == null) return [];
    if (v is List) {
      return v.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    if (v is String) return [v.trim()];
    return [];
  }

  static List<String> _extractCountries(dynamic v) {
    if (v == null || v is! List) return [];
    return v.map((e) => e.toString().split(':').first.trim()).toList();
  }

  // === Méthodes pour JSON / API ===
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_fr': titleFr,
      'sponsor': sponsor,
      'sponsor_country': sponsorCountry,
      'sponsor_type': sponsorType,
      'phase': phase,
      'status': status,
      'ct_public_status_code': ctPublicStatusCode,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'decision_date': decisionDate?.toIso8601String(),
      'publish_date': publishDate?.toIso8601String(),
      'conditions': conditions,
      'therapeutic_areas': therapeuticAreas,
      'interventions': interventions,
      'countries': countries,
      'locations': locations,
      'url_euctr': urlEuctr,
      'url_ctis': urlCtis,
      'vulgarized_summary': vulgarizedSummary,
      'vulgarized_fr': vulgarizedFr,
      'last_fetched_at': lastFetchedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      // raw_data trop lourd pour la liste → on le cache pour l'instant
    };
  }
}