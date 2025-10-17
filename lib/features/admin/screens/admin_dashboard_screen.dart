import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';

// 1. Convertido para ConsumerStatefulWidget
class AdminDashboardScreen extends ConsumerStatefulWidget {
  final String? message; // Recebe a mensagem opcional da navegação
  const AdminDashboardScreen({super.key, this.message});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  
  // 2. Adicionado initState para mostrar o SnackBar
  @override
  void initState() {
    super.initState();
    // Se uma mensagem foi passada através do parâmetro 'extra' do GoRouter...
    if (widget.message != null) {
      // Atrasamos a execução para garantir que o Scaffold da tela já esteja construído
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.message!)),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // O conteúdo do build permanece o mesmo, mas agora está dentro da classe State.
    // O 'ref' está disponível como uma propriedade da classe ConsumerState.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel do Admin"),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              context.go('/landing');
            },
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: <Widget>[
          _AdminMenuButton(
            icon: Icons.people_alt,
            label: 'Elenco',
            onTap: () => context.go('/admin/manage-players'),
          ),
          _AdminMenuButton(
            icon: Icons.calendar_today,
            label: 'Jogos',
            onTap: () => context.go('/admin/manage-games'),
          ),
          _AdminMenuButton(
            icon: Icons.category,
            label: 'Categorias',
            onTap: () => context.go('/admin/manage-categories'),
          ),
          _AdminMenuButton(
            icon: Icons.newspaper,
            label: 'Notícias',
            onTap: () => context.go('/admin/manage-news'),
          ),
          _AdminMenuButton(
            icon: Icons.business_center,
            label: 'Patrocinadores',
            onTap: () => context.go('/admin/manage-sponsors'), // ATIVE AQUI
          ),
          _AdminMenuButton(
            icon: Icons.photo_album,
            label: 'Galeria',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// O widget auxiliar _AdminMenuButton não precisa de alterações.
class _AdminMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AdminMenuButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.amber[600]),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.amber[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}