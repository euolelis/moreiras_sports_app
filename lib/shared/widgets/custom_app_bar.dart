import 'package:flutter/material.dart';
    import 'package:go_router/go_router.dart';

    class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
      final String title;
      final bool isMainScreen; // Parâmetro para saber se é uma tela principal

      const CustomAppBar({
        super.key,
        required this.title,
        this.isMainScreen = false,
      });

      @override
      Widget build(BuildContext context) {
        return AppBar(
          title: Text(title),
          centerTitle: true,
          // Lógica para mostrar o botão de voltar
          leading: !isMainScreen && context.canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                )
              : null, // Não mostra nada se for tela principal
        );
      }

      @override
      Size get preferredSize => const Size.fromHeight(kToolbarHeight);
    }