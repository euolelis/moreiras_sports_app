import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:go_router/go_router.dart';
    import '../../../core/models/sponsor_model.dart';
    import '../../../core/services/firestore_service.dart';
    import 'package:cached_network_image/cached_network_image.dart';

    final sponsorsStreamProvider = StreamProvider.autoDispose<List<Sponsor>>((ref) {
      return ref.watch(firestoreServiceProvider).getSponsorsStream();
    });

    class ManageSponsorsScreen extends ConsumerWidget {
      const ManageSponsorsScreen({super.key});

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        final sponsorsAsyncValue = ref.watch(sponsorsStreamProvider);
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
          body: sponsorsAsyncValue.when(
            data: (sponsors) => ListView.builder(
              itemCount: sponsors.length,
              itemBuilder: (context, index) {
                final sponsor = sponsors[index];
                return ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: sponsor.logoUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                  ),
                  title: Text(sponsor.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => ref.read(firestoreServiceProvider).deleteSponsor(sponsor.id),
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