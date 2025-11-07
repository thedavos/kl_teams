import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kl_teams/core/router/app_router.dart';
import 'package:kl_teams/domain/entities/preference.dart';
import 'package:kl_teams/presentation/cubits/preference_cubit/preference_cubit.dart';
import 'package:kl_teams/presentation/cubits/preference_cubit/preference_state.dart';
import 'package:kl_teams/presentation/widgets/common/empty_state_widget.dart';
import 'package:kl_teams/presentation/widgets/common/error_widget.dart';
import 'package:kl_teams/presentation/widgets/common/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PreferencesListPage extends StatefulWidget {
  const PreferencesListPage({super.key});

  @override
  State<PreferencesListPage> createState() => _PreferencesListPageState();
}

class _PreferencesListPageState extends State<PreferencesListPage> {
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    context.read<PreferenceCubit>().getAllPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Equipos Favoritos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.apiList),
        ),
      ),
      body: BlocConsumer<PreferenceCubit, PreferenceState>(
        listener: (context, state) {
          if (state is PreferenceActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            _loadPreferences();
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
        builder: (context, state) {
          if (state is PreferenceLoading) {
            return const LoadingWidget(message: 'Cargando equipos favoritos...');
          }

          if (state is PreferenceError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: _loadPreferences,
            );
          }

          if (state is PreferenceLoaded) {
            if (state.preferences.isEmpty) {
              return EmptyStateWidget(
                message: 'No tienes favoritos guardadas',
                icon: Icons.favorite_border,
                actionText: 'Agregar favorito',
                onAction: () => context.push(AppRouter.preferenceNew),
              );
            }

            return _buildPreferencesList(state.preferences);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRouter.preferenceNew),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo equipo favorito'),
      ),
    );
  }

  Widget _buildPreferencesList(List<Preference> preferences) {
    return RefreshIndicator(
      onRefresh: () async => _loadPreferences(),
      child: ListView.builder(
        itemCount: preferences.length,
        padding: const EdgeInsets.only(bottom: 80),
        itemBuilder: (context, index) {
          final preference = preferences[index];
          return _buildPreferenceCard(preference);
        },
      ),
    );
  }

  Widget _buildPreferenceCard(Preference preference) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => context.push(
          AppRouter.preferenceDetail.replaceAll(':id', preference.id),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Logo del equipo
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: preference.logoUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.sports_soccer),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preference.customName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preference.teamName,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${preference.city}, ${preference.country}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                onPressed: () => _showDeleteDialog(preference),
                tooltip: 'Eliminar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Preference preference) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar equipo favorito'),
        content: Text('¿Estás seguro de eliminar "${preference.customName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PreferenceCubit>().deletePreference(preference.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
