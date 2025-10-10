import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:go_router/go_router.dart';
    import 'package:lottie/lottie.dart';

    class SplashScreen extends StatefulWidget {
      const SplashScreen({super.key});

      @override
      State<SplashScreen> createState() => _SplashScreenState();
    }

    class _SplashScreenState extends State<SplashScreen> {
      @override
      void initState() {
        super.initState();
        _initializeApp();
      }

      Future<void> _initializeApp() async {
        // Simula um tempo de carregamento para a logo aparecer (bom para UX)
        await Future.delayed(const Duration(seconds: 3));

        // Após o tempo, navega para a home, substituindo a splash da pilha
        if (mounted) {
          context.go('/');
        }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Lottie.asset(
              'assets/animations/soccer_ball.json',
              width: 200,
              height: 200,
              fit: BoxFit.fill,
              ),
                const Icon(Icons.shield, size: 80, color: Colors.amber),
                const SizedBox(height: 20),
                const Text(
                  "Moreira's Sports",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                //const CircularProgressIndicator(
                  //valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                //),
              ],
            ),
          ),
        );
      }
    }