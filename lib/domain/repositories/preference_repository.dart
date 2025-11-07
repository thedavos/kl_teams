import 'package:dartz/dartz.dart';
import 'package:kl_teams/core/errors/failures.dart';
import 'package:kl_teams/domain/entities/preference.dart';

abstract class PreferenceRepository {
  Future<Either<Failure, List<Preference>>> getAllPreferences();
  Future<Either<Failure, Preference>> getPreferenceById(String id);
  Future<Either<Failure, Preference>> savePreference(Preference preference);
  Future<Either<Failure, Preference>> updatePreference(Preference preference);
  Future<Either<Failure, void>> deletePreference(String id);
  Future<Either<Failure, bool>> preferenceExistsForTeam(int teamId);
}
