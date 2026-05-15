// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trial.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trial _$TrialFromJson(Map<String, dynamic> json) => Trial(
      id: json['id'] as String,
      title: json['title'] as String,
      titleFr: json['titleFr'] as String?,
      sponsor: json['sponsor'] as String?,
      sponsorCountry: json['sponsorCountry'] as String?,
      sponsorType: json['sponsorType'] as String?,
      phase: json['phase'] as String?,
      status: json['status'] as String,
      ctPublicStatusCode: (json['ctPublicStatusCode'] as num?)?.toInt(),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      decisionDate: json['decisionDate'] == null
          ? null
          : DateTime.parse(json['decisionDate'] as String),
      publishDate: json['publishDate'] == null
          ? null
          : DateTime.parse(json['publishDate'] as String),
      conditions: (json['conditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      therapeuticAreas: (json['therapeuticAreas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      interventions: (json['interventions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      countries: (json['countries'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      locations: (json['locations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      urlEuctr: json['urlEuctr'] as String?,
      urlCtis: json['urlCtis'] as String?,
      rawData: json['rawData'] as Map<String, dynamic>,
      vulgarizedSummary: json['vulgarizedSummary'] as String?,
      vulgarizedFr: json['vulgarizedFr'] as String?,
      lastFetchedAt: json['lastFetchedAt'] == null
          ? null
          : DateTime.parse(json['lastFetchedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TrialToJson(Trial instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'titleFr': instance.titleFr,
      'sponsor': instance.sponsor,
      'sponsorCountry': instance.sponsorCountry,
      'sponsorType': instance.sponsorType,
      'phase': instance.phase,
      'status': instance.status,
      'ctPublicStatusCode': instance.ctPublicStatusCode,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'decisionDate': instance.decisionDate?.toIso8601String(),
      'publishDate': instance.publishDate?.toIso8601String(),
      'conditions': instance.conditions,
      'therapeuticAreas': instance.therapeuticAreas,
      'interventions': instance.interventions,
      'countries': instance.countries,
      'locations': instance.locations,
      'urlEuctr': instance.urlEuctr,
      'urlCtis': instance.urlCtis,
      'rawData': instance.rawData,
      'vulgarizedSummary': instance.vulgarizedSummary,
      'vulgarizedFr': instance.vulgarizedFr,
      'lastFetchedAt': instance.lastFetchedAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
