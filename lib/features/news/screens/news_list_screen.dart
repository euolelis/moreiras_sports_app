import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/news_model.dart';
import '../../../core/services/firestore_service.dart';

// Provider para buscar o stream de notícias
final newsStreamProvider = StreamProvider.autoDispose<List<News>>((ref) {
  return ref.watch(firestoreServiceProvider).getNewsStream();
});

class NewsListScreen extends ConsumerWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsyncValue = ref.watch(newsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("NOTÍCIAS E COMUNICADOS"),
        centerTitle: true,
      ),
      body: newsAsyncValue.when(
        data: (newsList) {
          if (newsList.isEmpty) {
            return const Center(child: Text("Nenhuma notícia publicada."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR').format(news.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Divider(height: 20),
                      Text(news.content),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Ocorreu um erro: $err")),
      ),
    );
  }
}