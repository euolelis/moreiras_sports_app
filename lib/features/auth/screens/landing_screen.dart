import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- ÍCONE SUBSTITUÍDO PELO LOGO ---
              Image.asset('assets/images/logo.png', height: 120),
              const SizedBox(height: 20),
              const Text(
                "Bem-vindo ao\nMoreira's Sports",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () => context.go('/select-category'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Acessar como Visitante'),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => context.go('/admin-login'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                child: const Text('Acesso Administrativo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}