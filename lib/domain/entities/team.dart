import 'package:equatable/equatable.dart';

class Team extends Equatable {
  final int id;
  final String uuid;
  final String slug;
  final String name;
  final String? abbr;
  final String logoUrl;
  final String city;
  final String country;
  final int? foundationYear;
  final String? venue;
  final int referenceId;
  final String referenceUrl;
  final bool isQueensLeagueTeam;
  final int leagueId;
  final String leagueUuid;

  const Team({
    required this.id,
    required this.uuid,
    required this.slug,
    required this.name,
    this.abbr,
    required this.logoUrl,
    required this.city,
    required this.country,
    this.foundationYear,
    this.venue,
    required this.referenceId,
    required this.referenceUrl,
    required this.isQueensLeagueTeam,
    required this.leagueId,
    required this.leagueUuid,
  });

  @override
  List<Object?> get props => [
    id,
    uuid,
    slug,
    name,
    abbr,
    logoUrl,
    city,
    country,
    foundationYear,
    venue,
    referenceId,
    referenceUrl,
    isQueensLeagueTeam,
    leagueId,
    leagueUuid,
  ];
}