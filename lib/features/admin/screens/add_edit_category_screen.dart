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
        if (mounted) context.pop();
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryId == null ? 'Nova Categoria' : 'Editar Categoria')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome da Categoria (Ex: Sub-11)'),
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(onPressed: _saveCategory, child: const Text('Salvar Categoria')),
                ],
              ),
            ),
    );
  }
}