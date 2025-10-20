import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/sponsor_model.dart';

class SponsorDetailScreen extends StatelessWidget {
  final Sponsor sponsor;
  const SponsorDetailScreen({super.key, required this.sponsor});

  // Função para abrir links
  Future<void> _launchURL(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sponsor.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            SizedBox(
              height: 150,
              child: CachedNetworkImage(
                imageUrl: sponsor.logoUrl,
                fit: BoxFit.contain,
                errorWidget: (c, u, e) => const Icon(Icons.business, size: 80),
              ),
            ),
            const SizedBox(height: 24),
            // Nome
            Text(
              sponsor.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),
            // Descrição (Merchan)
            if (sponsor.description != null && sponsor.description!.isNotEmpty)
              Text(sponsor.description!),
            const SizedBox(height: 24),
            // Botões de Ação
            if (sponsor.website != null && sponsor.website!.isNotEmpty)
              ElevatedButton.icon(
                icon: const Icon(Icons.public),
                label: const Text('Acessar Site'),
                onPressed: () => _launchURL(sponsor.website!),
              ),
            const SizedBox(height: 12),
            if (sponsor.whatsapp != null && sponsor.whatsapp!.isNotEmpty)
              ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('Contato via WhatsApp'),
                onPressed: () => _launchURL('https://wa.me/${sponsor.whatsapp}'),
              ),
          ],
        ),
      ),
    );
  }
}