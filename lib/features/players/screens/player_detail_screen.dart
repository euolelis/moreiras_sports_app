    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:cached_network_image/cached_network_image.dart';
    import '../../../core/models/player_model.dart';
    import '../../../core/services/firestore_service.dart'; // <-- IMPORTAÇÃO CORRETA

    // Provider corrigido para usar o novo método do serviço
    final playerDetailProvider = FutureProvider.autoDispose.family<Player, String>((ref, playerId) async {
      // Agora chamamos o método otimizado para buscar um único jogador
      return ref.watch(firestoreServiceProvider).getPlayerById(playerId);
    });

    class PlayerDetailScreen extends ConsumerWidget {
      final String playerId;
      const PlayerDetailScreen({super.key, required this.playerId});

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final playerAsyncValue = ref.watch(playerDetailProvider(playerId));

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          extendBodyBehindAppBar: true,
          body: playerAsyncValue.when(
            data: (player) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Garante que a imagem ocupe a largura
              children: [
                // --- SEÇÃO DA FOTO ---
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: player.photoUrl != null && player.photoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: player.photoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[800]),
                          errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                        )
                      : Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.person, size: 100, color: Colors.grey),
                        ),
                ),
                // --- SEÇÃO DO NOME E POSIÇÃO ---
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    children: [
                      Text(
                        player.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${player.number} - ${player.position.toUpperCase()}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.amber[600]),
                      ),
                    ],
                  ),
                ),
                // Adicione mais seções aqui (estatísticas, etc.)
                const Spacer(), // Empurra o conteúdo para cima
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Erro ao carregar jogador: $err", style: const TextStyle(color: Colors.white))),
          ),
        );
      }
    }