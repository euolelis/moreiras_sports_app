import 'package:cloud_firestore/cloud_firestore.dart';

    class Game {
      final String id;
      final String championship; // Campeonato
      final String opponent; // Adversário
      final DateTime gameDate; // Data e Hora
      final String location; // Local
      final String status; // Agendado, Em Andamento, Encerrado

      Game({
        required this.id,
        required this.championship,
        required this.opponent,
        required this.gameDate,
        required this.location,
        required this.status,
      });

      factory Game.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
        final data = snapshot.data()!;
        return Game(
          id: snapshot.id,
          championship: data['championship'],
          opponent: data['opponent'],
          gameDate: (data['gameDate'] as Timestamp).toDate(),
          location: data['location'],
          status: data['status'],
        );
      }

      Map<String, dynamic> toFirestore() {
        return {
          'championship': championship,
          'opponent': opponent,
          'gameDate': Timestamp.fromDate(gameDate),
          'location': location,
          'status': status,
        };
      }
    }