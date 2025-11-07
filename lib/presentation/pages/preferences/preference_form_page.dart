import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kl_teams/core/router/app_router.dart';
import 'package:kl_teams/domain/entities/team.dart';
import 'package:kl_teams/presentation/cubits/api_cubit/api_cubit.dart';
import 'package:kl_teams/presentation/cubits/api_cubit/api_state.dart';
import 'package:kl_teams/presentation/cubits/preference_cubit/preference_cubit.dart';
import 'package:kl_teams/presentation/cubits/preference_cubit/preference_state.dart';
import 'package:kl_teams/presentation/widgets/common/error_widget.dart';
import 'package:kl_teams/presentation/widgets/common/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PreferenceFormPage extends StatefulWidget {
  const PreferenceFormPage({super.key});

  @override
  State<PreferenceFormPage> createState() => _PreferenceFormPageState();
}

class _PreferenceFormPageState extends State<PreferenceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _customNameController = TextEditingController();
  Team? _selectedTeam;

  @override
  void initState() {
    super.initState();
    // Cargar equipos si no están cargados
    final apiState = context.read<ApiCubit>().state;
    if (apiState is! ApiLoaded) {
      context.read<ApiCubit>().getTeams();
    }
  }

  @override
  void dispose() {
    _customNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Preferencia'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<PreferenceCubit, PreferenceState>(
        listener: (context, state) {
          if (state is PreferenceActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            // Navegar a la lista de preferencias
            context.go(AppRouter.preferences);
          }

          if (state is PreferenceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, preferenceState) {
          if (preferenceState is PreferenceActionLoading) {
            return const LoadingWidget(message: 'Guardando preferencia...');
          }

          return BlocBuilder<ApiCubit, ApiState>(
            builder: (context, apiState) {
              if (apiState is ApiLoading) {
                return const LoadingWidget(message: 'Cargando equipos...');
              }

              if (apiState is ApiError) {
                return ErrorDisplayWidget(
                  message: apiState.message,
                  onRetry: () => context.read<ApiCubit>().retry(),
                );
              }

              if (apiState is ApiLoaded) {
                return _buildForm(apiState.teams);
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildForm(List<Team> teams) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selector de equipo
            Text(
              'Selecciona un equipo',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTeamSelector(teams),
            const SizedBox(height: 24),

            // Campo de nombre personalizado
            Text(
              'Nombre personalizado',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _customNameController,
              decoration: InputDecoration(
                hintText: 'Mi equipo favorito',
                prefixIcon: const Icon(Icons.edit),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un nombre personalizado';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _savePreference,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSelector(List<Team> teams) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: InkWell(
        onTap: () => _showTeamSelectionDialog(teams),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _selectedTeam == null
              ? Row(
                  children: [
                    Icon(Icons.sports_soccer, color: Colors.grey[600]),
                    const SizedBox(width: 16),
                    Text(
                      'Toca para seleccionar un equipo',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                )
              : Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: _selectedTeam!.logoUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.sports_soccer, size: 50),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedTeam!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${_selectedTeam!.city}, ${_selectedTeam!.country}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
        ),
      ),
    );
  }

  void _showTeamSelectionDialog(List<Team> teams) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Selecciona un equipo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  final team = teams[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: team.logoUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.sports_soccer),
                      ),
                    ),
                    title: Text(team.name),
                    subtitle: Text('${team.city}, ${team.country}'),
                    selected: _selectedTeam?.id == team.id,
                    onTap: () {
                      setState(() {
                        _selectedTeam = team;
                      });
                      Navigator.pop(dialogContext);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _savePreference() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un equipo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Verificar si ya existe una preferencia para este equipo
    final exists = await context
        .read<PreferenceCubit>()
        .checkPreferenceExistsForTeam(_selectedTeam!.id);

    if (!mounted) return;

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya existe una preferencia para este equipo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<PreferenceCubit>().savePreferenceFromTeam(
      team: _selectedTeam!,
      customName: _customNameController.text.trim(),
    );
  }
}
