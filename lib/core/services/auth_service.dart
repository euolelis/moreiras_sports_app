import 'package:firebase_auth/firebase_auth.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';

    class AuthService {
      final FirebaseAuth _auth = FirebaseAuth.instance;

      // Stream para ouvir o estado de autenticação
      Stream<User?> get authStateChanges => _auth.authStateChanges();

      // Método de Login
      Future<void> signInWithEmailAndPassword(String email, String password) async {
        try {
          await _auth.signInWithEmailAndPassword(email: email, password: password);
        } on FirebaseAuthException catch (e) {
          // Aqui você pode tratar erros específicos (usuário não encontrado, senha errada)
          throw Exception('Erro ao fazer login: ${e.message}');
        }
      }

      // Método de Logout
      Future<void> signOut() async {
        await _auth.signOut();
      }
    }

    // Provider para disponibilizar o AuthService no app
    final authServiceProvider = Provider<AuthService>((ref) {
      return AuthService();
    });