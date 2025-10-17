import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/models/player_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/storage_service.dart';
import '../../players/screens/player_detail_screen.dart';
import 'manage_categories_screen.dart';

class AddEditPlayerScreen extends ConsumerWidget {
  final String? playerId;
  const AddEditPlayerScreen({super.key, this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (playerId != null) {
      final playerAsyncValue = ref.watch(playerDetailProvider(playerId!));
      return playerAsyncValue.when(
        data: (player) => _PlayerForm(player: player),
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Editar Jogador')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Scaffold(
          appBar: AppBar(title: const Text('Erro')),
          body: Center(child: Text('Erro ao carregar jogador: $err')),
        ),
      );
    } else {
      return const _PlayerForm();
    }
  }
}

class _PlayerForm extends ConsumerStatefulWidget {
  final Player? player;
  const _PlayerForm({this.player});

  @override
  ConsumerState<_PlayerForm> createState() => _PlayerFormState();
}

class _PlayerFormState extends ConsumerState<_PlayerForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _positionController;
  late TextEditingController _numberController;
  late TextEditingController _goalsController;
  late TextEditingController _assistsController;
  late TextEditingController _gamesPlayedController;
  late TextEditingController _motmController;
  late TextEditingController _socialUrlController;

  DateTime? _birthDate;
  String? _selectedCategoryId;
  String? _existingPhotoUrl;
  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.player;
    _nameController = TextEditingController(text: p?.name ?? '');
    _positionController = TextEditingController(text: p?.position ?? '');
    _numberController = TextEditingController(text: p?.number.toString() ?? '');
    _goalsController = TextEditingController(text: p?.goals.toString() ?? '0');
    _assistsController = TextEditingController(text: p?.assists.toString() ?? '0');
    _gamesPlayedController = TextEditingController(text: p?.gamesPlayed.toString() ?? '0');
    _motmController = TextEditingController(text: p?.manOfTheMatch.toString() ?? '0');
    _socialUrlController = TextEditingController(text: p?.socialUrl ?? '');
    _birthDate = p?.birthDate;
    _selectedCategoryId = p?.categoryId;
    _existingPhotoUrl = p?.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _numberController.dispose();
    _goalsController.dispose();
    _assistsController.dispose();
    _gamesPlayedController.dispose();
    _motmController.dispose();
    _socialUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageFile = image;
        _selectedImageBytes = bytes;
      });
    }
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
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione a data de nascimento.')));
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione uma categoria.')));
      return;
    }

    setState(() => _isSaving = true);
    String? photoUrl = _existingPhotoUrl;

    try {
      if (_selectedImageFile != null) {
        photoUrl = await ref.read(storageServiceProvider).uploadPlayerImage(_selectedImageFile!);
      }

      final playerToSave = Player(
        id: widget.player?.id ?? '',
        name: _nameController.text,
        position: _positionController.text,
        number: int.parse(_numberController.text),
        birthDate: _birthDate!,
        photoUrl: photoUrl,
        categoryId: _selectedCategoryId!,
        goals: int.tryParse(_goalsController.text) ?? 0,
        assists: int.tryParse(_assistsController.text) ?? 0,
        gamesPlayed: int.tryParse(_gamesPlayedController.text) ?? 0,
        manOfTheMatch: int.tryParse(_motmController.text) ?? 0,
        socialUrl: _socialUrlController.text.trim(),
        yellowCards: widget.player?.yellowCards ?? 0,
        redCards: widget.player?.redCards ?? 0,
      );

      await ref.read(firestoreServiceProvider).setPlayer(playerToSave);
      if (mounted) {
        context.go('/admin/manage-players', extra: 'Jogador salvo com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.player == null ? 'Adicionar Jogador' : 'Editar Jogador'),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
                  const SizedBox(height: 16),
                  Consumer(builder: (context, ref, child) {
                    final categoriesAsync = ref.watch(categoriesStreamProvider);
                    return categoriesAsync.when(
                      data: (categories) => DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _selectedCategoryId,
                        hint: const Text('Selecione a Categoria'),
                        decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
                        items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                        onChanged: (value) => setState(() => _selectedCategoryId = value),
                        validator: (value) => value == null ? 'Selecione uma categoria' : null,
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => const Text('Erro ao carregar categorias'),
                    );
                  }),
                  const SizedBox(height: 16),
                  // --- GESTUREDETECTOR ATUALIZADO ---
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImageWidget(), // <-- CHAMADA DA FUNÇÃO AUXILIAR
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(controller: _positionController, decoration: const InputDecoration(labelText: 'Posição', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _numberController, decoration: const InputDecoration(labelText: 'Número da Camisa', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: TextFormField(controller: _goalsController, decoration: const InputDecoration(labelText: 'Gols', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: TextFormField(controller: _assistsController, decoration: const InputDecoration(labelText: 'Assist.', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: TextFormField(controller: _gamesPlayedController, decoration: const InputDecoration(labelText: 'Jogos', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: TextFormField(controller: _motmController, decoration: const InputDecoration(labelText: 'Craque do Jogo', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  ]),
                  const SizedBox(height: 16),
                  TextFormField(controller: _socialUrlController, decoration: const InputDecoration(labelText: 'Link da Rede Social', prefixIcon: Icon(Icons.link), border: OutlineInputBorder()), keyboardType: TextInputType.url),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: Text(_birthDate == null ? 'Nenhuma data selecionada' : 'Nascimento: ${DateFormat('dd/MM/yyyy').format(_birthDate!)}')),
                    TextButton(onPressed: () => _selectDate(context), child: const Text('Selecionar Data')),
                  ]),
                  const SizedBox(height: 32),
                  ElevatedButton(onPressed: _savePlayer, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Salvar Jogador')),
                ],
              ),
            ),
    );
  }

  // --- NOVA FUNÇÃO AUXILIAR ADICIONADA ---
  Widget _buildImageWidget() {
    // Prioridade 1: Se uma nova imagem foi selecionada (em bytes), mostre-a.
    if (_selectedImageBytes != null) {
      return Image.memory(_selectedImageBytes!, fit: BoxFit.cover);
    }

    // Prioridade 2: Se não há imagem nova, mas existe uma URL do banco de dados, mostre-a.
    if (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _existingPhotoUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
      );
    }

    // Prioridade 3: Se não há nenhuma imagem, mostre o placeholder para adicionar uma.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text('Adicionar Foto', style: TextStyle(color: Colors.grey[400])),
      ],
    );
  }
}