import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:go_router/go_router.dart';
    import '../../../core/models/player_model.dart';
    import '../../../core/services/firestore_service.dart';

    // Provider que "ouve" o stream de jogadores do Firestore
    final playersStreamProvider = StreamProvider.autoDispose<List<Player>>((ref) {
      return ref.watch(firestoreServiceProvider).getPlayersStream();
    });

    class ManagePlayersScreen extends ConsumerWidget {
      const ManagePlayersScreen({super.key});

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final playersAsyncValue = ref.watch(playersStreamProvider);

        return Scaffold(
          appBar: AppBar(
            title: const Text("Gerenciar Elenco"),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  // Navega para a tela de adicionar jogador
                  context.go('/admin/add-player');
                },
              ),
            ],
          ),
          body: playersAsyncValue.when(
            data: (players) {
              if (players.isEmpty) {
                return const Center(
                  child: Text("Nenhum jogador cadastrado. Clique em '+' para adicionar."),
                );
              }
              return ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(player.number.toString()),
                    ),
                    title: Text(player.name),
                    subtitle: Text(player.position),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // Navega para a tela de edição, passando o ID do jogador
                        context.go('/admin/edit-player/${player.id}');
                      },
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