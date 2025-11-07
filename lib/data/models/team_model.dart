import 'package:kl_teams/domain/entities/team.dart';

class TeamModel extends Team {
  const TeamModel({
    required super.id,
    required super.uuid,
    required super.slug,
    required super.name,
    super.abbr,
    required super.logoUrl,
    required super.city,
    required super.country,
    super.foundationYear,
    super.venue,
    required super.referenceId,
    required super.referenceUrl,
    required super.isQueensLeagueTeam,
    required super.leagueId,
    required super.leagueUuid,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      abbr: json['abbr'] as String?,
      logoUrl: json['logoUrl'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      foundationYear: json['foundationYear'] as int?,
      venue: json['venue'] as String?,
      referenceId: json['referenceId'] as int,
      referenceUrl: json['referenceUrl'] as String,
      isQueensLeagueTeam: json['isQueensLeagueTeam'] as bool,
      leagueId: json['leagueId'] as int,
      leagueUuid: json['leagueUuid'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'slug': slug,
      'name': name,
      'abbr': abbr,
      'logoUrl': logoUrl,
      'city': city,
      'country': country,
      'foundationYear': foundationYear,
      'venue': venue,
      'referenceId': referenceId,
      'referenceUrl': referenceUrl,
      'isQueensLeagueTeam': isQueensLeagueTeam,
      'leagueId': leagueId,
      'leagueUuid': leagueUuid,
    };
  }

  factory TeamModel.fromEntity(Team team) {
    return TeamModel(
      id: team.id,
      uuid: team.uuid,
      slug: team.slug,
      name: team.name,
      abbr: team.abbr,
      logoUrl: team.logoUrl,
      city: team.city,
      country: team.country,
      foundationYear: team.foundationYear,
      venue: team.venue,
      referenceId: team.referenceId,
      referenceUrl: team.referenceUrl,
      isQueensLeagueTeam: team.isQueensLeagueTeam,
      leagueId: team.leagueId,
      leagueUuid: team.leagueUuid,
    );
  }
}