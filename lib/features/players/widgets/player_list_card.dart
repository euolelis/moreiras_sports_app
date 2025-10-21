import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 1. Importe o GoRouter
import '../../../core/models/player_model.dart';

class PlayerListCard extends StatelessWidget {
  final Player player;
  const PlayerListCard({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withOpacity(0.7),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.amber[600],
          // Aqui usaremos a foto do jogador no futuro.
          // Por enquanto, um ícone ou a primeira letra do nome.
          child: Text(
            player.name.isNotEmpty ? player.name[0] : '?',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          player.name.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          '${player.position.toUpperCase()} ${player.number}',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.amber[600]),
        // 2. ATUALIZE A NAVEGAÇÃO AQUI
        onTap: () {
          // Use push para manter a rota anterior na pilha e permitir voltar.
          context.push('/players/${player.id}');
        },
      ),
    );
  }
}