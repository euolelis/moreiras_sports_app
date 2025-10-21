import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Imagem de Fundo
          Image.asset(
            'assets/images/landing_background.png', // <-- ADICIONE UMA IMAGEM DE FUNDO AQUI
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.4), // Escurece a imagem
            colorBlendMode: BlendMode.darken,
          ),

          // 2. Conteúdo Central com Animação
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    // Logo
                    Image.asset('assets/images/logo_circular.png', height: 120),
                    const SizedBox(height: 16),
                    // Título
                    Text(
                      "Moreira's Sports",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(blurRadius: 10, color: Colors.black54)
                        ],
                      ),
                    ),
                    const Spacer(flex: 3),
                    // Botão Principal
                    ElevatedButton(
                      onPressed: () => context.go('/select-category'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Acessar como Visitante', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),
                    // Botão Secundário
                    TextButton(
                      onPressed: () => context.go('/admin-login'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        foregroundColor: Colors.white70,
                      ),
                      child: const Text('Acesso Administrativo'),
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}