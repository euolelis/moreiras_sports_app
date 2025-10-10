import 'package:flutter/material.dart';
    import 'package:firebase_core/firebase_core.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'firebase_options.dart';
    import 'navigation/app_router.dart';
    import 'shared/theme/app_theme.dart'; // <-- 1. IMPORTE O TEMA

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

        return MaterialApp.router(
          title: 'Moreira\'s Sports',
          theme: appTheme, // <-- 2. APLIQUE O TEMA AQUI
          routerConfig: router,
        );
      }
    }