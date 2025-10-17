import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/player_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../admin/screens/manage_categories_screen.dart'; // Provider de categorias
import '../widgets/player_list_card.dart';

// Provider que busca TODOS os jogadores
final allPlayersStreamProvider = StreamProvider.autoDispose<List<Player>>((ref) {
  return ref.watch(firestoreServiceProvider).getPlayersStream();
});

class PlayerListScreen extends ConsumerWidget {
  const PlayerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assiste aos dois streams: categorias e jogadores
    final categoriesAsyncValue = ref.watch(categoriesStreamProvider);
    final playersAsyncValue = ref.watch(allPlayersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("MOREIRA'S ELENCO"),
        centerTitle: true,
      ),
      body: categoriesAsyncValue.when(
        data: (categories) {
          return playersAsyncValue.when(
            data: (players) {
              if (categories.isEmpty) {
                return const Center(child: Text('Nenhuma categoria cadastrada.'));
              }
              // Usa um ListView para as categorias
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  
                  // Filtra a lista de jogadores para encontrar apenas os desta categoria
                  final playersInCategory = players.where((p) => p.categoryId == category.id).toList();

                  // Cria um ExpansionTile para cada categoria
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ExpansionTile(
                      title: Text(
                        category.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      children: playersInCategory.isNotEmpty
                          ? playersInCategory.map((player) {
                              // Reutiliza o PlayerListCard que já criamos
                              return PlayerListCard(player: player);
                            }).toList()
                          : [
                              const ListTile(
                                title: Text(
                                  'Nenhum jogador nesta categoria.',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              )
                            ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Erro ao carregar jogadores: $err")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Erro ao carregar categorias: $err")),
      ),
    );
  }
}