import 'package:dartz/dartz.dart';
import 'package:kl_teams/core/errors/exceptions.dart';
import 'package:kl_teams/core/errors/failures.dart';
import 'package:kl_teams/data/datasources/team_datasource.dart';
import 'package:kl_teams/domain/entities/team.dart';
import 'package:kl_teams/domain/repositories/team_repository.dart';

class TeamRepositoryImpl implements TeamRepository {
  final TeamDataSource dataSource;

  TeamRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<Team>>> getTeams() async {
    try {
      final teams = await dataSource.getTeams();
      return Right(teams);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: ${e.toString()}'));
    }
  }
}