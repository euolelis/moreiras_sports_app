import 'package:cloud_firestore/cloud_firestore.dart';

class Sponsor {
  final String id;
  final String name;
  final String logoUrl;
  final String categoryId;
  final String? description;
  final String? website;
  final String? whatsapp;

  Sponsor({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.categoryId,
    this.description,
    this.website,
    this.whatsapp,
  });

  // --- FÁBRICA CORRIGIDA ---
  factory Sponsor.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Missing data for sponsorId: ${snapshot.id}');
    }
    
    // CORREÇÃO: Adicionamos '?? '' (operador de coalescência nula) para os campos obrigatórios.
    // Isso garante que, se o campo vier nulo do Firestore, usaremos uma string vazia em vez de quebrar o app.
    return Sponsor(
      id: snapshot.id,
      name: data['name'] ?? 'Nome Indisponível',
      logoUrl: data['logoUrl'] ?? '',
      categoryId: data['categoryId'] ?? '',
      
      // Para campos opcionais (String?), o valor pode ser nulo, então está correto.
      description: data['description'],
      website: data['website'],
      whatsapp: data['whatsapp'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'categoryId': categoryId,
      'description': description,
      'website': website,
      'whatsapp': whatsapp,
    };
  }
}