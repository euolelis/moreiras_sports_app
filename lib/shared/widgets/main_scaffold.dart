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

    String getTitle() {
      if (location.startsWith('/players')) return "ELENCO";
      if (location.startsWith('/games')) return "CALENDÁRIO DE JOGOS";
      if (location.startsWith('/stats')) return "ESTATÍSTICAS";
      if (location.startsWith('/news')) return "NOTÍCIAS";
      if (location.startsWith('/sponsors')) return "PATROCINADORES";
      if (location.startsWith('/about')) return "SOBRE O CLUBE"; // Título para a nova tela
      return selectedCategory?.name.toUpperCase() ?? "MOREIRA'S SPORT";
    }

    final bool isHomePage = location == '/';

    return Scaffold(
      appBar: AppBar(
        title: Text(getTitle()),
        centerTitle: true,
        leading: !isHomePage
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Voltar para o Início',
                onPressed: () => context.go('/'),
              )
            : null,
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        // --- MUDANÇA AQUI: ADICIONA O NOVO ITEM ---
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Elenco'),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'Notícias'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Sobre o Clube'), // NOVO ITEM
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int index) => _onItemTapped(index, context),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber[600],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/players');
        break;
      case 2:
        context.go('/news');
        break;
      case 3:
        context.go('/about'); // NAVEGA PARA A TELA "SOBRE"
        break;
    }
  }

  // --- MUDANÇA AQUI: ATUALIZA A LÓGICA DE SELEÇÃO ---
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/players')) return 1;
    if (location.startsWith('/news')) return 2;
    if (location.startsWith('/about')) return 3; // MARCA O ITEM "SOBRE" COMO ATIVO
    return 0; // Padrão é 'Início'
  }
}