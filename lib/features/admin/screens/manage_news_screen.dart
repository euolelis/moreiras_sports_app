import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/news_model.dart';
import '../../../core/services/firestore_service.dart';

final newsStreamProvider = StreamProvider.autoDispose<List<News>>((ref) {
  return ref.watch(firestoreServiceProvider).getNewsStream();
});

class ManageNewsScreen extends ConsumerWidget {
  const ManageNewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsyncValue = ref.watch(newsStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Notícias"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/admin/add-news'),
          ),
        ],
      ),
      body: newsAsyncValue.when(
        data: (newsList) => ListView.builder(
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            final news = newsList[index];
            return ListTile(
              title: Text(news.title),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(news.createdAt)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  // Adicionar confirmação antes de deletar
                  await ref.read(firestoreServiceProvider).deleteNews(news.id);
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Ocorreu um erro: $err")),
      ),
    );
  }
}