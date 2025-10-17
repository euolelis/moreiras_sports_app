import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  final String id;
  final String name;
  final String position;
  final int number;
  final DateTime birthDate;
  final String? photoUrl;
  final int goals;
  final int assists;
  final String categoryId;
  final int gamesPlayed;
  final int manOfTheMatch;
  final String? socialUrl;
  // Novos campos para cartões
  final int yellowCards;
  final int redCards;

  Player({
    required this.id,
    required this.name,
    required this.position,
    required this.number,
    required this.birthDate,
    this.photoUrl,
    this.goals = 0,
    this.assists = 0,
    required this.categoryId,
    this.gamesPlayed = 0,
    this.manOfTheMatch = 0,
    this.socialUrl,
    // Adicionados ao construtor com valor padrão
    this.yellowCards = 0,
    this.redCards = 0,
  });

  factory Player.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Missing data for playerId: ${snapshot.id}');
    }
    
    return Player(
      id: snapshot.id,
      name: data['name'] ?? '',
      position: data['position'] ?? '',
      number: data['number'] ?? 0,
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      photoUrl: data['photoUrl'],
      goals: data['goals'] ?? 0,
      assists: data['assists'] ?? 0,
      categoryId: data['categoryId'] ?? '',
      gamesPlayed: data['gamesPlayed'] ?? 0,
      manOfTheMatch: data['manOfTheMatch'] ?? 0,
      socialUrl: data['socialUrl'],
      // Lendo os novos campos do Firestore, com fallback para 0
      yellowCards: data['yellowCards'] ?? 0,
      redCards: data['redCards'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'position': position,
      'number': number,
      'birthDate': Timestamp.fromDate(birthDate),
      'photoUrl': photoUrl,
      'goals': goals,
      'assists': assists,
      'categoryId': categoryId,
      'gamesPlayed': gamesPlayed,
      'manOfTheMatch': manOfTheMatch,
      'socialUrl': socialUrl,
      // Adicionando os novos campos para salvar no Firestore
      'yellowCards': yellowCards,
      'redCards': redCards,
    };
  }
}