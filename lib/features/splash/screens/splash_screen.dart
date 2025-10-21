import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// 1. Adicionamos o 'TickerProviderStateMixin' para controlar a animação
class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // 2. Criamos um controlador para a animação
  late final AnimationController _controller;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _logoScale;
  late final Animation<double> _sloganOpacity;
  late final Animation<Offset> _sloganSlide;

  @override
  void initState() {
    super.initState();

    // 3. Configuramos o controlador e as animações
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500), // Duração total da animação
      vsync: this,
    );

    // Animação do Título (aparece nos primeiros 50% do tempo)
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    // Animação do Logo (aparece entre 30% e 70% do tempo)
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7, curve: Curves.elasticOut)),
    );

    // Animação do Slogan (aparece nos últimos 50% do tempo)
    _sloganOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );
    _sloganSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    // Inicia a animação
    _controller.forward();

    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose(); // É muito importante limpar o controlador
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.go('/landing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash_background.png',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent, Colors.black.withOpacity(0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
              child: Column(
                children: [
                  // 4. Aplicamos as animações aos widgets
                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleOpacity,
                      child: const Text(
                        "MOREIRA'S\nSPORT",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                          shadows: [Shadow(blurRadius: 10.0, color: Colors.black54)],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ScaleTransition(
                    scale: _logoScale,
                    child: Image.asset(
                      'assets/images/logo_circular.png',
                      height: 120,
                    ),
                  ),
                  const Spacer(),
                  SlideTransition(
                    position: _sloganSlide,
                    child: FadeTransition(
                      opacity: _sloganOpacity,
                      child: const Text(
                        "O FUTEBOL CRIA CAMPEÕES!",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          shadows: [Shadow(blurRadius: 8.0, color: Colors.black87)],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}