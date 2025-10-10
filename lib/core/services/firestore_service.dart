import 'package:cloud_firestore/cloud_firestore.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import '../models/player_model.dart';

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
            .orderBy('name') // Ordena por nome
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
            .doc(player.id.isEmpty ? null : player.id); // Se o ID for vazio, o Firestore gera um novo

        // Se o player.id for vazio, criamos um novo Player com o ID gerado
        final playerToSave = player.id.isEmpty
            ? Player(
                id: docRef.id, // Usamos o ID que o Firestore acabou de gerar
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
    }

    // Provider para disponibilizar o FirestoreService no app
    final firestoreServiceProvider = Provider<FirestoreService>((ref) {
      return FirestoreService();
    });