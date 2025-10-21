import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/global_filter_provider.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedCategory = ref.watch(selectedCategoryProvider);

    // Variável para saber se estamos na Home
    final bool isHomePage = location == '/';

    String getTitle() {
      if (location.startsWith('/players')) return "ELENCO";
      if (location.startsWith('/games')) return "CALENDÁRIO DE JOGOS";
      if (location.startsWith('/stats')) return "ESTATÍSTICAS";
      if (location.startsWith('/news')) return "NOTÍCIAS";
      if (location.startsWith('/sponsors')) return "PATROCINADORES";
      if (location.startsWith('/about')) return "SOBRE O CLUBE";
      // O título da Home será gerenciado pela própria HomeScreen
      return "MOREIRA'S SPORT";
    }

    // A HomeScreen terá sua própria AppBar customizada, então aqui retornamos apenas o corpo.
    if (isHomePage) {
      return Scaffold(
        body: child,
        bottomNavigationBar: _buildBottomNavBar(context),
      );
    }

    // Para todas as outras telas, usamos esta AppBar padrão com o botão de voltar.
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Column(
          children: [
            const Text(
              "MOREIRA'S SPORT",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              getTitle(),
              style: TextStyle(
                fontSize: 18,
                color: Colors.amber[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        // --- LÓGICA DO BOTÃO 'leading' CORRIGIDA ---
        // Se NÃO for a Home, mostra um botão de voltar que leva para a Home.
        leading: !isHomePage
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Voltar para o Início',
                onPressed: () => context.go('/'), // Sempre volta para a Home da categoria
              )
            : null, // Na Home, o botão é controlado pela própria HomeScreen
      ),
      body: child,
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  BottomNavigationBar _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Elenco'),
        BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'Notícias'),
        BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Sobre'),
      ],
      currentIndex: _calculateSelectedIndex(context),
      onTap: (int index) => _onItemTapped(index, context),
      backgroundColor: Colors.black,
      selectedItemColor: Colors.amber[600],
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/'); break;
      case 1: context.go('/players'); break;
      case 2: context.go('/news'); break;
      case 3: context.go('/about'); break;
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/players')) return 1;
    if (location.startsWith('/news')) return 2;
    if (location.startsWith('/about')) return 3;
    return 0;
  }
}