import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  final String id;
  final String championship;
  final String opponent;
  final DateTime gameDate;
  final String location;
  final String status;
  // Novos campos para o placar
  final int? ourScore;
  final int? opponentScore;

  Game({
    required this.id,
    required this.championship,
    required this.opponent,
    required this.gameDate,
    required this.location,
    required this.status,
    // Adicionados ao construtor
    this.ourScore,
    this.opponentScore,
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
      // Lendo os novos campos do Firestore
      ourScore: data['ourScore'],
      opponentScore: data['opponentScore'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'championship': championship,
      'opponent': opponent,
      'gameDate': Timestamp.fromDate(gameDate),
      'location': location,
      'status': status,
      // Adicionando os novos campos para salvar no Firestore
      'ourScore': ourScore,
      'opponentScore': opponentScore,
    };
  }
}