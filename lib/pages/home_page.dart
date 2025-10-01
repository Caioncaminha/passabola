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

  final List<Map<String, dynamic>> _campeonatos = [
    {
      'titulo': 'Copa Feminina 2024',
      'dataInicio': '15 de Abril',
      'dataFim': '30 de Maio',
      'local': 'Estádio Municipal',
      'categoria': 'Sub-18',
      'preco': 'R\$ 50,00',
      'vagas': 16,
      'inscritos': 8,
      'imagem':
          'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?q=80&w=1200&auto=format&fit=crop',
      'descricao':
          'Campeonato estadual para atletas sub-18 com premiação em dinheiro.',
    },
    {
      'titulo': 'Liga Amadora Feminina',
      'dataInicio': '1 de Junho',
      'dataFim': '15 de Agosto',
      'local': 'Centro Esportivo',
      'categoria': 'Adulto',
      'preco': 'R\$ 80,00',
      'vagas': 12,
      'inscritos': 5,
      'imagem':
          'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=1200&auto=format&fit=crop',
      'descricao':
          'Liga para jogadoras amadoras com sistema de pontos corridos.',
    },
    {
      'titulo': 'Copa das Estrelas',
      'dataInicio': '10 de Setembro',
      'dataFim': '25 de Outubro',
      'local': 'Arena Esportiva',
      'categoria': 'Sub-16',
      'preco': 'R\$ 40,00',
      'vagas': 20,
      'inscritos': 12,
      'imagem':
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=1200&auto=format&fit=crop',
      'descricao': 'Torneio para jovens promessas com acompanhamento técnico.',
    },
    {
      'titulo': 'Champions League Feminina',
      'dataInicio': '5 de Novembro',
      'dataFim': '20 de Dezembro',
      'local': 'Complexo Esportivo',
      'categoria': 'Adulto',
      'preco': 'R\$ 120,00',
      'vagas': 8,
      'inscritos': 3,
      'imagem':
          'https://images.unsplash.com/photo-1521417531039-55b8c7a7f2a9?q=80&w=1200&auto=format&fit=crop',
      'descricao': 'Campeonato de elite com premiação especial e troféus.',
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
            const SizedBox(height: KConstants.spacingExtraLarge),

            // Seção Futuros Campeonatos
            _buildSectionHeader(
              'Futuros Campeonatos',
              Icons.emoji_events_outlined,
            ),
            const SizedBox(height: KConstants.spacingMedium),
            ..._campeonatos
                .map((campeonato) => _buildChampionshipCard(campeonato))
                .toList(),
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

  Widget _buildChampionshipCard(Map<String, dynamic> campeonato) {
    final int vagasRestantes = campeonato['vagas'] - campeonato['inscritos'];
    final bool temVagas = vagasRestantes > 0;

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
                  campeonato['imagem'],
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: KConstants.spacingSmall,
                right: KConstants.spacingSmall,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KConstants.spacingSmall,
                    vertical: KConstants.spacingExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    color: campeonato['categoria'] == 'Adulto'
                        ? Colors.orange
                        : Colors.blue,
                    borderRadius: BorderRadius.circular(
                      KConstants.borderRadiusSmall,
                    ),
                  ),
                  child: Text(
                    campeonato['categoria'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
                Text(campeonato['titulo'], style: KTextStyle.cardTitleText),
                const SizedBox(height: KConstants.spacingSmall),
                Text(
                  campeonato['descricao'],
                  style: KTextStyle.cardSubtitleText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: KConstants.spacingMedium),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: KConstants.textSecondaryColor,
                    ),
                    const SizedBox(width: KConstants.spacingExtraSmall),
                    Text(
                      '${campeonato['dataInicio']} - ${campeonato['dataFim']}',
                      style: KTextStyle.cardSubtitleText,
                    ),
                  ],
                ),
                const SizedBox(height: KConstants.spacingSmall),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: KConstants.textSecondaryColor,
                    ),
                    const SizedBox(width: KConstants.spacingExtraSmall),
                    Expanded(
                      child: Text(
                        campeonato['local'],
                        style: KTextStyle.cardSubtitleText,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KConstants.spacingSmall),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: KConstants.textSecondaryColor,
                    ),
                    const SizedBox(width: KConstants.spacingExtraSmall),
                    Text(
                      '${campeonato['inscritos']}/${campeonato['vagas']} inscritos',
                      style: KTextStyle.cardSubtitleText,
                    ),
                    const Spacer(),
                    Text(
                      campeonato['preco'],
                      style: KTextStyle.cardTitleText.copyWith(
                        color: KConstants.primaryColor,
                        fontSize: KConstants.fontSizeMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KConstants.spacingMedium),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: temVagas
                        ? () => _showSignupDialog(campeonato)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: temVagas
                          ? KConstants.primaryColor
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: KConstants.spacingSmall,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          KConstants.borderRadiusMedium,
                        ),
                      ),
                    ),
                    child: Text(
                      temVagas ? 'Inscrever-se' : 'Vagas Esgotadas',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSignupDialog(Map<String, dynamic> campeonato) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Inscrever-se em ${campeonato['titulo']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Categoria: ${campeonato['categoria']}'),
              Text(
                'Período: ${campeonato['dataInicio']} - ${campeonato['dataFim']}',
              ),
              Text('Local: ${campeonato['local']}'),
              Text('Valor: ${campeonato['preco']}'),
              const SizedBox(height: KConstants.spacingMedium),
              const Text(
                'Deseja confirmar sua inscrição?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmSignup(campeonato);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: KConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmSignup(Map<String, dynamic> campeonato) {
    setState(() {
      campeonato['inscritos'] = campeonato['inscritos'] + 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inscrição confirmada em ${campeonato['titulo']}!'),
        backgroundColor: KConstants.successColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}