 import 'package:flutter/material.dart';

    Future<bool> showConfirmDialog({
      required BuildContext context,
      required String title,
      required String content,
    }) async {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Retorna false
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true), // Retorna true
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );
      // Se o usuário fechar o dialog sem clicar, retorna false
      return result ?? false;
    }