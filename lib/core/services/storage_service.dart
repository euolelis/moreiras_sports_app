import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- MÉTODO CORRIGIDO E MULTIPLATAFORMA ---
  Future<String> uploadPlayerImage(XFile imageFile) async {
    try {
      // Cria uma referência única para o arquivo
      final fileName = 'player_photos/player_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);

      // Lê o arquivo como um array de bytes (Uint8List).
      final Uint8List fileBytes = await imageFile.readAsBytes();

      // Faz o upload dos bytes para o Firebase Storage, especificando o tipo de conteúdo.
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      
      await ref.putData(fileBytes, metadata);

      // Retorna a URL de download para salvar no Firestore
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Erro no upload da imagem: ${e.message}');
    }
  }
  // --- FIM DO MÉTODO CORRIGIDO ---

  // O método para upload de logo de patrocinador permanece o mesmo
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

// Provider (sem alterações)
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});