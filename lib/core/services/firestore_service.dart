import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_model.dart';
import '../models/game_model.dart';
import '../models/game_event_model.dart';
import '../models/news_model.dart';
import '../models/category_model.dart';
import '../models/sponsor_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _schoolId = "moreiras-sport";

  // --- PLAYERS ---

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
            photoUrl: player.photoUrl,
            goals: player.goals,
            assists: player.assists,
            categoryId: player.categoryId,
            gamesPlayed: player.gamesPlayed,
            manOfTheMatch: player.manOfTheMatch,
            socialUrl: player.socialUrl,
            yellowCards: player.yellowCards,
            redCards: player.redCards)
        : player;

    await docRef.set(playerToSave.toFirestore());
  }

  Future<void> deletePlayer(String playerId) async {
    await _db
        .collection('schools')
        .doc(_schoolId)
        .collection('players')
        .doc(playerId)
        .delete();
  }

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

  // --- GAMES ---
  
  Stream<List<Game>> getGamesStream() {
    return _db
        .collection('schools')
        .doc(_schoolId)
        .collection('games')
        .orderBy('gameDate', descending: true)
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

    final gameToSave = game.id.isEmpty
        ? Game(
            id: docRef.id,
            championship: game.championship,
            opponent: game.opponent,
            gameDate: game.gameDate,
            location: game.location,
            status: game.status,
            ourScore: game.ourScore,
            opponentScore: game.opponentScore,
            categoryId: game.categoryId)
        : game;

    await docRef.set(gameToSave.toFirestore());
  }

  Future<void> updateGameScore(String gameId, int ourScore, int opponentScore) async {
    await _db
        .collection('schools')
        .doc(_schoolId)
        .collection('games')
        .doc(gameId)
        .update({
      'ourScore': ourScore,
      'opponentScore': opponentScore,
      'status': 'Encerrado',
    });
  }

  Future<Game> getGameById(String gameId) async {
    final docSnapshot = await _db
        .collection('schools')
        .doc(_schoolId)
        .collection('games')
        .doc(gameId)
        .get();
    if (docSnapshot.exists) {
      return Game.fromFirestore(docSnapshot);
    } else {
      throw Exception('Jogo não encontrado');
    }
  }

  // --- GAME EVENTS ---

  Future<void> addGameEvent(GameEvent event) async {
    final batch = _db.batch();
    final eventRef = _db
        .collection('schools')
        .doc(_schoolId)
        .collection('game_events')
        .doc();
    
    final eventWithId = GameEvent(
      id: eventRef.id, 
      gameId: event.gameId, 
      playerId: event.playerId, 
      playerName: event.playerName, 
      type: event.type, 
      minute: event.minute
    );

    batch.set(eventRef, eventWithId.toFirestore());

    if (event.type == GameEventType.gol ||
        event.type == GameEventType.assistencia ||
        event.type == GameEventType.cartaoAmarelo ||
        event.type == GameEventType.cartaoVermelho) {
          
      final playerRef = _db
          .collection('schools')
          .doc(_schoolId)
          .collection('players')
          .doc(event.playerId);

      String fieldToIncrement;
      switch (event.type) {
        case GameEventType.gol:
          fieldToIncrement = 'goals';
          break;
        case GameEventType.assistencia:
          fieldToIncrement = 'assists';
          break;
        case GameEventType.cartaoAmarelo:
          fieldToIncrement = 'yellowCards';
          break;
        case GameEventType.cartaoVermelho:
          fieldToIncrement = 'redCards';
          break;
        default:
          await batch.commit();
          return;
      }
      
      batch.update(playerRef, {fieldToIncrement: FieldValue.increment(1)});
    }

    await batch.commit();
  }

  Stream<List<GameEvent>> getEventsForGameStream(String gameId) {
    return _db
        .collection('schools')
        .doc(_schoolId)
        .collection('game_events')
        .where('gameId', isEqualTo: gameId)
        .orderBy('minute')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GameEvent.fromFirestore(doc))
            .toList());
  }

  // --- NEWS ---
  Stream<List<News>> getNewsStream() {
    return _db
        .collection('schools')
        .doc(_schoolId)
        .collection('news')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => News.fromFirestore(doc)).toList());
  }

  Future<void> setNews(News newsItem) async {
    final docRef = _db
        .collection('schools')
        .doc(_schoolId)
        .collection('news')
        .doc(newsItem.id.isEmpty ? null : newsItem.id);

    final newsToSave = newsItem.id.isEmpty
        ? News(
            id: docRef.id,
            title: newsItem.title,
            content: newsItem.content,
            createdAt: newsItem.createdAt,
            imageUrl: newsItem.imageUrl)
        : newsItem;

    await docRef.set(newsToSave.toFirestore());
  }

  Future<void> deleteNews(String newsId) async {
    await _db
        .collection('schools')
        .doc(_schoolId)
        .collection('news')
        .doc(newsId)
        .delete();
  }

  // --- CATEGORIES ---
  Stream<List<Category>> getCategoriesStream() {
    return _db
        .collection('schools')
        .doc(_schoolId)
        .collection('categories')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromFirestore(doc))
            .toList());
  }

  Future<void> setCategory(Category category) async {
    final docRef = _db
        .collection('schools')
        .doc(_schoolId)
        .collection('categories')
        .doc(category.id.isEmpty ? null : category.id);

    final categoryToSave = category.id.isEmpty
        ? Category(id: docRef.id, name: category.name)
        : category;

    await docRef.set(categoryToSave.toFirestore());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _db
        .collection('schools')
        .doc(_schoolId)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }

  // --- SPONSORS ---
  Stream<List<Sponsor>> getSponsorsStream() {
    return _db
        .collection('schools')
        .doc(_schoolId)
        .collection('sponsors')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Sponsor.fromFirestore(doc)).toList());
  }

  Future<void> setSponsor(Sponsor sponsor) async {
    final docRef = _db
        .collection('schools')
        .doc(_schoolId)
        .collection('sponsors')
        .doc(sponsor.id.isEmpty ? null : sponsor.id);

    final sponsorToSave = sponsor.id.isEmpty
        ? Sponsor(
            id: docRef.id,
            name: sponsor.name,
            logoUrl: sponsor.logoUrl,
            website: sponsor.website)
        : sponsor;

    await docRef.set(sponsorToSave.toFirestore());
  }

  Future<void> deleteSponsor(String sponsorId) async {
    await _db
        .collection('schools')
        .doc(_schoolId)
        .collection('sponsors')
        .doc(sponsorId)
        .delete();
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});