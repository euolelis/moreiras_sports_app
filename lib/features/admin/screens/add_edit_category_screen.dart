import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/category_model.dart';
import '../../../core/services/firestore_service.dart';

class AddEditCategoryScreen extends ConsumerStatefulWidget {
  final String? categoryId;
  const AddEditCategoryScreen({super.key, this.categoryId});

  @override
  ConsumerState<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends ConsumerState<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingData = false; // Para o carregamento inicial

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      _isLoadingData = true;
      Future.microtask(() => _loadCategoryData());
    }
  }

  // Novo método para carregar os dados da categoria
  Future<void> _loadCategoryData() async {
    try {
      // Este método precisará ser criado no FirestoreService
      final category = await ref.read(firestoreServiceProvider).getCategoryById(widget.categoryId!);

      // Preenche o controller com o nome da categoria
      _nameController.text = category.name;
      
      setState(() {
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() { _isLoadingData = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados da categoria: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      final category = Category(
        id: widget.categoryId ?? '',
        name: _nameController.text.trim(),
      );
      try {
        await ref.read(firestoreServiceProvider).setCategory(category);
        if (mounted) {
          // Navega de volta para a lista de categorias com mensagem de sucesso
          context.go('/admin/manage-categories', extra: 'Categoria salva com sucesso!');
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryId == null ? 'Nova Categoria' : 'Editar Categoria')),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da Categoria (Ex: Sub-11)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(onPressed: _saveCategory, child: const Text('Salvar Categoria')),
                    ],
                  ),
                ),
    );
  }
}