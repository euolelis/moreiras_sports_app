import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/player_model.dart';
import '../../players/screens/player_list_screen.dart'; // Reutiliza o provider de jogadores
import '../../../core/providers/global_filter_provider.dart'; // Importa o filtro global

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsyncValue = ref.watch(allPlayersStreamProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider); // Ouve o filtro global

    return DefaultTabController(
      length: 3, // Número de abas: Artilharia, Assistências, Cartões
      child: Scaffold(
        // O AppBar foi removido, pois será gerenciado pelo MainScaffold
        // A TabBar será adicionada ao CustomAppBar no próximo passo.
        body: playersAsyncValue.when(
          data: (players) {
            // Filtra os jogadores ANTES de criar os rankings
            final filteredPlayers = selectedCategory == null
                ? players
                : players.where((p) => p.categoryId == selectedCategory.id).toList();

            // O TabBarView agora usa a lista de jogadores já filtrada
            return TabBarView(
              children: [
                // Aba de Artilharia
                _buildRankingList(
                  players: filteredPlayers,
                  valueExtractor: (p) => p.goals,
                  label: 'Gols',
                ),
                // Aba de Assistências
                _buildRankingList(
                  players: filteredPlayers,
                  valueExtractor: (p) => p.assists,
                  label: 'Assist.',
                ),
                // Aba de Cartões
                _buildRankingList(
                  players: filteredPlayers,
                  valueExtractor: (p) => p.yellowCards + p.redCards,
                  label: 'Cartões',
                  subtitleExtractor: (p) => '${p.yellowCards}A / ${p.redCards}V',
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Erro ao carregar jogadores: $e')),
        ),
      ),
    );
  }

  // Widget auxiliar para construir as listas de ranking
  Widget _buildRankingList({
    required List<Player> players,
    required int Function(Player) valueExtractor,
    required String label,
    String Function(Player)? subtitleExtractor,
  }) {
    final rankedPlayers = players.where((p) => valueExtractor(p) > 0).toList()
      ..sort((a, b) => valueExtractor(b).compareTo(valueExtractor(a)));

    if (rankedPlayers.isEmpty) {
      return const Center(child: Text('Nenhum dado para exibir nesta categoria.'));
    }

    return ListView.builder(
      itemCount: rankedPlayers.length,
      itemBuilder: (context, index) {
        final player = rankedPlayers[index];
        return ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(player.name),
          subtitle: Text(subtitleExtractor != null ? subtitleExtractor(player) : player.position),
          trailing: Text(
            '${valueExtractor(player)} $label',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
      },
    );
  }
}