import 'package:cloud_firestore/cloud_firestore.dart';

class Sponsor {
  final String id;
  final String name;
  final String logoUrl;
  final String? website; // Opcional: link para o site do patrocinador

  Sponsor({
    required this.id,
    required this.name,
    required this.logoUrl,
    this.website,
  });

  factory Sponsor.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Sponsor(
      id: snapshot.id,
      name: data['name'],
      logoUrl: data['logoUrl'],
      website: data['website'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'website': website,
    };
  }
}