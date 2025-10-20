import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/category_model.dart';
import '../../../core/providers/global_filter_provider.dart';
import '../../admin/screens/manage_categories_screen.dart';

class CategorySelectionScreen extends ConsumerWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Selecione uma Categoria"),
        centerTitle: true,
        // Remove o botão de voltar automático, pois esta é uma tela de entrada
        automaticallyImplyLeading: false,
      ),
      body: categoriesAsyncValue.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Nenhuma categoria foi cadastrada ainda. Peça ao administrador para configurar as turmas.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            // Ajusta o Grid para 2 ou 3 colunas dependendo do tamanho da tela
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1, // Proporção mais agradável
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryButton(
                category: category,
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state = category;
                  context.go('/');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => const Center(child: Text("Erro ao carregar categorias")),
      ),
    );
  }
}

// --- NOVO WIDGET DE BOTÃO, MAIS ELABORADO ---
class _CategoryButton extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  const _CategoryButton({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone representativo
            Icon(
              Icons.groups, // Ícone de "grupos" ou "times"
              size: 48,
              color: Colors.amber[600],
            ),
            const SizedBox(height: 12),
            // Nome da categoria
            Text(
              category.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.amber[600],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}