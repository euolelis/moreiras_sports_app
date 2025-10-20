import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/player_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/providers/global_filter_provider.dart';
import '../../admin/screens/manage_categories_screen.dart';
import '../widgets/player_list_card.dart';

final allPlayersStreamProvider = StreamProvider.autoDispose<List<Player>>((ref) {
  return ref.watch(firestoreServiceProvider).getPlayersStream();
});

class PlayerListScreen extends ConsumerWidget {
  const PlayerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesStreamProvider);
    final playersAsyncValue = ref.watch(allPlayersStreamProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      // A AppBar foi removida daqui.
      body: categoriesAsyncValue.when(
        data: (allCategories) {
          return playersAsyncValue.when(
            data: (allPlayers) {
              final List<Category> categoriesToDisplay = selectedCategory == null
                  ? allCategories
                  : [selectedCategory];

              if (categoriesToDisplay.isEmpty) {
                return const Center(child: Text('Nenhuma categoria para exibir.'));
              }
              
              return ListView.builder(
                itemCount: categoriesToDisplay.length,
                itemBuilder: (context, index) {
                  final category = categoriesToDisplay[index];
                  
                  final playersInCategory = allPlayers.where((p) => p.categoryId == category.id).toList();

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ExpansionTile(
                      initiallyExpanded: selectedCategory != null,
                      title: Text(
                        category.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      children: playersInCategory.isNotEmpty
                          ? playersInCategory.map((player) {
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