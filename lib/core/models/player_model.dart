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
  final String categoryId; // Novo campo obrigatório

  Player({
    required this.id,
    required this.name,
    required this.position,
    required this.number,
    required this.birthDate,
    this.photoUrl,
    this.goals = 0, // Valor padrão para novos jogadores
    this.assists = 0, // Valor padrão para novos jogadores
    required this.categoryId,
  });

  // Converte um Documento do Firestore para um objeto Player
  factory Player.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    // Verificação de segurança para caso os dados sejam nulos
    if (data == null) {
      throw StateError('Missing data for playerId: ${snapshot.id}');
    }
    
    return Player(
      id: snapshot.id,
      name: data['name'] ?? '',
      position: data['position'] ?? '',
      number: data['number'] ?? 0,
      // CORREÇÃO: Lida com o tipo Timestamp do Firestore
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      photoUrl: data['photoUrl'],
      goals: data['goals'] ?? 0,
      assists: data['assists'] ?? 0,
      categoryId: data['categoryId'] ?? '',
    );
  }

  // Converte um objeto Player para um Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'position': position,
      'number': number,
      // CORREÇÃO: Converte DateTime para Timestamp do Firestore
      'birthDate': Timestamp.fromDate(birthDate),
      'photoUrl': photoUrl,
      'goals': goals,
      'assists': assists,
      'categoryId': categoryId,
    };
  }
}