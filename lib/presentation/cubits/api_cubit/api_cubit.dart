import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kl_teams/domain/repositories/team_repository.dart';
import 'package:kl_teams/presentation/cubits/api_cubit/api_state.dart';

class ApiCubit extends Cubit<ApiState> {
  final TeamRepository teamRepository;

  ApiCubit({required this.teamRepository}) : super(const ApiInitial());

  Future<void> getTeams() async {
    emit(const ApiLoading());

    final result = await teamRepository.getTeams();

    result.fold(
      (failure) => emit(ApiError(message: failure.message)),
      (teams) =>
          emit(ApiLoaded(teams: teams, filteredTeams: teams, searchQuery: '')),
    );
  }

  void searchTeams(String query) {
    final currentState = state;

    if (currentState is ApiLoaded) {
      if (query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredTeams: currentState.teams,
            searchQuery: '',
          ),
        );
      } else {
        final filtered = currentState.teams.where((team) {
          return team.name.toLowerCase().contains(query.toLowerCase()) ||
              team.city.toLowerCase().contains(query.toLowerCase()) ||
              team.country.toLowerCase().contains(query.toLowerCase());
        }).toList();

        emit(
          currentState.copyWith(filteredTeams: filtered, searchQuery: query),
        );
      }
    }
  }

  void clearSearch() {
    final currentState = state;

    if (currentState is ApiLoaded) {
      emit(
        currentState.copyWith(
          filteredTeams: currentState.teams,
          searchQuery: '',
        ),
      );
    }
  }

  Future<void> retry() async {
    await getTeams();
  }
}
