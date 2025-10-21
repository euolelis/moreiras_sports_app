import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/player_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import 'manage_categories_screen.dart'; // Import para o provider de categorias

final playersStreamProvider = StreamProvider.autoDispose<List<Player>>((ref) {
  return ref.watch(firestoreServiceProvider).getPlayersStream();
});

class ManagePlayersScreen extends ConsumerStatefulWidget {
  const ManagePlayersScreen({super.key});

  @override
  ConsumerState<ManagePlayersScreen> createState() => _ManagePlayersScreenState();
}

class _ManagePlayersScreenState extends ConsumerState<ManagePlayersScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategoryId; // 2. Variável de estado para o filtro de categoria

  @override
  void initState() {
    super.initState();
    // O listener garante que a UI reconstrua a cada letra digitada na busca
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playersAsyncValue = ref.watch(playersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Elenco"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.go('/admin/add-player');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 3. --- FILTRO DE CATEGORIA ---
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0), // Ajuste de padding
            child: Consumer(builder: (context, ref, child) {
              final categoriesAsync = ref.watch(categoriesStreamProvider);
              return categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<String?>(
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
                error: (e, s) => const SizedBox.shrink(),
              );
            }),
          ),
          // --- BARRA DE BUSCA (JÁ EXISTENTE) ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nome...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          // --- LISTA DE JOGADORES ---
          Expanded(
            child: playersAsyncValue.when(
              data: (players) {
                // Lógica de filtragem combinada
                final searchQuery = _searchController.text.toLowerCase();
                final filteredPlayers = players.where((player) {
                  final categoryMatch = _selectedCategoryId == null || player.categoryId == _selectedCategoryId;
                  final nameMatch = player.name.toLowerCase().contains(searchQuery);
                  return categoryMatch && nameMatch;
                }).toList();

                if (filteredPlayers.isEmpty) {
                  return const Center(
                    child: Text("Nenhum jogador encontrado."),
                  );
                }
                
                return ListView.builder(
                  itemCount: filteredPlayers.length,
                  itemBuilder: (context, index) {
                    final player = filteredPlayers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(player.number.toString()),
                      ),
                      title: Text(player.name),
                      subtitle: Text(player.position),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              context.go('/admin/edit-player/${player.id}');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showConfirmDialog(
                                context: context,
                                title: 'Confirmar Exclusão',
                                content: 'Tem certeza que deseja deletar o jogador "${player.name}"?',
                              );
                              if (confirm && context.mounted) {
                                await ref.read(firestoreServiceProvider).deletePlayer(player.id);
                              }
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
          ),
        ],
      ),
    );
  }
}