import 'package:dartz/dartz.dart';
import 'package:kl_teams/core/errors/exceptions.dart';
import 'package:kl_teams/core/errors/failures.dart';
import 'package:kl_teams/data/datasources/preference_local_datasource.dart';
import 'package:kl_teams/data/models/preference_model.dart';
import 'package:kl_teams/domain/entities/preference.dart';
import 'package:kl_teams/domain/repositories/preference_repository.dart';

class PreferenceRepositoryImpl implements PreferenceRepository {
  final PreferenceLocalDataSource localDataSource;

  PreferenceRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Preference>>> getAllPreferences() async {
    try {
      final preferences = await localDataSource.getAllPreferences();
      return Right(preferences.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Preference>> getPreferenceById(String id) async {
    try {
      final preference = await localDataSource.getPreferenceById(id);
      return Right(preference.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Preference>> savePreference(
    Preference preference,
  ) async {
    try {
      final model = PreferenceModel.fromEntity(preference);
      final savedModel = await localDataSource.savePreference(model);
      return Right(savedModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Preference>> updatePreference(
    Preference preference,
  ) async {
    try {
      final model = PreferenceModel.fromEntity(preference);
      final updatedModel = await localDataSource.updatePreference(model);
      return Right(updatedModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePreference(String id) async {
    try {
      await localDataSource.deletePreference(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> preferenceExistsForTeam(int teamId) async {
    try {
      final exists = await localDataSource.preferenceExistsForTeam(teamId);
      return Right(exists);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: ${e.toString()}'));
    }
  }
}
