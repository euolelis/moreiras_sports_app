import 'package:cloud_firestore/cloud_firestore.dart';

    class Category {
      final String id;
      final String name; // Ex: "Sub-11"

      Category({required this.id, required this.name});

      factory Category.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
        final data = snapshot.data()!;
        return Category(id: snapshot.id, name: data['name']);
      }

      Map<String, dynamic> toFirestore() => {'name': name};
    }