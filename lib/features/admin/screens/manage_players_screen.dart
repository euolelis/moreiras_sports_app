import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/player_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../shared/widgets/confirm_dialog.dart';

// O provider continua o mesmo
final playersStreamProvider = StreamProvider.autoDispose<List<Player>>((ref) {
  return ref.watch(firestoreServiceProvider).getPlayersStream();
});

// 1. Convertido para ConsumerStatefulWidget
class ManagePlayersScreen extends ConsumerStatefulWidget {
  const ManagePlayersScreen({super.key});

  @override
  ConsumerState<ManagePlayersScreen> createState() => _ManagePlayersScreenState();
}

class _ManagePlayersScreenState extends ConsumerState<ManagePlayersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Adiciona um listener para reconstruir a UI quando o texto da busca mudar
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
      // 2. Corpo envolvido em uma Column para a barra de busca
      body: Column(
        children: [
          // --- BARRA DE BUSCA ---
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
          // --- FIM DA BARRA DE BUSCA ---

          // --- LISTA DE JOGADORES ---
          Expanded(
            child: playersAsyncValue.when(
              data: (players) {
                // Lógica de filtragem
                final searchQuery = _searchController.text.toLowerCase();
                final filteredPlayers = players.where((player) {
                  return player.name.toLowerCase().contains(searchQuery);
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
                              if (confirm) {
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