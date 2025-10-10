import 'package:flutter/material.dart';
    import 'package:go_router/go_router.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';

    // Vamos criar essas telas nos próximos passos
    // import '../features/home/screens/home_screen.dart';
    // import '../features/auth/screens/admin_login_screen.dart';

    final goRouterProvider = Provider<GoRouter>((ref) {
      return GoRouter(
        initialLocation: '/',
        routes: [
          // Rota Pública
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(appBar: null, body: Center(child: Text("Home Screen"))), // Tela temporária
          ),
          // Rota de Login do Admin
          GoRoute(
            path: '/admin-login',
            builder: (context, state) => const Scaffold(appBar: null, body: Center(child: Text("Admin Login Screen"))), // Tela temporária
          ),
        ],
        errorBuilder: (context, state) => Scaffold(
          body: Center(child: Text('Página não encontrada: ${state.error}')),
        ),
      );
    });