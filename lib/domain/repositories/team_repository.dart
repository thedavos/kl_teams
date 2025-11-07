import 'package:dartz/dartz.dart';
import 'package:kl_teams/core/errors/failures.dart';
import 'package:kl_teams/domain/entities/team.dart';

abstract class TeamRepository {
  Future<Either<Failure, List<Team>>> getTeams();
}