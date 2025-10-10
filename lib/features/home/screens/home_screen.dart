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
        // --- SEÇÃO ADICIONADA ---
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            tooltip: 'Acesso Administrativo', // Texto que aparece ao passar o mouse por cima
            onPressed: () {
              context.go('/admin-login');
            },
          ),
        ],
        // --- FIM DA SEÇÃO ---
      ),
      body: GridView.count(
        crossAxisCount: 2, // 2 colunas
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: <Widget>[
          _MenuButton(
            icon: Icons.people,
            label: 'ELENCO',
            onTap: () => context.go('/players'),
          ),
          _MenuButton(icon: Icons.event, label: 'JOGOS', onTap: () {}),
          _MenuButton(icon: Icons.bar_chart, label: 'ESTATÍSTICAS', onTap: () {}),
          _MenuButton(icon: Icons.business, label: 'PATROCINADORES', onTap: () {}),
          _MenuButton(icon: Icons.photo_library, label: 'GALERIA', onTap: () {}),
          _MenuButton(icon: Icons.video_library, label: 'VÍDEOS', onTap: () {}),
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