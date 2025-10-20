import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Função auxiliar para abrir o WhatsApp
  Future<void> _launchWhatsApp(String phone) async {
    // Chama a função genérica de URL
    await _launchURL('https://wa.me/$phone');
  }

  // --- NOVA FUNÇÃO GENÉRICA PARA ABRIR LINKS ---
  Future<void> _launchURL(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Opcional: Adicionar um SnackBar ou log de erro aqui
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sobre o Clube"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Seção: Nossa Missão (Sem alterações) ---
          _buildSectionCard(
            context: context,
            title: "Transformando nossa missão em realidade",
            content: "A Moreira's Sport é um celeiro de talentos do futebol, com 25 anos de experiência na formação de jovens atletas. Nosso compromisso é preparar esses jovens para o mundo profissional, mantendo viva a essência do futebol brasileiro.",
            icon: Icons.flag,
          ),
          const SizedBox(height: 16),

          // --- Seção: Nossa História (Sem alterações) ---
          _buildSectionCard(
            context: context,
            title: "Nossa História",
            content: "Desde 1997, a Moreira Sports vem formando atletas de alto nível, com uma metodologia baseada na experiência do fundador Nilton de Jesus Moreira, ex-goleiro profissional. Hoje, somos reconhecidos nacionalmente pela excelência na formação de jogadores.",
            icon: Icons.history_edu,
          ),
          const SizedBox(height: 16),

          // --- Seção: Conquistas e Destaques (Com novo layout) ---
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Conquistas e Destaques", style: Theme.of(context).textTheme.titleLarge),
                  const Divider(height: 20),
                  // Usando o novo widget _buildHighlight
                  _buildHighlight(context, "Casemiro", "São Paulo, Real Madrid, Seleção Brasileira"),
                  _buildHighlight(context, "Ricardo Goulart", "Santo André, Cruzeiro, Seleção Brasileira"),
                  _buildHighlight(context, "Lucas Fernandes", "São Paulo, Botafogo"),
                  const ListTile(
                    leading: Icon(Icons.more_horiz, size: 16),
                    title: Text("E muitos outros..."),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Seção: Contato (Sem alterações) ---
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Contato", style: Theme.of(context).textTheme.titleLarge),
                  const Divider(height: 20),
                  const ListTile(
                    leading: Icon(Icons.person),
                    title: Text("Cleverson Moreira"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text("(12) 97406-0854"),
                    onTap: () => _launchWhatsApp('5512974060854'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.email),
                    title: Text("moreirassport@gmail.com"),
                  ),
                  const ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text("Av. George Eastman, S/N, São José dos Campos - SP"),
                    subtitle: Text("Tivit - Portão 02 31 de Março"),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- NOVA SEÇÃO: INSTAGRAM ---
          Card(
            elevation: 2,
            child: InkWell(
              onTap: () => _launchURL('https://www.instagram.com/moreiras.sport'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt, size: 30, color: Colors.pink),
                    const SizedBox(width: 16),
                    Text(
                      "Siga-nos no Instagram!",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para criar os cards de seção (Sem alterações)
  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
              ],
            ),
            const Divider(height: 20),
            Text(content),
          ],
        ),
      ),
    );
  }

  // --- WIDGET AUXILIAR ATUALIZADO ---
  Widget _buildHighlight(BuildContext context, String name, String clubs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0, right: 8.0),
            child: Icon(Icons.star, size: 16, color: Colors.amber[600]),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                // Usando o tema do app para a cor do texto
                Text(clubs, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}