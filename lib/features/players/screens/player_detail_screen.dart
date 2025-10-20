import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart'; // Importe o GoRouter
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/player_model.dart';
import '../../../core/services/firestore_service.dart';

final playerDetailProvider = FutureProvider.autoDispose.family<Player, String>((ref, playerId) {
  return ref.watch(firestoreServiceProvider).getPlayerById(playerId);
});

class PlayerDetailScreen extends ConsumerWidget {
  final String playerId;
  const PlayerDetailScreen({super.key, required this.playerId});

  int _calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _launchSocialUrl(String? url, BuildContext context) async {
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir o link: $url')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma rede social cadastrada para este jogador.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsyncValue = ref.watch(playerDetailProvider(playerId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: playerAsyncValue.when(
        data: (player) {
          final age = _calculateAge(player.birthDate);
          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (player.photoUrl != null && player.photoUrl!.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: player.photoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[900]),
                          errorWidget: (context, url, error) => const Icon(Icons.person, size: 150, color: Colors.grey),
                        )
                      else
                        Container(color: Colors.grey[900], child: const Icon(Icons.person, size: 150, color: Colors.grey)),
                      
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Text(
                              player.name.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                            ),
                            Text(
                              '#${player.number} - ${player.position.toUpperCase()}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 22, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Container(height: 4, color: Colors.amber[600]),

                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _InfoTile(label: 'DATA DE NASCIMENTO', value: DateFormat('dd/MM/yyyy').format(player.birthDate)),
                            _InfoTile(label: 'IDADE', value: age.toString()),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatTile(icon: Icons.sports_soccer, label: 'GOLS', value: player.goals.toString()),
                            _StatTile(icon: Icons.assistant, label: 'ASSISTÊNCIAS', value: player.assists.toString()),
                            _StatTile(icon: Icons.event_available, label: 'JOGOS', value: player.gamesPlayed.toString()),
                            _StatTile(icon: Icons.star, label: 'CRAQUE DO JOGO', value: player.manOfTheMatch.toString()),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _ActionButton(icon: Icons.photo_library, label: 'FOTOS/VÍDEOS', onTap: () {}),
                            // --- onTap ATIVADO AQUI ---
                            _ActionButton(
                              icon: Icons.bar_chart,
                              label: 'ESTATÍSTICAS',
                              onTap: () => context.go('/players/${player.id}/stats', extra: player),
                            ),
                            _ActionButton(
                              icon: Icons.public,
                              label: 'REDES SOCIAIS',
                              onTap: () => _launchSocialUrl(player.socialUrl, context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Erro ao carregar dados do jogador: $err")),
      ),
    );
  }
}

// --- WIDGETS AUXILIARES ---

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12, letterSpacing: 1.1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.amber[600], size: 20),
            const SizedBox(width: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12, letterSpacing: 1.1)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.amber[600]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.amber[600]),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.amber[600], fontSize: 10)),
          ],
        ),
      ),
    );
  }
}