import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/category_model.dart';
import '../../../core/services/firestore_service.dart';

final categoriesStreamProvider = StreamProvider.autoDispose<List<Category>>((ref) {
  return ref.watch(firestoreServiceProvider).getCategoriesStream();
});

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Categorias"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/admin/add-category'),
          ),
        ],
      ),
      body: categoriesAsyncValue.when(
        data: (categories) => ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return ListTile(
              title: Text(category.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  // Adicionar um dialog de confirmação aqui é uma boa prática
                  await ref.read(firestoreServiceProvider).deleteCategory(category.id);
                },
              ),
              // onTap: () => context.go('/admin/edit-category/${category.id}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Ocorreu um erro: $err")),
      ),
    );
  }
}