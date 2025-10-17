import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'custom_app_bar.dart'; // 1. Importe o novo widget

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    
    // 2. Define o título e se é uma tela principal baseado na rota
    String title = "MOREIRA'S SPORT";
    bool isMainScreen = true;

    if (location.startsWith('/players')) {
      title = "MOREIRA'S ELENCO";
      isMainScreen = true;
    } else if (location.startsWith('/news')) {
      title = "NOTÍCIAS";
      isMainScreen = true;
    }
    // Adicione outras telas principais aqui (ex: /games, /stats)

    return Scaffold(
      // 3. Usa o AppBar customizado
      appBar: CustomAppBar(
        title: title,
        isMainScreen: isMainScreen,
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Elenco',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Notícias',
          ),
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

  // As funções auxiliares permanecem as mesmas
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
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/players')) {
      return 1;
    }
    if (location.startsWith('/news')) {
      return 2;
    }
    return 0;
  }
}