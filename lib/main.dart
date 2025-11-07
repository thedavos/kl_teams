import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kl_teams/core/injection/injection_container.dart';
import 'package:kl_teams/core/router/app_router.dart';
import 'package:kl_teams/presentation/cubits/api_cubit/api_cubit.dart';
import 'package:kl_teams/presentation/cubits/preference_cubit/preference_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ApiCubit>()),
        BlocProvider(create: (_) => sl<PreferenceCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Kings League App',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),
      ),
    );
  }
}
