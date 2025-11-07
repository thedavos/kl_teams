import 'package:go_router/go_router.dart';
import 'package:kl_teams/presentation/pages/home/home_page.dart';
import 'package:kl_teams/presentation/pages/preferences/preference_form_page.dart';
import 'package:kl_teams/presentation/pages/preferences/preferences_page.dart';
import 'package:kl_teams/presentation/pages/splash_page.dart';
import 'package:kl_teams/presentation/pages/team_detail/team_detail_page.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String apiList = '/api-list';
  static const String preferences = '/prefs';
  static const String preferenceNew = '/prefs/new';
  static const String preferenceDetail = '/prefs/:id';

  static GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: apiList,
        name: 'apiList',
        builder: (context, state) => const ApiListPage(),
      ),
      GoRoute(
        path: preferences,
        name: 'preferences',
        builder: (context, state) => const PreferencesListPage(),
      ),
      GoRoute(
        path: preferenceNew,
        name: 'preference-new',
        builder: (context, state) => const PreferenceFormPage(),
      ),
      GoRoute(
        path: preferenceDetail,
        name: 'preference-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TeamDetailPage(preferenceId: id);
        },
      ),
    ],
  );
}
