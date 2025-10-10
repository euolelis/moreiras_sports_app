import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/news_model.dart';
import '../../../core/services/firestore_service.dart';

class AddEditNewsScreen extends ConsumerStatefulWidget {
  final String? newsId;
  const AddEditNewsScreen({super.key, this.newsId});

  @override
  ConsumerState<AddEditNewsScreen> createState() => _AddEditNewsScreenState();
}

class _AddEditNewsScreenState extends ConsumerState<AddEditNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNews() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      final newsItem = News(
        id: widget.newsId ?? '',
        title: _titleController.text,
        content: _contentController.text,
        createdAt: DateTime.now(),
      );
      try {
        await ref.read(firestoreServiceProvider).setNews(newsItem);
        if (mounted) context.pop();
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.newsId == null ? 'Nova Notícia' : 'Editar Notícia')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(labelText: 'Conteúdo'),
                    maxLines: 8,
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(onPressed: _saveNews, child: const Text('Publicar Notícia')),
                ],
              ),
            ),
    );
  }
}