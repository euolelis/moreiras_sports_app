import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel do Admin"),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              context.go('/landing'); // Volta para a tela de entrada
            },
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: <Widget>[
          _AdminMenuButton(
            icon: Icons.people_alt,
            label: 'Elenco',
            onTap: () => context.go('/admin/manage-players'),
          ),
          _AdminMenuButton(
            icon: Icons.calendar_today,
            label: 'Jogos',
            onTap: () => context.go('/admin/manage-games'),
          ),
          // --- NOVO BOTÃO ADICIONADO ---
          _AdminMenuButton(
            icon: Icons.category,
            label: 'Categorias',
            onTap: () => context.go('/admin/manage-categories'),
          ),
          // --- FIM DO NOVO BOTÃO ---
          _AdminMenuButton(
            icon: Icons.newspaper,
            label: 'Notícias',
            onTap: () => context.go('/admin/manage-news'),
          ),
          _AdminMenuButton(
            icon: Icons.business_center,
            label: 'Patrocinadores',
            onTap: () {
              // Navegar para gerenciar patrocinadores
            },
          ),
          _AdminMenuButton(
            icon: Icons.photo_album,
            label: 'Galeria',
            onTap: () {
              // Navegar para gerenciar galeria
            },
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para os botões do menu do admin
class _AdminMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AdminMenuButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.amber[600]),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.amber[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}