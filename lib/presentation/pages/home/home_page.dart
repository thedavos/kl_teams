import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kl_teams/core/router/app_router.dart';
import 'package:kl_teams/domain/entities/team.dart';
import 'package:kl_teams/presentation/cubits/api_cubit/api_cubit.dart';
import 'package:kl_teams/presentation/cubits/api_cubit/api_state.dart';
import 'package:kl_teams/presentation/cubits/preference_cubit/preference_cubit.dart';
import 'package:kl_teams/presentation/widgets/common/error_widget.dart';
import 'package:kl_teams/presentation/widgets/common/loading_widget.dart';
import 'package:kl_teams/presentation/widgets/common/empty_state_widget.dart';
import 'package:kl_teams/presentation/widgets/team_card/team_card.dart';

class ApiListPage extends StatefulWidget {
  const ApiListPage({super.key});

  @override
  State<ApiListPage> createState() => _ApiListPageState();
}

class _ApiListPageState extends State<ApiListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ApiCubit>().getTeams();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kings League Teams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => context.push(AppRouter.preferences),
            tooltip: 'Mis Preferencias',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<ApiCubit, ApiState>(
              builder: (context, state) {
                if (state is ApiLoading) {
                  return const LoadingWidget(message: 'Cargando equipos...');
                }

                if (state is ApiError) {
                  return ErrorDisplayWidget(
                    message: state.message,
                    onRetry: () => context.read<ApiCubit>().retry(),
                  );
                }

                if (state is ApiLoaded) {
                  if (state.filteredTeams.isEmpty) {
                    return EmptyStateWidget(
                      message: state.searchQuery.isEmpty
                          ? 'No hay equipos disponibles'
                          : 'No se encontraron equipos para "${state.searchQuery}"',
                      icon: Icons.search_off,
                      actionText: state.searchQuery.isNotEmpty
                          ? 'Limpiar búsqueda'
                          : null,
                      onAction: state.searchQuery.isNotEmpty
                          ? () {
                              _searchController.clear();
                              context.read<ApiCubit>().clearSearch();
                            }
                          : null,
                    );
                  }

                  return _buildTeamsList(state.filteredTeams);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRouter.preferenceNew),
        icon: const Icon(Icons.add),
        label: const Text('Agregar equipo favorito'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar equipos...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<ApiCubit>().clearSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          context.read<ApiCubit>().searchTeams(value);
        },
      ),
    );
  }

  Widget _buildTeamsList(List<Team> teams) {
    return RefreshIndicator(
      onRefresh: () => context.read<ApiCubit>().getTeams(),
      child: ListView.builder(
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          return TeamCard(
            team: team,
            onTap: () => _showTeamDetailsDialog(context, team),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.blue,
              onPressed: () => _showAddPreferenceDialog(context, team),
              tooltip: 'Agregar a favoritos',
            ),
          );
        },
      ),
    );
  }

  void _showTeamDetailsDialog(BuildContext context, Team team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(team.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Image.network(
                  team.logoUrl,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.sports_soccer, size: 100),
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Ciudad', team.city),
              _buildDetailRow('País', team.country),
              _buildDetailRow('Slug', team.slug),
              _buildDetailRow('League ID', team.leagueId.toString()),
              _buildDetailRow(
                'Queens League',
                team.isQueensLeagueTeam ? 'Sí' : 'No',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddPreferenceDialog(BuildContext context, Team team) {
    final customNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Agregar a Favoritos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Equipo: ${team.name}'),
            const SizedBox(height: 16),
            TextField(
              controller: customNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre personalizado',
                hintText: 'Mi equipo favorito',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final customName = customNameController.text.trim();
              if (customName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor ingresa un nombre personalizado'),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);

              context.read<PreferenceCubit>().savePreferenceFromTeam(
                team: team,
                customName: customName,
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
