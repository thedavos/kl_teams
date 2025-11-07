import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kl_teams/core/router/app_router.dart';
import 'package:kl_teams/domain/entities/preference.dart';
import 'package:kl_teams/presentation/cubits/preference_cubit/preference_cubit.dart';
import 'package:kl_teams/presentation/cubits/preference_cubit/preference_state.dart';
import 'package:kl_teams/presentation/widgets/common/error_widget.dart';
import 'package:kl_teams/presentation/widgets/common/loading_widget.dart';

class TeamDetailPage extends StatefulWidget {
  final String preferenceId;

  const TeamDetailPage({super.key, required this.preferenceId});

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  void _loadPreference() {
    context.read<PreferenceCubit>().getPreferenceById(widget.preferenceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de mi equipo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.preferences),
        ),
        actions: [
          BlocBuilder<PreferenceCubit, PreferenceState>(
            builder: (context, state) {
              if (state is PreferenceDetailLoaded) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDialog(state.preference);
                    } else if (value == 'delete') {
                      _showDeleteDialog(state.preference);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<PreferenceCubit, PreferenceState>(
        listener: (context, state) {
          if (state is PreferenceActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));

            // Si se eliminó, volver a la lista
            if (state.message.contains('eliminada')) {
              context.go(AppRouter.preferences);
            } else {
              // Si se editó, recargar el detalle
              _loadPreference();
            }
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
          if (state is PreferenceLoading || state is PreferenceActionLoading) {
            return const LoadingWidget(message: 'Cargando detalle...');
          }

          if (state is PreferenceError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: _loadPreference,
            );
          }

          if (state is PreferenceDetailLoaded) {
            return _buildDetailContent(state.preference);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<PreferenceCubit, PreferenceState>(
        builder: (context, state) {
          if (state is PreferenceDetailLoaded) {
            return FloatingActionButton.extended(
              onPressed: () => _showEditDialog(state.preference),
              icon: const Icon(Icons.edit),
              label: const Text('Editar'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetailContent(Preference preference) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo del equipo
          Center(
            child: Hero(
              tag: 'team-logo-${preference.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: preference.logoUrl,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.sports_soccer, size: 80),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Nombre personalizado
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mi nombre personalizado',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    preference.customName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Información del equipo
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del equipo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.sports_soccer,
                    'Nombre',
                    preference.teamName,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.location_city, 'Ciudad', preference.city),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.flag, 'País', preference.country),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.tag,
                    'Team ID',
                    preference.teamId.toString(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Fechas
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fechas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Creado',
                    dateFormat.format(preference.createdAt),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.update,
                    'Última actualización',
                    dateFormat.format(preference.updatedAt),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80), // Espacio para el FAB
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditDialog(Preference preference) {
    final controller = TextEditingController(text: preference.customName);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar Nombre Personalizado'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre personalizado',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('El nombre no puede estar vacío'),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);

              context.read<PreferenceCubit>().updatePreference(
                id: preference.id,
                newCustomName: newName,
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Preference preference) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar equipo'),
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
