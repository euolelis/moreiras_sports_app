import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/game_model.dart';
import '../../../core/services/firestore_service.dart';
import 'manage_categories_screen.dart'; // 1. Importe o provider

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
  String? _selectedCategoryId; // 2. Adicione a variável de estado
  bool _isLoading = false;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    if (widget.gameId != null) {
      _isLoadingData = true;
      Future.microtask(() => _loadGameData());
    }
  }

  Future<void> _loadGameData() async {
    try {
      final game = await ref.read(firestoreServiceProvider).getGameById(widget.gameId!);

      _championshipController.text = game.championship;
      _opponentController.text = game.opponent;
      _locationController.text = game.location;
      
      setState(() {
        _gameDate = game.gameDate;
        _status = game.status;
        _selectedCategoryId = game.categoryId; // 5. Pré-preencha a categoria
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() { _isLoadingData = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados do jogo: $e')),
        );
      }
    }
  }

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
      // ignore: use_build_context_synchronously
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
      // 4. Adicione a validação para a categoria
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione uma categoria.')),
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
        categoryId: _selectedCategoryId!, // 4. Adicione o categoryId
      );
      try {
        await ref.read(firestoreServiceProvider).setGame(game);
        if (mounted) context.go('/admin/manage-games', extra: 'Jogo salvo com sucesso!');
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
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // 3. Adicione o Dropdown de Categorias
                      Consumer(
                        builder: (context, ref, child) {
                          final categoriesAsyncValue = ref.watch(categoriesStreamProvider);
                          return categoriesAsyncValue.when(
                            data: (categories) => DropdownButtonFormField<String>(
                              initialValue: _selectedCategoryId,
                              hint: const Text('Selecione a Categoria do Jogo'),
                              decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
                              items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                              onChanged: (value) => setState(() => _selectedCategoryId = value),
                              validator: (value) => value == null ? 'Selecione uma categoria' : null,
                            ),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, s) => const Text('Erro ao carregar categorias'),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(controller: _championshipController, decoration: const InputDecoration(labelText: 'Campeonato', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      TextFormField(controller: _opponentController, decoration: const InputDecoration(labelText: 'Adversário', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Local', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Text(_gameDate == null ? 'Nenhuma data selecionada' : DateFormat('dd/MM/yyyy HH:mm').format(_gameDate!))),
                          TextButton(onPressed: () => _selectDateTime(context), child: const Text('Selecionar')),
                        ],
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        items: ['Agendado', 'Em Andamento', 'Encerrado', 'Cancelado']
                            .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                            .toList(),
                        onChanged: (value) => setState(() => _status = value!),
                        decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(onPressed: _saveGame, child: const Text('Salvar Jogo')),
                    ],
                  ),
                ),
    );
  }
}