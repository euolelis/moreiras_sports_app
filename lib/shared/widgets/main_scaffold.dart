 import 'package:flutter/material.dart';
    import 'package:go_router/go_router.dart';

    class MainScaffold extends StatelessWidget {
      final Widget child;
      const MainScaffold({super.key, required this.child});

      @override
      Widget build(BuildContext context) {
        return Scaffold(
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
            // Estilos baseados nos seus mockups
            backgroundColor: Colors.black,
            selectedItemColor: Colors.amber[600],
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
          ),
        );
      }

      // Função para navegar quando um item é tocado
      void _onItemTapped(int index, BuildContext context) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/players');
            break;
          case 2:
            // Criaremos a rota /news depois
            // context.go('/news');
            break;
        }
      }

      // Função para determinar qual item está selecionado baseado na rota atual
      int _calculateSelectedIndex(BuildContext context) {
        final String location = GoRouterState.of(context).uri.toString();
        if (location.startsWith('/players')) {
          return 1;
        }
        if (location.startsWith('/news')) {
          return 2;
        }
        return 0; // Home é o padrão
      }
    }