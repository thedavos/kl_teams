import 'package:hive/hive.dart';
import 'package:kl_teams/domain/entities/preference.dart';

part 'preference_model.g.dart';

@HiveType(typeId: 0)
class PreferenceModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int teamId;

  @HiveField(2)
  final String teamName;

  @HiveField(3)
  final String customName;

  @HiveField(4)
  final String logoUrl;

  @HiveField(5)
  final String city;

  @HiveField(6)
  final String country;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  PreferenceModel({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.customName,
    required this.logoUrl,
    required this.city,
    required this.country,
    required this.createdAt,
    required this.updatedAt,
  });

  // Conversión a Entity
  Preference toEntity() {
    return Preference(
      id: id,
      teamId: teamId,
      teamName: teamName,
      customName: customName,
      logoUrl: logoUrl,
      city: city,
      country: country,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Conversión desde Entity
  factory PreferenceModel.fromEntity(Preference preference) {
    return PreferenceModel(
      id: preference.id,
      teamId: preference.teamId,
      teamName: preference.teamName,
      customName: preference.customName,
      logoUrl: preference.logoUrl,
      city: preference.city,
      country: preference.country,
      createdAt: preference.createdAt,
      updatedAt: preference.updatedAt,
    );
  }

  // Conversión a Map (útil para debugging)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teamId': teamId,
      'teamName': teamName,
      'customName': customName,
      'logoUrl': logoUrl,
      'city': city,
      'country': country,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Método para actualizar
  PreferenceModel copyWith({
    String? customName,
    DateTime? updatedAt,
  }) {
    return PreferenceModel(
      id: id,
      teamId: teamId,
      teamName: teamName,
      customName: customName ?? this.customName,
      logoUrl: logoUrl,
      city: city,
      country: country,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}