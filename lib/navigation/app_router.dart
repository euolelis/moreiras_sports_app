import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/game_model.dart';
import '../core/services/auth_service.dart';
import '../features/admin/screens/add_edit_category_screen.dart';
import '../features/admin/screens/add_edit_game_screen.dart';
import '../features/admin/screens/add_edit_news_screen.dart';
import '../features/admin/screens/add_edit_player_screen.dart';
import '../features/admin/screens/add_edit_sponsor_screen.dart'; // Novo import
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/manage_categories_screen.dart';
import '../features/admin/screens/manage_game_details_screen.dart';
import '../features/admin/screens/manage_games_screen.dart';
import '../features/admin/screens/manage_news_screen.dart';
import '../features/admin/screens/manage_players_screen.dart';
import '../features/admin/screens/manage_sponsors_screen.dart'; // Novo import
import '../features/auth/screens/admin_login_screen.dart';
import '../features/auth/screens/landing_screen.dart';
import '../features/games/screens/games_list_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/news/screens/news_list_screen.dart';
import '../features/players/screens/player_detail_screen.dart';
import '../features/players/screens/player_list_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/sponsors/screens/sponsors_screen.dart'; // Novo import
import '../features/stats/screens/stats_screen.dart';
import '../shared/widgets/main_scaffold.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(ref.watch(authStateProvider.stream)),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/players',
            builder: (context, state) => const PlayerListScreen(),
            routes: [
              GoRoute(
                path: ':playerId',
                builder: (context, state) {
                  final playerId = state.pathParameters['playerId']!;
                  return PlayerDetailScreen(playerId: playerId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/games',
            builder: (context, state) => const GamesListScreen(),
          ),
          GoRoute(
            path: '/news',
            builder: (context, state) => const NewsListScreen(),
          ),
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatsScreen(),
          ),
          // Nova rota pública de patrocinadores
          GoRoute(
            path: '/sponsors',
            builder: (context, state) => const SponsorsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) {
          String? message;
          if (state.extra is String) {
            message = state.extra as String?;
          }
          return AdminDashboardScreen(message: message);
        },
        routes: [
          // Players
          GoRoute(
            path: 'manage-players',
            builder: (context, state) => const ManagePlayersScreen(),
          ),
          GoRoute(
            path: 'add-player',
            builder: (context, state) => const AddEditPlayerScreen(),
          ),
          GoRoute(
            path: 'edit-player/:playerId',
            builder: (context, state) {
              final playerId = state.pathParameters['playerId']!;
              return AddEditPlayerScreen(playerId: playerId);
            },
          ),
          // Games
          GoRoute(
            path: 'manage-games',
            builder: (context, state) => const ManageGamesScreen(),
            routes: [
              GoRoute(
                path: ':gameId',
                builder: (context, state) {
                  final game = state.extra as Game;
                  return ManageGameDetailsScreen(game: game);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'add-game',
            builder: (context, state) => const AddEditGameScreen(),
          ),
          GoRoute(
            path: 'edit-game/:gameId',
            builder: (context, state) {
              final gameId = state.pathParameters['gameId']!;
              return AddEditGameScreen(gameId: gameId);
            },
          ),
          // News
          GoRoute(
            path: 'manage-news',
            builder: (context, state) => const ManageNewsScreen(),
          ),
          GoRoute(
            path: 'add-news',
            builder: (context, state) => const AddEditNewsScreen(),
          ),
          // Categories
          GoRoute(
            path: 'manage-categories',
            builder: (context, state) => const ManageCategoriesScreen(),
          ),
          GoRoute(
            path: 'add-category',
            builder: (context, state) => const AddEditCategoryScreen(),
          ),
          // Novas rotas de admin para patrocinadores
          GoRoute(
            path: 'manage-sponsors',
            builder: (context, state) => const ManageSponsorsScreen(),
          ),
          GoRoute(
            path: 'add-sponsor',
            builder: (context, state) => const AddEditSponsorScreen(),
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/admin-login';
      final isAdminRoute = state.matchedLocation.startsWith('/admin');

      if (!isLoggedIn && isAdminRoute) {
        return '/admin-login';
      }
      if (isLoggedIn && isLoggingIn) {
        return '/admin';
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Página não encontrada: ${state.error}')),
    ),
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}