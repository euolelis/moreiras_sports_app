import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/player_model.dart';
import '../../admin/screens/manage_categories_screen.dart'; // Provider de categorias
import '../../players/screens/player_list_screen.dart'; // Provider de jogadores

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final playersAsyncValue = ref.watch(allPlayersStreamProvider);
    final categoriesAsyncValue = ref.watch(categoriesStreamProvider);

    return DefaultTabController(
      length: 3, // Número de abas: Artilharia, Assistências, Cartões
      child: Scaffold(
        appBar: AppBar(
          title: const Text("ESTATÍSTICAS"),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'ARTILHARIA'),
              Tab(text: 'ASSISTÊNCIAS'),
              Tab(text: 'CARTÕES'),
            ],
          ),
        ),
        body: Column(
          children: [
            // --- FILTRO DE CATEGORIA ---
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: categoriesAsyncValue.when(
                data: (categories) => DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  hint: const Text('Filtrar por Categoria'),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas as Categorias')),
                    ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (value) => setState(() => _selectedCategoryId = value),
                ),
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const Text('Erro ao carregar categorias'),
              ),
            ),
            // --- CONTEÚDO DAS ABAS ---
            Expanded(
              child: playersAsyncValue.when(
                data: (players) {
                  // Filtra os jogadores pela categoria selecionada
                  final filteredPlayers = _selectedCategoryId == null
                      ? players
                      : players.where((p) => p.categoryId == _selectedCategoryId).toList();

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
          ],
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
    // Filtra e ordena a lista
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