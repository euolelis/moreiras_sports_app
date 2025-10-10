import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/game_event_model.dart';
import '../../../core/models/game_model.dart';
import '../../../core/services/firestore_service.dart';
import 'manage_players_screen.dart'; // Reutiliza o playersStreamProvider

class ManageGameDetailsScreen extends ConsumerStatefulWidget {
  final Game game;
  const ManageGameDetailsScreen({super.key, required this.game});

  @override
  ConsumerState<ManageGameDetailsScreen> createState() => _ManageGameDetailsScreenState();
}

final gameEventsProvider = StreamProvider.autoDispose.family<List<GameEvent>, String>((ref, gameId) {
  return ref.watch(firestoreServiceProvider).getEventsForGameStream(gameId);
});

class _ManageGameDetailsScreenState extends ConsumerState<ManageGameDetailsScreen> {
  
  // --- NOVO MÉTODO ADICIONADO ---
  void _showEditScoreDialog(BuildContext context) {
    final ourScoreController = TextEditingController(text: widget.game.ourScore?.toString() ?? '');
    final opponentScoreController = TextEditingController(text: widget.game.opponentScore?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Placar Final'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ourScoreController,
                decoration: const InputDecoration(labelText: "Gols Moreira's"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: opponentScoreController,
                decoration: InputDecoration(labelText: 'Gols ${widget.game.opponent}'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final ourScore = int.tryParse(ourScoreController.text);
                final opponentScore = int.tryParse(opponentScoreController.text);

                if (ourScore != null && opponentScore != null) {
                  try {
                    // Nota: O método updateGameScore precisa ser criado no FirestoreService
                    await ref.read(firestoreServiceProvider).updateGameScore(
                          widget.game.id,
                          ourScore,
                          opponentScore,
                        );
                    if (mounted) Navigator.of(context).pop();
                  } catch (e) {
                    // TODO: Mostrar SnackBar de erro
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showAddEventForm(BuildContext context) {
    final minuteController = TextEditingController();
    GameEventType selectedType = GameEventType.gol;
    String? selectedPlayerId;
    String? selectedPlayerName;

    final playersAsyncValue = ref.read(playersStreamProvider);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Adicionar Evento'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<GameEventType>(
                      value: selectedType,
                      items: GameEventType.values.map((type) => DropdownMenuItem(value: type, child: Text(_eventTypeToString(type)))).toList(),
                      onChanged: (value) => setStateDialog(() => selectedType = value!),
                      decoration: const InputDecoration(labelText: 'Tipo'),
                    ),
                    playersAsyncValue.when(
                      data: (players) => DropdownButtonFormField<String>(
                        value: selectedPlayerId,
                        hint: const Text('Selecione o Jogador'),
                        items: players.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedPlayerId = value;
                            selectedPlayerName = players.firstWhere((p) => p.id == value).name;
                          });
                        },
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => const Text('Erro ao carregar jogadores'),
                    ),
                    TextFormField(
                      controller: minuteController,
                      decoration: const InputDecoration(labelText: 'Minuto do Jogo'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedPlayerId != null && minuteController.text.isNotEmpty) {
                      final event = GameEvent(
                        id: '',
                        gameId: widget.game.id,
                        playerId: selectedPlayerId!,
                        playerName: selectedPlayerName!,
                        type: selectedType,
                        minute: int.parse(minuteController.text),
                      );
                      try {
                        await ref.read(firestoreServiceProvider).addGameEvent(event);
                        if (mounted) Navigator.of(context).pop();
                      } catch (e) {
                        // TODO: Mostrar SnackBar de erro
                      }
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsyncValue = ref.watch(gameEventsProvider(widget.game.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes: ${widget.game.opponent}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Editar Placar',
            onPressed: () {
              _showEditScoreDialog(context); // --- MÉTODO CONECTADO AQUI ---
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("Moreira's", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '${widget.game.ourScore ?? '-'} x ${widget.game.opponentScore ?? '-'}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(widget.game.opponent, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Timeline da Partida',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
          ),
          Expanded(
            child: eventsAsyncValue.when(
              data: (events) {
                if (events.isEmpty) {
                  return const Center(child: Text('Nenhum evento lançado para esta partida.'));
                }
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      leading: _getEventIcon(event.type),
                      title: Text('${event.playerName} (${_eventTypeToString(event.type)})'),
                      trailing: Text("${event.minute}'"),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Erro ao carregar eventos: $err")),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventForm(context),
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Evento',
      ),
    );
  }

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
      default:
        return const Icon(Icons.help);
    }
  }

  String _eventTypeToString(GameEventType type) {
    switch (type) {
      case GameEventType.gol:
        return 'Gol';
      case GameEventType.assistencia:
        return 'Assistência';
      case GameEventType.cartaoAmarelo:
        return 'Cartão Amarelo';
      case GameEventType.cartaoVermelho:
        return 'Cartão Vermelho';
      case GameEventType.substituicaoEntra:
        return 'Entrou';
      case GameEventType.substituicaoSai:
        return 'Saiu';
    }
  }
}