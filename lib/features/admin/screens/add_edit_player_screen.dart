import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../../../core/models/player_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/storage_service.dart';
import 'manage_categories_screen.dart';

class AddEditPlayerScreen extends ConsumerStatefulWidget {
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

  XFile? _selectedImageFile;
  String? _existingPhotoUrl;
  String? _selectedCategoryId;

  bool get _isEditing => widget.playerId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      // TODO: Carregar dados do jogador, incluindo _selectedCategoryId
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImageFile = image;
      });
    }
  }

  Future<void> _savePlayer() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma categoria.')),
      );
      return;
    }
    
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione a data de nascimento.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    String? photoUrl = _existingPhotoUrl;

    try {
      if (_selectedImageFile != null) {
        photoUrl = await ref.read(storageServiceProvider).uploadPlayerImage(_selectedImageFile!);
      }

      final player = Player(
        id: widget.playerId ?? '',
        name: _nameController.text,
        position: _positionController.text,
        number: int.parse(_numberController.text),
        birthDate: _birthDate!,
        photoUrl: photoUrl,
        categoryId: _selectedCategoryId!,
      );

      await ref.read(firestoreServiceProvider).setPlayer(player);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jogador salvo com sucesso!')),
        );
        context.pop();
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
                      decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder()),
                      validator: (value) => (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),

                    // --- DROPDOWN DE CATEGORIAS ATUALIZADO ---
                    Consumer(
                      builder: (context, ref, child) {
                        final categoriesAsyncValue = ref.watch(categoriesStreamProvider);
                        return categoriesAsyncValue.when(
                          data: (categories) {
                            if (_selectedCategoryId != null && !categories.any((c) => c.id == _selectedCategoryId)) {
                              _selectedCategoryId = null;
                            }
                            return DropdownButtonFormField<String>(
                              value: _selectedCategoryId,
                              hint: const Text('Selecione a Categoria'),
                              decoration: const InputDecoration(
                                labelText: 'Categoria',
                                border: OutlineInputBorder(), // Adiciona uma borda
                              ),
                              items: categories.map((category) {
                                return DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategoryId = value;
                                });
                              },
                              validator: (value) => value == null ? 'Selecione uma categoria' : null,
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => const Text('Erro ao carregar categorias. Cadastre uma primeiro.'),
                        );
                      },
                    ),
                    // --- FIM DO DROPDOWN ---

                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: _selectedImageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: kIsWeb
                                    ? Image.network(_selectedImageFile!.path, fit: BoxFit.cover)
                                    : Image.asset("assets/placeholder.png"),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text('Adicionar Foto', style: TextStyle(color: Colors.grey[400])),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _positionController,
                      decoration: const InputDecoration(labelText: 'Posição (Ex: Atacante)', border: OutlineInputBorder()),
                      validator: (value) => (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _numberController,
                      decoration: const InputDecoration(labelText: 'Número da Camisa', border: OutlineInputBorder()),
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