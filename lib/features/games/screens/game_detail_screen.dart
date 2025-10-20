import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/game_event_model.dart';
import '../../../core/models/game_model.dart';
import '../../admin/screens/manage_game_details_screen.dart'; // Reutiliza o gameEventsProvider

class GameDetailScreen extends ConsumerWidget {
  final Game game;
  const GameDetailScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ouve o provider que busca os eventos para este jogo específico
    final eventsAsyncValue = ref.watch(gameEventsProvider(game.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes da Partida"),
      ),
      body: Column(
        children: [
          // Card do Placar
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: Text("Moreira's", style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center)),
                  Text(
                    '${game.ourScore ?? '-'} x ${game.opponentScore ?? '-'}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Expanded(child: Text(game.opponent, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center)),
                ],
              ),
            ),
          ),
          
          // Título da Timeline
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "LINHA DO TEMPO",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.amber[600]),
            ),
          ),

          // Lista da Timeline
          Expanded(
            child: eventsAsyncValue.when(
              data: (events) {
                if (events.isEmpty) {
                  return const Center(child: Text("Nenhum evento registrado para esta partida."));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return _TimelineTile(event: event);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              // CORREÇÃO: Adiciona o builder de erro que estava faltando
              error: (err, stack) => Center(child: Text("Erro ao carregar eventos: $err")),
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS AUXILIARES PARA A TIMELINE (ESTAVAM FALTANDO) ---

class _TimelineTile extends StatelessWidget {
  final GameEvent event;
  const _TimelineTile({required this.event});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Coluna da linha do tempo (ícone e linhas)
          SizedBox(
            width: 60,
            child: Column(
              children: [
                const Expanded(child: VerticalDivider(color: Colors.grey, thickness: 2)),
                _getEventIcon(event.type),
                const Expanded(child: VerticalDivider(color: Colors.grey, thickness: 2)),
              ],
            ),
          ),
          // Coluna do conteúdo (minuto e descrição)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${event.playerName} (${_eventTypeToString(event.type)})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("${event.minute}'"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Funções auxiliares para ícones e textos
  Icon _getEventIcon(GameEventType type) {
    switch (type) {
      case GameEventType.gol:
        return const Icon(Icons.sports_soccer, color: Colors.green);
      case GameEventType.assistencia:
        return const Icon(Icons.assistant, color: Colors.blue);
      case GameEventType.cartaoAmarelo:
        return const Icon(Icons.style, color: Colors.yellow);
      case GameEventType.cartaoVermelho:
        return const Icon(Icons.style, color: Colors.red);
      case GameEventType.substituicaoEntra:
        return const Icon(Icons.arrow_upward, color: Colors.green);
      case GameEventType.substituicaoSai:
        return const Icon(Icons.arrow_downward, color: Colors.red);
    }
  }

  String _eventTypeToString(GameEventType type) {
    switch (type) {
      case GameEventType.gol: return 'Gol';
      case GameEventType.assistencia: return 'Assistência';
      case GameEventType.cartaoAmarelo: return 'Cartão Amarelo';
      case GameEventType.cartaoVermelho: return 'Cartão Vermelho';
      case GameEventType.substituicaoEntra: return 'Entrou';
      case GameEventType.substituicaoSai: return 'Saiu';
    }
  }
}