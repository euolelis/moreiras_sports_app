 import 'package:flutter/material.dart';
    import 'package:firebase_core/firebase_core.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'firebase_options.dart';
    import 'navigation/app_router.dart'; // Importe o router

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
        // Assiste o provider do GoRouter
        final router = ref.watch(goRouterProvider);

        // Usa o MaterialApp.router
        return MaterialApp.router(
          title: 'Moreira\'s Sports',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              elevation: 0,
            )
          ),
          routerConfig: router,
        );
      }
    }