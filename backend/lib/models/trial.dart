class Trial {
  final String id;
  final String title;
  final String? titleFr;
  final String? sponsor;
  final String? phase;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> conditions;
  final List<String> interventions;
  final List<String> locations;
  final String? urlEuctr;
  final String? urlCtis;
  final String? vulgarizedSummary;
  final Map<String, dynamic>? rawData;   // ← on garde tout le JSON si besoin

  Trial({
    required this.id,
    required this.title,
    this.titleFr,
    this.sponsor,
    this.phase,
    this.status,
    this.startDate,
    this.endDate,
    this.conditions = const [],
    this.interventions = const [],
    this.locations = const [],
    this.urlEuctr,
    this.urlCtis,
    this.vulgarizedSummary,
    this.rawData,
  });

  // Mapping depuis le JSON CTIS
  factory Trial.fromCtisJson(Map<String, dynamic> json) {
    final countries = (json['trialCountries'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return Trial(
      id: json['ctNumber'] ?? 'unknown-${DateTime.now().millisecondsSinceEpoch}',
      title: json['ctTitle'] ?? '',
      titleFr: null,                    // pas toujours dispo
      sponsor: json['sponsor'],
      phase: json['trialPhase'],
      status: _mapStatus(json['ctStatus']),   // on convertit le numéro en texte
      startDate: null,                      // pas dans ce JSON pour l'instant
      endDate: null,
      conditions: [json['conditions']?.toString() ?? ''],
      interventions: json['product'] != null 
          ? [json['product'].toString()] 
          : [],
      locations: countries,
      urlCtis: json['ctNumber'] != null 
          ? 'https://euclinicaltrials.eu/ctis-public/search/#/?number=${json['ctNumber']}' 
          : null,
      rawData: json,
    );
  }

  static String? _mapStatus(int? code) {
    const statusMap = {
      2: 'Recruiting',
      11: 'Completed',
      // ajoute d'autres codes si tu veux (tu peux les voir dans les logs)
    };
    return statusMap[code] ?? 'Unknown';
  }

  factory Trial.fromMap(Map<String, dynamic> map) {
    return Trial(
      id: map['id'],
      title: map['title'],
      titleFr: map['title_fr'],
      sponsor: map['sponsor'],
      phase: map['phase'],
      status: map['status'],
      startDate: map['start_date'] != null ? DateTime.tryParse(map['start_date'].toString()) : null,
      endDate: map['end_date'] != null ? DateTime.tryParse(map['end_date'].toString()) : null,
      conditions: List<String>.from(map['conditions'] ?? []),
      interventions: List<String>.from(map['interventions'] ?? []),
      locations: List<String>.from(map['locations'] ?? []),
      urlEuctr: map['url_euctr'],
      urlCtis: map['url_ctis'],
      vulgarizedSummary: map['vulgarized_summary'],
      rawData: map['raw_data'] is Map ? map['raw_data'] : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'titleFr': titleFr,
        'sponsor': sponsor,
        'phase': phase,
        'status': status,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'conditions': conditions,
        'interventions': interventions,
        'locations': locations,
        'urlEuctr': urlEuctr,
        'urlCtis': urlCtis,
        'vulgarizedSummary': vulgarizedSummary,
      };
}