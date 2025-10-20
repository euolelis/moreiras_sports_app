import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe o User
import 'firebase_options.dart';
import 'navigation/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'core/services/auth_service.dart'; // Importe o auth_service

// O authStateProvider foi movido para cá (ou pode ser mantido no app_router.dart)
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    // --- LÓGICA DE NAVEGAÇÃO CENTRALIZADA ---
    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      final user = next.value;
      if (user != null) {
        // Se o usuário está logado, SEMPRE vá para o painel do admin.
        router.go('/admin');
      } else {
        // Se o usuário fez logout, SEMPRE vá para a tela de login.
        final currentLocation = router.routerDelegate.currentConfiguration.uri.toString();
        // Só redireciona se ele estava em uma rota de admin, para evitar
        // redirecionamentos indesejados ao abrir o app pela primeira vez.
        if (currentLocation.startsWith('/admin')) {
          router.go('/admin-login');
        }
      }
    });
    // --- FIM DA LÓGICA ---

    return MaterialApp.router(
      title: 'Moreira\'s Sports',
      theme: appTheme,
      
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      locale: const Locale('pt', 'BR'),

      routerConfig: router,
    );
  }
}