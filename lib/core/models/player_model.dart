    import 'package:cloud_firestore/cloud_firestore.dart';

    class Player {
      final String id;
      final String name;
      final String position;
      final int number;
      final DateTime birthDate;
      final String? photoUrl;

      Player({
        required this.id,
        required this.name,
        required this.position,
        required this.number,
        required this.birthDate,
        this.photoUrl,
      });

      // Converte um Documento do Firestore para um objeto Player
      factory Player.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
        final data = snapshot.data()!;
        return Player(
          id: snapshot.id,
          name: data['name'],
          position: data['position'],
          number: data['number'],
          birthDate: (data['birthDate'] as Timestamp).toDate(),
          photoUrl: data['photoUrl'],
        );
      }

      // Converte um objeto Player para um Map para salvar no Firestore
      Map<String, dynamic> toFirestore() {
        return {
          'name': name,
          'position': position,
          'number': number,
          'birthDate': Timestamp.fromDate(birthDate),
          'photoUrl': photoUrl,
        };
      }
    }