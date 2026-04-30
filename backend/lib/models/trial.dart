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
  });

  factory Trial.fromMap(Map<String, dynamic> map) {
    return Trial(
      id: map['id'],
      title: map['title'],
      titleFr: map['title_fr'],
      sponsor: map['sponsor'],
      phase: map['phase'],
      status: map['status'],
      startDate: map['start_date'] != null ? DateTime.parse(map['start_date'].toString()) : null,
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date'].toString()) : null,
      conditions: List<String>.from(map['conditions'] ?? []),
      interventions: List<String>.from(map['interventions'] ?? []),
      locations: List<String>.from(map['locations'] ?? []),
      urlEuctr: map['url_euctr'],
      urlCtis: map['url_ctis'],
      vulgarizedSummary: map['vulgarized_summary'],
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
