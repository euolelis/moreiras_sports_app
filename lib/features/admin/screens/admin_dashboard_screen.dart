import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:go_router/go_router.dart';
    import '../../../core/services/auth_service.dart';

    class AdminDashboardScreen extends ConsumerWidget {
      const AdminDashboardScreen({super.key});

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Painel do Admin"),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                  // Após o logout, volta para a home
                  context.go('/');
                },
              )
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navegar para gerenciar jogadores
                  },
                  child: const Text('Gerenciar Jogadores'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Navegar para gerenciar jogos
                  },
                  child: const Text('Gerenciar Jogos'),
                ),
              ],
            ),
          ),
        );
      }
    }