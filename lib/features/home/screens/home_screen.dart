import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/global_filter_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      // --- NOVA APPBAR CUSTOMIZADA ---
      appBar: AppBar(
        elevation: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "MOREIRA'S SPORT",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 2),
            if (selectedCategory != null)
              Text(
                selectedCategory.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.amber[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.swap_horiz),
          tooltip: 'Trocar Categoria',
          onPressed: () {
            ref.read(selectedCategoryProvider.notifier).state = null;
            context.go('/select-category');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Sobre o Clube',
            onPressed: () => context.go('/about'),
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            tooltip: 'Acesso Administrativo',
            onPressed: () => context.go('/admin-login'),
          ),
        ],
      ),
      // --- FIM DA NOVA APPBAR ---
      
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 2,
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
            onTap: () => context.go('/sponsors'),
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