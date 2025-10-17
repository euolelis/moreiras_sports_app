import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MOREIRA'S SPORT"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            tooltip: 'Acesso Administrativo',
            onPressed: () {
              context.go('/admin-login');
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: <Widget>[
          _MenuButton(
            icon: Icons.people,
            label: 'ELENCO',
            onTap: () => context.go('/players'),
          ),
          _MenuButton(
            icon: Icons.event,
            label: 'JOGOS',
            onTap: () => context.go('/games'),
          ),
          _MenuButton(
            icon: Icons.bar_chart,
            label: 'ESTATÍSTICAS',
            onTap: () => context.go('/stats'),
          ),
          _MenuButton(
            icon: Icons.newspaper,
            label: 'NOTÍCIAS',
            onTap: () => context.go('/news'),
          ),
          _MenuButton(
            icon: Icons.photo_library,
            label: 'GALERIA',
            onTap: () {},
          ),
          _MenuButton(
            icon: Icons.business,
            label: 'PATROCINADORES',
            onTap: () => context.go('/sponsors'), // ATIVE AQUI
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para os botões do menu (sem alterações)
class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.amber[600]),
            const SizedBox(height: 8),
            Text(
              label,
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