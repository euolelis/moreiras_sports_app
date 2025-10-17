import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  final String id;
  final String championship;
  final String opponent;
  final DateTime gameDate;
  final String location;
  final String status;
  final int? ourScore;
  final int? opponentScore;
  final String categoryId; // <-- NOVO CAMPO

  Game({
    required this.id,
    required this.championship,
    required this.opponent,
    required this.gameDate,
    required this.location,
    required this.status,
    this.ourScore,
    this.opponentScore,
    required this.categoryId, // <-- NOVO PARÂMETRO OBRIGATÓRIO
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
      ourScore: data['ourScore'],
      opponentScore: data['opponentScore'],
      categoryId: data['categoryId'] ?? '', // <-- LER DO FIRESTORE
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'championship': championship,
      'opponent': opponent,
      'gameDate': Timestamp.fromDate(gameDate),
      'location': location,
      'status': status,
      'ourScore': ourScore,
      'opponentScore': opponentScore,
      'categoryId': categoryId, // <-- SALVAR NO FIRESTORE
    };
  }
}