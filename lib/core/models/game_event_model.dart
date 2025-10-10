 import 'package:cloud_firestore/cloud_firestore.dart';

    enum GameEventType { gol, assistencia, cartaoAmarelo, cartaoVermelho, substituicaoEntra, substituicaoSai }

    class GameEvent {
      final String id;
      final String gameId;
      final String playerId;
      final String playerName; // Para facilitar a exibição
      final GameEventType type;
      final int minute;

      GameEvent({
        required this.id,
        required this.gameId,
        required this.playerId,
        required this.playerName,
        required this.type,
        required this.minute,
      });

      factory GameEvent.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
        final data = snapshot.data()!;
        return GameEvent(
          id: snapshot.id,
          gameId: data['gameId'],
          playerId: data['playerId'],
          playerName: data['playerName'],
          type: GameEventType.values.byName(data['type']),
          minute: data['minute'],
        );
      }

      Map<String, dynamic> toFirestore() {
        return {
          'gameId': gameId,
          'playerId': playerId,
          'playerName': playerName,
          'type': type.name,
          'minute': minute,
        };
      }
    }