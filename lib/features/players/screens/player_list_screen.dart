import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import '../../../core/models/player_model.dart';
    import '../../../core/services/firestore_service.dart';
    import '../widgets/player_list_card.dart'; // Vamos criar este widget

    // Reutilizamos o mesmo provider da tela de admin!
    final playersStreamProvider = StreamProvider.autoDispose<List<Player>>((ref) {
      return ref.watch(firestoreServiceProvider).getPlayersStream();
    });

    class PlayerListScreen extends ConsumerWidget {
      const PlayerListScreen({super.key});

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final playersAsyncValue = ref.watch(playersStreamProvider);

        return Scaffold(
          appBar: AppBar(
            title: const Text("MOREIRA'S ELENCO"),
            centerTitle: true,
          ),
          body: playersAsyncValue.when(
            data: (players) {
              if (players.isEmpty) {
                return const Center(child: Text("Elenco ainda não cadastrado."));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return PlayerListCard(player: player);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Ocorreu um erro: $err")),
          ),
        );
      }
    }