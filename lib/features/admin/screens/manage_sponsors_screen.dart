import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/sponsor_model.dart';
import '../../../core/services/firestore_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/widgets/confirm_dialog.dart'; // Import para o dialog de confirmação

final sponsorsStreamProvider = StreamProvider.autoDispose<List<Sponsor>>((ref) {
  return ref.watch(firestoreServiceProvider).getSponsorsStream();
});

class ManageSponsorsScreen extends ConsumerWidget {
  const ManageSponsorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sponsorsAsync = ref.watch(sponsorsStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Patrocinadores"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/admin/add-sponsor'),
          ),
        ],
      ),
      body: sponsorsAsync.when(
        data: (sponsors) => ListView.builder(
          itemCount: sponsors.length,
          itemBuilder: (context, index) {
            final sponsor = sponsors[index];
            // --- ListTile ATUALIZADO ---
            return ListTile(
              leading: CachedNetworkImage(
                imageUrl: sponsor.logoUrl,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.business),
              ),
              title: Text(sponsor.name),
              // TODO: Mostrar a qual categoria ele pertence
              onTap: () => context.go('/admin/edit-sponsor/${sponsor.id}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- BOTÃO DE EDITAR ---
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Editar Patrocinador',
                    onPressed: () => context.go('/admin/edit-sponsor/${sponsor.id}'),
                  ),
                  // --- BOTÃO DE DELETAR (ATUALIZADO COM CONFIRMAÇÃO) ---
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Excluir Patrocinador',
                    onPressed: () async {
                      final confirmed = await showConfirmDialog(
                        context: context,
                        title: 'Confirmar Exclusão',
                        content: 'Tem certeza que deseja excluir o patrocinador "${sponsor.name}"?',
                      );
                      if (confirmed && context.mounted) {
                        // TODO: Adicionar lógica para deletar imagem do Storage
                        await ref.read(firestoreServiceProvider).deleteSponsor(sponsor.id);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}