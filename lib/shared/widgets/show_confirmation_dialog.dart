import 'package:flutter/material.dart';

    Future<bool> showConfirmationDialog(BuildContext context, {
      required String title,
      required String content,
      String confirmText = 'Confirmar',
    }) async {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton( // Usa o botão de maior destaque para a confirmação
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        ),
      );
      return result ?? false; // Retorna false se o dialog for fechado de outra forma
    }