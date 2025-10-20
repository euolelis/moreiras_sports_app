import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/providers/global_filter_provider.dart';
import '../../admin/screens/manage_sponsors_screen.dart'; // Reutiliza o provider

class SponsorsListScreen extends ConsumerWidget {
  const SponsorsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sponsorsAsync = ref.watch(sponsorsStreamProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      body: sponsorsAsync.when(
        data: (sponsors) {
          final filteredSponsors = selectedCategory == null
              ? sponsors
              : sponsors.where((s) => s.categoryId == selectedCategory.id).toList();

          if (filteredSponsors.isEmpty) {
            return const Center(child: Text('Nenhum patrocinador para esta categoria.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8, // Ajusta a proporção para o novo layout
            ),
            itemCount: filteredSponsors.length,
            // --- itemBuilder ATUALIZADO ---
            itemBuilder: (context, index) {
              final sponsor = filteredSponsors[index];
              return InkWell(
                onTap: () => context.go('/sponsors/${sponsor.id}', extra: sponsor),
                borderRadius: BorderRadius.circular(100), // Para o efeito de clique ser redondo
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- CÍRCULO PARA O LOGO ---
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: (sponsor.logoUrl.isNotEmpty)
                          ? CachedNetworkImageProvider(sponsor.logoUrl)
                          : null,
                      child: (sponsor.logoUrl.isEmpty)
                          ? const Icon(Icons.business, size: 40, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    // --- NOME DO PATROCINADOR ---
                    Text(
                      sponsor.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}