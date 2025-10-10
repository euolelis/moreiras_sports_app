import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports das telas e serviços
import '../core/services/auth_service.dart';
import '../features/auth/screens/admin_login_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/manage_players_screen.dart';
import '../features/admin/screens/add_edit_player_screen.dart';

// Imports para o ShellRoute
import '../shared/widgets/main_scaffold.dart';
import '../features/home/screens/home_screen.dart';
import '../features/players/screens/player_list_screen.dart';
import '../features/players/screens/player_detail_screen.dart';
// --- NOVO IMPORT PARA A SPLASH SCREEN ---
import '../features/splash/screens/splash_screen.dart';


// Provider que expõe o estado de autenticação (sem alterações)
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash', // <-- MUDANÇA AQUI
    refreshListenable: GoRouterRefreshStream(ref.watch(authStateProvider.stream)),

    routes: [
      // --- ROTA DA SPLASH SCREEN ---
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // --- ROTAS PÚBLICAS DENTRO DO SHELL ---
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
        ],
      ),

      // --- ROTAS FORA DO SHELL (TELA CHEIA) ---
      GoRoute(
        path: '/admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
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
        ],
      ),
    ],
    
    // A lógica de redirect continua exatamente a mesma
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

    // O errorBuilder continua o mesmo
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Página não encontrada: ${state.error}')),
    ),
  );
});

// Classe auxiliar para o refreshListenable (sem alterações)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}