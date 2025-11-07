import 'package:equatable/equatable.dart';
import 'package:kl_teams/domain/entities/team.dart';

abstract class ApiState extends Equatable {
  const ApiState();

  @override
  List<Object?> get props => [];
}

class ApiInitial extends ApiState {
  const ApiInitial();
}

class ApiLoading extends ApiState {
  const ApiLoading();
}

class ApiLoaded extends ApiState {
  final List<Team> teams;
  final List<Team> filteredTeams;
  final String searchQuery;

  const ApiLoaded({
    required this.teams,
    required this.filteredTeams,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [teams, filteredTeams, searchQuery];

  ApiLoaded copyWith({
    List<Team>? teams,
    List<Team>? filteredTeams,
    String? searchQuery,
  }) {
    return ApiLoaded(
      teams: teams ?? this.teams,
      filteredTeams: filteredTeams ?? this.filteredTeams,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ApiError extends ApiState {
  final String message;

  const ApiError({required this.message});

  @override
  List<Object?> get props => [message];
}
