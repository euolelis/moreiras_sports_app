import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Faz o upload de uma imagem de jogador e retorna a URL de download
  Future<String> uploadPlayerImage(XFile imageFile) async {
    try {
      final fileName = 'player_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('player_photos/$fileName');
      final Uint8List fileBytes = await imageFile.readAsBytes();
      await ref.putData(fileBytes);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Erro no upload da imagem: ${e.message}');
    }
  }

  // --- NOVO MÉTODO ADICIONADO ---
  // Faz o upload de um logo de patrocinador e retorna a URL de download
  Future<String> uploadSponsorLogo(XFile imageFile) async {
    try {
      final fileName = 'sponsor_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('sponsor_logos/$fileName');
      final Uint8List fileBytes = await imageFile.readAsBytes();
      await ref.putData(fileBytes);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Erro no upload do logo: ${e.message}');
    }
  }
}

// Provider para o serviço
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});