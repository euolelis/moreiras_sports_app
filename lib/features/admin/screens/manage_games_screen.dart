import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/game_model.dart';
import '../../../core/services/firestore_service.dart';

final gamesStreamProvider = StreamProvider.autoDispose<List<Game>>((ref) {
  return ref.watch(firestoreServiceProvider).getGamesStream();
});

class ManageGamesScreen extends ConsumerWidget {
  const ManageGamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsyncValue = ref.watch(gamesStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Jogos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/admin/add-game'),
          ),
        ],
      ),
      body: gamesAsyncValue.when(
        data: (games) {
          if (games.isEmpty) {
            return const Center(child: Text("Nenhum jogo cadastrado."));
          }
          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return ListTile(
                title: Text('${game.opponent} (${game.championship})'),
                subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(game.gameDate)),
                onTap: () {
                  // Navegar para a tela de detalhes do jogo (onde se lançam os eventos)
                  context.go('/admin/manage-games/${game.id}', extra: game);
                },
                // Adiciona um botão de edição
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(game.status),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Editar Jogo',
                      onPressed: () {
                        // Navegar para a tela de edição do formulário
                        context.go('/admin/edit-game/${game.id}');
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Ocorreu um erro: $err")),
      ),
    );
  }
}