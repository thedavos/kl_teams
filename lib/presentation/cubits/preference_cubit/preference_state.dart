import 'package:equatable/equatable.dart';
import 'package:kl_teams/domain/entities/preference.dart';

abstract class PreferenceState extends Equatable {
  const PreferenceState();

  @override
  List<Object?> get props => [];
}

class PreferenceInitial extends PreferenceState {
  const PreferenceInitial();
}

class PreferenceLoading extends PreferenceState {
  const PreferenceLoading();
}

class PreferenceActionLoading extends PreferenceState {
  const PreferenceActionLoading();
}

class PreferenceLoaded extends PreferenceState {
  final List<Preference> preferences;

  const PreferenceLoaded({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

class PreferenceDetailLoaded extends PreferenceState {
  final Preference preference;

  const PreferenceDetailLoaded({required this.preference});

  @override
  List<Object?> get props => [preference];
}

class PreferenceActionSuccess extends PreferenceState {
  final String message;
  final Preference? preference;

  const PreferenceActionSuccess({required this.message, this.preference});

  @override
  List<Object?> get props => [message, preference];
}

class PreferenceError extends PreferenceState {
  final String message;

  const PreferenceError({required this.message});

  @override
  List<Object?> get props => [message];
}
