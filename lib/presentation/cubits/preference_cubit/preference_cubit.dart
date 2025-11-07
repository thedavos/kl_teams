import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kl_teams/domain/entities/preference.dart';
import 'package:kl_teams/domain/entities/team.dart';
import 'package:kl_teams/domain/repositories/preference_repository.dart';
import 'package:kl_teams/presentation/cubits/preference_cubit/preference_state.dart';

class PreferenceCubit extends Cubit<PreferenceState> {
  final PreferenceRepository preferenceRepository;

  PreferenceCubit({required this.preferenceRepository})
    : super(const PreferenceInitial());

  Future<void> getAllPreferences() async {
    emit(const PreferenceLoading());

    final result = await preferenceRepository.getAllPreferences();

    result.fold(
      (failure) => emit(PreferenceError(message: failure.message)),
      (preferences) => emit(PreferenceLoaded(preferences: preferences)),
    );
  }

  Future<void> getPreferenceById(String id) async {
    emit(const PreferenceLoading());

    final result = await preferenceRepository.getPreferenceById(id);

    result.fold(
      (failure) => emit(PreferenceError(message: failure.message)),
      (preference) => emit(PreferenceDetailLoaded(preference: preference)),
    );
  }

  Future<void> savePreferenceFromTeam({
    required Team team,
    required String customName,
  }) async {
    emit(const PreferenceActionLoading());

    final existsResult = await preferenceRepository.preferenceExistsForTeam(
      team.id,
    );

    final exists = existsResult.fold((failure) => false, (exists) => exists);

    if (exists) {
      emit(
        const PreferenceError(
          message: 'Este equipo ya está seleccionado como favorito'
        ),
      );
      return;
    }

    final preference = Preference(
      id: '', // Se generará en el datasource
      teamId: team.id,
      teamName: team.name,
      customName: customName,
      logoUrl: team.logoUrl,
      city: team.city,
      country: team.country,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await preferenceRepository.savePreference(preference);

    result.fold(
      (failure) => emit(PreferenceError(message: failure.message)),
      (savedPreference) => emit(
        PreferenceActionSuccess(
          message: 'Preferencia guardada exitosamente',
          preference: savedPreference,
        ),
      ),
    );
  }

  Future<void> updatePreference({
    required String id,
    required String newCustomName,
  }) async {
    emit(const PreferenceActionLoading());

    final getResult = await preferenceRepository.getPreferenceById(id);

    await getResult.fold(
      (failure) async {
        emit(PreferenceError(message: failure.message));
      },
      (currentPreference) async {
        final updatedPreference = Preference(
          id: currentPreference.id,
          teamId: currentPreference.teamId,
          teamName: currentPreference.teamName,
          customName: newCustomName,
          logoUrl: currentPreference.logoUrl,
          city: currentPreference.city,
          country: currentPreference.country,
          createdAt: currentPreference.createdAt,
          updatedAt: DateTime.now(),
        );

        final result = await preferenceRepository.updatePreference(
          updatedPreference,
        );

        result.fold(
          (failure) => emit(PreferenceError(message: failure.message)),
          (preference) => emit(
            PreferenceActionSuccess(
              message: 'Equipo favorito actualizado exitosamente',
              preference: preference,
            ),
          ),
        );
      },
    );
  }

  Future<void> deletePreference(String id) async {
    emit(const PreferenceActionLoading());

    final result = await preferenceRepository.deletePreference(id);

    result.fold(
      (failure) => emit(PreferenceError(message: failure.message)),
      (_) => emit(
        const PreferenceActionSuccess(
          message: 'Equipo favorito eliminado',
        ),
      ),
    );
  }

  Future<bool> checkPreferenceExistsForTeam(int teamId) async {
    final result = await preferenceRepository.preferenceExistsForTeam(teamId);

    return result.fold((failure) => false, (exists) => exists);
  }

  void resetToInitial() {
    emit(const PreferenceInitial());
  }
}
