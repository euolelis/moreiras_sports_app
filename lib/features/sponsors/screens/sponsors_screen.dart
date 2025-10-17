import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../admin/screens/manage_sponsors_screen.dart'; // Reutiliza o provider

class SponsorsScreen extends ConsumerWidget {
  const SponsorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sponsorsAsyncValue = ref.watch(sponsorsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Nossos Patrocinadores')),
      body: sponsorsAsyncValue.when(
        data: (sponsors) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: sponsors.length,
          itemBuilder: (context, index) {
            final sponsor = sponsors[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CachedNetworkImage(
                        imageUrl: sponsor.logoUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(sponsor.name, textAlign: TextAlign.center),
                  ],
                ),
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