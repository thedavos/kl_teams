import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kl_teams/core/router/app_router.dart';
import 'package:kl_teams/presentation/cubits/api_cubit/api_cubit.dart';
import 'package:kl_teams/presentation/cubits/api_cubit/api_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int _retries = 0;
  final int _maxRetries = 5;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApiCubit>().getTeams();
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _scheduleRetry() {
    if (_retries >= _maxRetries) return;

    _retries++;
    final delays = [2, 4, 8, 16, 30];
    final seconds = delays[(_retries - 1).clamp(0, delays.length - 1)];

    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: seconds), () {
      if (!mounted) return;
      context.read<ApiCubit>().getTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApiCubit, ApiState>(
      listener: (context, state) {
        if (state is ApiLoaded) {
          _retryTimer?.cancel();
          if (!mounted) return;
          context.go(AppRouter.apiList);
        } else if (state is ApiError) {
          if (_retries < _maxRetries) {
            _scheduleRetry();
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'No se pudo conectar. Revisa tu red e inténtalo de nuevo.',
                  ),
                ),
              );
            }
          }
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Cargando equipos...'),
            ],
          ),
        ),
      ),
    );
  }
}
