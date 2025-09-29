import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../data/article.dart';
import '../widgets/article_template.dart';
import 'article_create_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  // Dados de exemplo para as seções
  final List<Article> _articles = [
    Article(
      title: 'Bem-vinda ao Passa a Bola',
      subtitle: 'Comece criando sua primeira reportagem',
      body:
          'Use o botão "Nova reportagem" para adicionar uma matéria com imagem, título, subtítulo e texto.',
      imageUrl:
          'https://images.unsplash.com/photo-1521417531039-55b8c7a7f2a9?q=80&w=1200&auto=format&fit=crop',
      createdAt: DateTime.now(),
    ),
  ];

  final List<Article> _destaques = [
    Article(
      title: '🏆 Campeãs da Temporada',
      subtitle: 'Conheça as grandes vencedoras',
      body:
          'As atletas que se destacaram nesta temporada e conquistaram títulos importantes para o esporte feminino.',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=1200&auto=format&fit=crop',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final List<Map<String, dynamic>> _eventos = [
    {
      'titulo': 'Copa Feminina 2024',
      'data': '15 de Março',
      'local': 'Estádio Municipal',
      'imagem':
          'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?q=80&w=1200&auto=format&fit=crop',
    },
    {
      'titulo': 'Workshop de Futebol',
      'data': '22 de Março',
      'local': 'Centro Esportivo',
      'imagem':
          'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=1200&auto=format&fit=crop',
    },
  ];

  final List<Map<String, dynamic>> _videos = [
    {
      'titulo': 'Técnicas de Chute',
      'canal': 'Passa a Bola',
      'visualizacoes': '15.2K',
      'thumbnail':
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=1200&auto=format&fit=crop',
    },
    {
      'titulo': 'Preparação Física',
      'canal': 'Passa a Bola',
      'visualizacoes': '8.7K',
      'thumbnail':
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=1200&auto=format&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final String query = _searchController.text.trim().toLowerCase();
    final List<Article> filtered = _articles.where((a) {
      if (query.isEmpty) return true;
      return a.title.toLowerCase().contains(query) ||
          a.subtitle.toLowerCase().contains(query) ||
          a.body.toLowerCase().contains(query);
    }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(KConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de pesquisa e botão de nova reportagem
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: KInputDecoration.textFieldDecoration(
                      hintText: 'Pesquisar reportagens...',
                      prefixIcon: Icons.search,
                    ),
                  ),
                ),
                const SizedBox(width: KConstants.spacingMedium),
                TextButton.icon(
                  onPressed: _onCreateArticle,
                  icon: const Icon(Icons.add, color: KConstants.primaryColor),
                  label: Text(
                    'Nova reportagem',
                    style: KTextStyle.buttonTextPrimary,
                  ),
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(
                      KConstants.primaryColor.withOpacity(0.06),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KConstants.spacingLarge),

            // Seção Últimas Notícias
            _buildSectionHeader('Últimas Notícias', Icons.article_outlined),
            const SizedBox(height: KConstants.spacingMedium),
            ...filtered.map((a) => ArticleTemplate(article: a)).toList(),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: KConstants.spacingLarge),
                child: Center(
                  child: Text(
                    'Nenhuma reportagem encontrada',
                    style: KTextStyle.bodySecondaryText,
                  ),
                ),
              ),
            const SizedBox(height: KConstants.spacingExtraLarge),

            // Seção Destaques
            _buildSectionHeader('Destaques', Icons.star_outline),
            const SizedBox(height: KConstants.spacingMedium),
            ..._destaques.map((a) => ArticleTemplate(article: a)).toList(),
            const SizedBox(height: KConstants.spacingExtraLarge),

            // Seção Novos Eventos
            _buildSectionHeader('Novos Eventos', Icons.event_outlined),
            const SizedBox(height: KConstants.spacingMedium),
            ..._eventos.map((evento) => _buildEventCard(evento)).toList(),
            const SizedBox(height: KConstants.spacingExtraLarge),

            // Seção Últimos Vídeos
            _buildSectionHeader('Últimos Vídeos', Icons.play_circle_outline),
            const SizedBox(height: KConstants.spacingMedium),
            ..._videos.map((video) => _buildVideoCard(video)).toList(),
            const SizedBox(height: KConstants.spacingLarge),
          ],
        ),
      ),
    );
  }

  void _onCreateArticle() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ArticleCreatePage()));
    if (result is Article) {
      setState(() {
        _articles.insert(0, result);
      });
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: KConstants.primaryColor, size: 24),
        const SizedBox(width: KConstants.spacingSmall),
        Text(
          title,
          style: KTextStyle.titleText.copyWith(color: KConstants.primaryColor),
        ),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> evento) {
    return Container(
      margin: const EdgeInsets.only(bottom: KConstants.spacingMedium),
      decoration: KDecoration.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              evento['imagem'],
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(KConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(evento['titulo'], style: KTextStyle.cardTitleText),
                const SizedBox(height: KConstants.spacingSmall),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: KConstants.textSecondaryColor,
                    ),
                    const SizedBox(width: KConstants.spacingExtraSmall),
                    Text(evento['data'], style: KTextStyle.cardSubtitleText),
                    const SizedBox(width: KConstants.spacingMedium),
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: KConstants.textSecondaryColor,
                    ),
                    const SizedBox(width: KConstants.spacingExtraSmall),
                    Expanded(
                      child: Text(
                        evento['local'],
                        style: KTextStyle.cardSubtitleText,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    return Container(
      margin: const EdgeInsets.only(bottom: KConstants.spacingMedium),
      decoration: KDecoration.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  video['thumbnail'],
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(KConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video['titulo'], style: KTextStyle.cardTitleText),
                const SizedBox(height: KConstants.spacingSmall),
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 16,
                      color: KConstants.textSecondaryColor,
                    ),
                    const SizedBox(width: KConstants.spacingExtraSmall),
                    Text(video['canal'], style: KTextStyle.cardSubtitleText),
                    const Spacer(),
                    Icon(
                      Icons.visibility,
                      size: 16,
                      color: KConstants.textSecondaryColor,
                    ),
                    const SizedBox(width: KConstants.spacingExtraSmall),
                    Text(
                      video['visualizacoes'],
                      style: KTextStyle.cardSubtitleText,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
