import 'package:equatable/equatable.dart';

class Preference extends Equatable {
  final String id;
  final int teamId;
  final String teamName;
  final String customName;
  final String logoUrl;
  final String city;
  final String country;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Preference({
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

  @override
  List<Object?> get props => [
    id,
    teamId,
    teamName,
    customName,
    logoUrl,
    city,
    country,
    createdAt,
    updatedAt,
  ];
}