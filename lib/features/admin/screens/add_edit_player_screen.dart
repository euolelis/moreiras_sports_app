import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:go_router/go_router.dart';
    import 'package:intl/intl.dart';
    import '../../../core/models/player_model.dart';
    import '../../../core/services/firestore_service.dart';

    class AddEditPlayerScreen extends ConsumerStatefulWidget {
      // O ID do jogador é opcional. Se for nulo, estamos criando um novo.
      final String? playerId;
      const AddEditPlayerScreen({super.key, this.playerId});

      @override
      ConsumerState<AddEditPlayerScreen> createState() => _AddEditPlayerScreenState();
    }

    class _AddEditPlayerScreenState extends ConsumerState<AddEditPlayerScreen> {
      final _formKey = GlobalKey<FormState>();
      final _nameController = TextEditingController();
      final _positionController = TextEditingController();
      final _numberController = TextEditingController();
      DateTime? _birthDate;
      bool _isLoading = false;

      bool get _isEditing => widget.playerId != null;

      @override
      void initState() {
        super.initState();
        // Se estiver editando, vamos carregar os dados do jogador
        if (_isEditing) {
          // Lógica para carregar dados virá aqui
        }
      }

      @override
      void dispose() {
        _nameController.dispose();
        _positionController.dispose();
        _numberController.dispose();
        super.dispose();
      }

      Future<void> _selectDate(BuildContext context) async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _birthDate ?? DateTime.now(),
          firstDate: DateTime(1990),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != _birthDate) {
          setState(() {
            _birthDate = picked;
          });
        }
      }

      Future<void> _savePlayer() async {
        if (_formKey.currentState?.validate() ?? false) {
          if (_birthDate == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Por favor, selecione a data de nascimento.')),
            );
            return;
          }

          setState(() => _isLoading = true);

          final player = Player(
            id: widget.playerId ?? '', // Se for novo, ID vazio
            name: _nameController.text,
            position: _positionController.text,
            number: int.parse(_numberController.text),
            birthDate: _birthDate!,
          );

          try {
            await ref.read(firestoreServiceProvider).setPlayer(player);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Jogador salvo com sucesso!')),
              );
              context.pop(); // Volta para a tela anterior
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao salvar: $e')),
              );
            }
          } finally {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          }
        }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Editar Jogador' : 'Adicionar Jogador'),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Nome Completo'),
                          validator: (value) => (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _positionController,
                          decoration: const InputDecoration(labelText: 'Posição (Ex: Atacante)'),
                          validator: (value) => (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _numberController,
                          decoration: const InputDecoration(labelText: 'Número da Camisa'),
                          keyboardType: TextInputType.number,
                          validator: (value) => (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _birthDate == null
                                    ? 'Nenhuma data selecionada'
                                    : 'Nascimento: ${DateFormat('dd/MM/yyyy').format(_birthDate!)}',
                              ),
                            ),
                            TextButton(
                              onPressed: () => _selectDate(context),
                              child: const Text('Selecionar Data'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _savePlayer,
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Salvar Jogador'),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      }
    }