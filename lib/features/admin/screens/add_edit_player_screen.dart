import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // 1. Import para checar se é web
import 'package:image_picker/image_picker.dart';      // 2. Import do image_picker
import '../../../core/models/player_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/storage_service.dart';   // 3. Import do storage_service

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

  // 4. Novas variáveis de estado para a imagem
  XFile? _selectedImageFile;
  String? _existingPhotoUrl; // Usado para guardar a URL da foto ao editar

  bool get _isEditing => widget.playerId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      // Lógica para carregar dados virá aqui (incluindo _existingPhotoUrl)
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

  // 5. Nova função para selecionar a imagem da galeria
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImageFile = image;
      });
    }
  }

  // 6. Função _savePlayer MODIFICADA para lidar com o upload
  Future<void> _savePlayer() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione a data de nascimento.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    String? photoUrl = _existingPhotoUrl; // Começa com a URL da foto existente (se houver)

    try {
      // Se uma nova imagem foi selecionada, faz o upload dela para o Storage
      if (_selectedImageFile != null) {
        photoUrl = await ref.read(storageServiceProvider).uploadPlayerImage(_selectedImageFile!);
      }

      final player = Player(
        id: widget.playerId ?? '',
        name: _nameController.text,
        position: _positionController.text,
        number: int.parse(_numberController.text),
        birthDate: _birthDate!,
        photoUrl: photoUrl, // Usa a URL da foto (nova ou existente)
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
                      decoration: const InputDecoration(labelText: 'Nome Completo'),
                      validator: (value) => (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),

                    // 7. --- WIDGET DE UPLOAD DE IMAGEM ADICIONADO ---
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
                                // Na web, o path do image_picker é uma URL que pode ser usada com Image.network
                                // Em mobile, seria Image.file(File(_selectedImageFile!.path))
                                child: kIsWeb
                                    ? Image.network(_selectedImageFile!.path, fit: BoxFit.cover)
                                    : Image.asset("assets/placeholder.png"), // Adicione um placeholder para mobile ou implemente a lógica de File
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
                    // --- FIM DO WIDGET ---

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