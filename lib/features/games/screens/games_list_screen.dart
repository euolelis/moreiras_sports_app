import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/game_model.dart';
import '../../../core/services/firestore_service.dart';

// Provider para buscar o stream de jogos
final gamesStreamProvider = StreamProvider.autoDispose<List<Game>>((ref) {
  return ref.watch(firestoreServiceProvider).getGamesStream();
});

class GamesListScreen extends ConsumerWidget {
  const GamesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsyncValue = ref.watch(gamesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("CALENDÁRIO DE JOGOS"),
        centerTitle: true,
      ),
      body: gamesAsyncValue.when(
        data: (games) {
          if (games.isEmpty) {
            return const Center(child: Text("Nenhum jogo agendado."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    "Moreira's Sports x ${game.opponent}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(game.championship),
                      const SizedBox(height: 4),
                      Text(DateFormat('dd/MM/yyyy \'às\' HH:mm').format(game.gameDate)),
                    ],
                  ),
                  trailing: _buildScore(context, game),
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

  // Widget auxiliar para mostrar o placar ou o status
  Widget _buildScore(BuildContext context, Game game) {
    if (game.status == 'Encerrado' && game.ourScore != null) {
      return Text(
        '${game.ourScore} x ${game.opponentScore}',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      );
    }
    return Chip(
      label: Text(game.status),
      backgroundColor: Colors.grey[300],
    );
  }
}