import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_model.dart';
import '../models/game_model.dart'; // 1. Adicione o import para o GameModel

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _schoolId = "moreiras-sport"; // Hardcoded para o projeto piloto

  // --- PLAYERS ---

  // Pega um stream da lista de jogadores para exibir em tempo real
  Stream<List<Player>> getPlayersStream() {
    return _db
        .collection('schools')
        .doc(_schoolId)
        .collection('players')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Player.fromFirestore(doc))
            .toList());
  }

  // Salva (cria ou atualiza) um jogador
  Future<void> setPlayer(Player player) async {
    final docRef = _db
        .collection('schools')
        .doc(_schoolId)
        .collection('players')
        .doc(player.id.isEmpty ? null : player.id);

    final playerToSave = player.id.isEmpty
        ? Player(
            id: docRef.id,
            name: player.name,
            position: player.position,
            number: player.number,
            birthDate: player.birthDate,
            photoUrl: player.photoUrl)
        : player;

    await docRef.set(playerToSave.toFirestore());
  }

  // Deleta um jogador
  Future<void> deletePlayer(String playerId) async {
    await _db
        .collection('schools')
        .doc(_schoolId)
        .collection('players')
        .doc(playerId)
        .delete();
  }

  // Pega um único jogador pelo seu ID
  Future<Player> getPlayerById(String playerId) async {
    try {
      final docSnapshot = await _db
          .collection('schools')
          .doc(_schoolId)
          .collection('players')
          .doc(playerId)
          .get();

      if (docSnapshot.exists) {
        return Player.fromFirestore(docSnapshot);
      } else {
        throw Exception('Jogador não encontrado');
      }
    } catch (e) {
      throw Exception('Erro ao buscar jogador: $e');
    }
  }

  // --- GAMES --- (2. Nova seção e métodos adicionados)
  Stream<List<Game>> getGamesStream() {
    return _db
        .collection('schools')
        .doc(_schoolId)
        .collection('games')
        .orderBy('gameDate', descending: true) // Mais recentes primeiro
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Game.fromFirestore(doc)).toList());
  }

  Future<void> setGame(Game game) async {
    final docRef = _db
        .collection('schools')
        .doc(_schoolId)
        .collection('games')
        .doc(game.id.isEmpty ? null : game.id);

    // Lógica para garantir que o ID está no documento
    final gameToSave = game.id.isEmpty
        ? Game(
            id: docRef.id,
            championship: game.championship,
            opponent: game.opponent,
            gameDate: game.gameDate,
            location: game.location,
            status: game.status)
        : game;

    await docRef.set(gameToSave.toFirestore());
  }
}

// Provider para disponibilizar o FirestoreService no app
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});