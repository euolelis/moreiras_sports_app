import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Importe o Firebase Auth

// Importe os serviços e telas necessários
import '../core/services/auth_service.dart';
import '../features/auth/screens/admin_login_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart'; // 2. Importe a nova tela de dashboard

// 3. Crie este provider para observar o estado de autenticação em tempo real
final authStateProvider = StreamProvider<User?>((ref) {
  // Ele "escuta" as mudanças no serviço de autenticação
  return ref.watch(authServiceProvider).authStateChanges;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  // 4. Observa o estado de autenticação para usar nos redirecionamentos
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    
    // 5. Adicione o refreshListenable para que o router reavalie as rotas
    // quando o estado de login/logout mudar.
    refreshListenable: GoRouterRefreshStream(authState.stream),
    
    routes: [
      // Rota Pública
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(appBar: null, body: Center(child: Text("Home Screen"))), // Tela temporária
      ),
      // Rota de Login do Admin
      GoRoute(
        path: '/admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      
      // 6. --- ROTA PROTEGIDA (Admin) ---
      // Esta é a nova rota para o painel do admin
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],

    // 7. Lógica de redirecionamento para proteger as rotas
    redirect: (BuildContext context, GoRouterState state) {
      // Verifica se o usuário está logado (se existe um usuário no stream)
      final isLoggedIn = authState.value != null;
      
      // Verifica se a rota que o usuário está tentando acessar é a de login
      final isLoggingIn = state.matchedLocation == '/admin-login';
      
      // Verifica se a rota que o usuário está tentando acessar começa com '/admin'
      final isAdminRoute = state.matchedLocation.startsWith('/admin');

      // REGRA 1: Se o usuário NÃO está logado e tenta acessar uma rota de admin...
      if (!isLoggedIn && isAdminRoute) {
        // ...redireciona ele para a tela de login.
        return '/admin-login';
      }

      // REGRA 2: Se o usuário ESTÁ logado e tenta acessar a tela de login...
      if (isLoggedIn && isLoggingIn) {
        // ...redireciona ele para o painel, pois ele já está autenticado.
        return '/admin';
      }

      // Se nenhuma das regras acima se aplicar, não faz nenhum redirecionamento.
      return null;
    },

    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Página não encontrada: ${state.error}')),
    ),
  );
});

// 8. Classe auxiliar necessária para o refreshListenable funcionar com o Stream do Firebase
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}