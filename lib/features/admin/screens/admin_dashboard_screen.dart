import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:go_router/go_router.dart'; // Garanta que este import está aqui
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
                    // Esta é a linha chave. Ela navega para a sub-rota.
                    context.go('/admin/manage-players');
                  },
                  child: const Text('Gerenciar Jogadores'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Ação para gerenciar jogos (futuro)
                  },
                  child: const Text('Gerenciar Jogos'),
                ),
              ],
            ),
          ),
        );
      }
    }