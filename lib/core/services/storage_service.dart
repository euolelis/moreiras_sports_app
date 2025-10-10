 import 'dart:typed_data';
    import 'package:firebase_storage/firebase_storage.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:image_picker/image_picker.dart';

    class StorageService {
      final FirebaseStorage _storage = FirebaseStorage.instance;

      // Faz o upload de uma imagem e retorna a URL de download
      Future<String> uploadPlayerImage(XFile imageFile) async {
        try {
          // Cria uma referência única para o arquivo usando o timestamp
          final fileName = 'player_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final ref = _storage.ref().child('player_photos/$fileName');

          // Lê o arquivo como bytes
          final Uint8List fileBytes = await imageFile.readAsBytes();

          // Faz o upload dos bytes
          await ref.putData(fileBytes);

          // Retorna a URL de download
          final downloadUrl = await ref.getDownloadURL();
          return downloadUrl;
        } on FirebaseException catch (e) {
          // Trata possíveis erros de upload
          throw Exception('Erro no upload da imagem: ${e.message}');
        }
      }
    }

    // Provider para o serviço
    final storageServiceProvider = Provider<StorageService>((ref) {
      return StorageService();
    });