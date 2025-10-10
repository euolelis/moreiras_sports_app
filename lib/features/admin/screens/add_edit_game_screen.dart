  import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:go_router/go_router.dart';
    import 'package:intl/intl.dart';
    import '../../../core/models/game_model.dart';
    import '../../../core/services/firestore_service.dart';

    class AddEditGameScreen extends ConsumerStatefulWidget {
      final String? gameId;
      const AddEditGameScreen({super.key, this.gameId});

      @override
      ConsumerState<AddEditGameScreen> createState() => _AddEditGameScreenState();
    }

    class _AddEditGameScreenState extends ConsumerState<AddEditGameScreen> {
      final _formKey = GlobalKey<FormState>();
      final _championshipController = TextEditingController();
      final _opponentController = TextEditingController();
      final _locationController = TextEditingController();
      DateTime? _gameDate;
      String _status = 'Agendado';
      bool _isLoading = false;

      @override
      void dispose() {
        _championshipController.dispose();
        _opponentController.dispose();
        _locationController.dispose();
        super.dispose();
      }

      Future<void> _selectDateTime(BuildContext context) async {
        final date = await showDatePicker(
          context: context,
          initialDate: _gameDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date == null) return;

        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_gameDate ?? DateTime.now()),
        );
        if (time == null) return;

        setState(() {
          _gameDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }

      Future<void> _saveGame() async {
        if (_formKey.currentState?.validate() ?? false) {
          if (_gameDate == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Por favor, selecione a data e hora do jogo.')),
            );
            return;
          }
          setState(() => _isLoading = true);
          final game = Game(
            id: widget.gameId ?? '',
            championship: _championshipController.text,
            opponent: _opponentController.text,
            location: _locationController.text,
            gameDate: _gameDate!,
            status: _status,
          );
          try {
            await ref.read(firestoreServiceProvider).setGame(game);
            if (mounted) context.pop();
          } catch (e) {
            // Tratar erro
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.gameId == null ? 'Adicionar Jogo' : 'Editar Jogo')),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      TextFormField(controller: _championshipController, decoration: const InputDecoration(labelText: 'Campeonato')),
                      TextFormField(controller: _opponentController, decoration: const InputDecoration(labelText: 'Adversário')),
                      TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Local')),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Text(_gameDate == null ? 'Nenhuma data selecionada' : DateFormat('dd/MM/yyyy HH:mm').format(_gameDate!))),
                          TextButton(onPressed: () => _selectDateTime(context), child: const Text('Selecionar')),
                        ],
                      ),
                      DropdownButtonFormField<String>(
                        value: _status,
                        items: ['Agendado', 'Em Andamento', 'Encerrado', 'Cancelado']
                            .map((label) => DropdownMenuItem(child: Text(label), value: label))
                            .toList(),
                        onChanged: (value) => setState(() => _status = value!),
                        decoration: const InputDecoration(labelText: 'Status'),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(onPressed: _saveGame, child: const Text('Salvar Jogo')),
                    ],
                  ),
                ),
        );
      }
    }