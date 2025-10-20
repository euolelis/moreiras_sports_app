import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/game_model.dart';
import '../core/models/sponsor_model.dart';
import '../core/services/auth_service.dart';
import '../features/about/screens/about_screen.dart';
import '../features/admin/screens/add_edit_category_screen.dart';
import '../features/admin/screens/add_edit_game_screen.dart';
import '../features/admin/screens/add_edit_news_screen.dart';
import '../features/admin/screens/add_edit_player_screen.dart';
import '../features/admin/screens/add_edit_sponsor_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/manage_categories_screen.dart';
import '../features/admin/screens/manage_game_details_screen.dart';
import '../features/admin/screens/manage_games_screen.dart';
import '../features/admin/screens/manage_news_screen.dart';
import '../features/admin/screens/manage_players_screen.dart';
import '../features/admin/screens/manage_sponsors_screen.dart';
import '../features/auth/screens/admin_login_screen.dart';
import '../features/auth/screens/landing_screen.dart';
import '../features/games/screens/game_detail_screen.dart';
import '../features/games/screens/games_list_screen.dart';
import '../features/home/screens/category_selection_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/news/screens/news_list_screen.dart';
import '../features/players/screens/player_detail_screen.dart';
import '../features/players/screens/player_list_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/sponsors/screens/sponsor_detail_screen.dart';
import '../features/sponsors/screens/sponsors_list_screen.dart';
import '../features/stats/screens/stats_screen.dart';
import '../shared/widgets/main_scaffold.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/select-category',
        builder: (context, state) => const CategorySelectionScreen(),
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
          ),
          GoRoute(
            path: '/games',
            builder: (context, state) => const GamesListScreen(),
            routes: [
              GoRoute(
                path: ':gameId',
                builder: (context, state) {
                  final game = state.extra as Game;
                  return GameDetailScreen(game: game);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/news',
            builder: (context, state) => const NewsListScreen(),
          ),
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: '/sponsors',
            builder: (context, state) => const SponsorsListScreen(),
            routes: [
              GoRoute(
                path: ':sponsorId',
                builder: (context, state) {
                  final sponsor = state.extra as Sponsor;
                  return SponsorDetailScreen(sponsor: sponsor);
                },
              ),
            ],
          ),
          // --- ROTA /about MOVIDA PARA DENTRO DO SHELLROUTE ---
          GoRoute(
            path: '/about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/players/:playerId',
        builder: (context, state) {
          final playerId = state.pathParameters['playerId']!;
          return PlayerDetailScreen(playerId: playerId);
        },
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
          GoRoute(path: 'manage-players', builder: (c, s) => const ManagePlayersScreen()),
          GoRoute(path: 'add-player', builder: (c, s) => const AddEditPlayerScreen()),
          GoRoute(path: 'edit-player/:playerId', builder: (c, s) {
            final playerId = s.pathParameters['playerId']!;
            return AddEditPlayerScreen(playerId: playerId);
          }),
          GoRoute(path: 'manage-games', builder: (c, s) => const ManageGamesScreen(), routes: [
            GoRoute(path: ':gameId', builder: (c, s) {
              final game = s.extra as Game;
              return ManageGameDetailsScreen(game: game);
            }),
          ]),
          GoRoute(path: 'add-game', builder: (c, s) => const AddEditGameScreen()),
          GoRoute(path: 'edit-game/:gameId', builder: (c, s) {
            final gameId = s.pathParameters['gameId']!;
            return AddEditGameScreen(gameId: gameId);
          }),
          GoRoute(path: 'manage-news', builder: (c, s) => const ManageNewsScreen()),
          GoRoute(path: 'add-news', builder: (c, s) => const AddEditNewsScreen()),
          GoRoute(path: 'edit-news/:newsId', builder: (c, s) {
            final newsId = s.pathParameters['newsId']!;
            return AddEditNewsScreen(newsId: newsId);
          }),
          GoRoute(path: 'manage-categories', builder: (c, s) => const ManageCategoriesScreen()),
          GoRoute(path: 'add-category', builder: (c, s) => const AddEditCategoryScreen()),
          GoRoute(path: 'edit-category/:categoryId', builder: (c, s) {
            final categoryId = s.pathParameters['categoryId']!;
            return AddEditCategoryScreen(categoryId: categoryId);
          }),
          GoRoute(path: 'manage-sponsors', builder: (c, s) => const ManageSponsorsScreen()),
          GoRoute(path: 'add-sponsor', builder: (c, s) => const AddEditSponsorScreen()),
          GoRoute(path: 'edit-sponsor/:sponsorId', builder: (c, s) {
            final sponsorId = s.pathParameters['sponsorId']!;
            return AddEditSponsorScreen(sponsorId: sponsorId);
          }),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Página não encontrada: ${state.error}')),
    ),
  );
});