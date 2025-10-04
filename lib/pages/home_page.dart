import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../data/article.dart';
import '../data/championship_model.dart';
import '../data/championship_service.dart';
import '../widgets/article_template.dart';
import 'article_create_page.dart';
import 'videos_player_page.dart';
import 'championships_page.dart';
import 'championship_registration_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  Championship? _featuredChampionship;
  bool _isLoadingChampionship = true;

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
        'titulo': 'PABCAST CONVIDA: KETLEN WIGGERS - FALA, BEBÊ #40',
        'canal': 'Passa a Bola',
        'visualizacoes': '1.4K',
        'thumbnail': 'https://img.youtube.com/vi/OwIKvXW6aYU/hqdefault.jpg',
        'videoId': 'OwIKvXW6aYU', // <- ID DO VÍDEO
      },
      {
        'titulo': 'COMO TEM SIDO NOSSOS PRIMEIROS MESES? - FALA, BEBÊ #39',
        'canal': 'Passa a Bola',
        'visualizacoes': '1.9K',
        'thumbnail': 'https://img.youtube.com/vi/pr4wX4hCVLs/hqdefault.jpg',
        'videoId': 'pr4wX4hCVLs', // <- ID DO VÍDEO
      },
  ];

  @override
  void initState() {
    super.initState();
    _loadFeaturedChampionship();
  }

  Future<void> _loadFeaturedChampionship() async {
    try {
      final championships = await ChampionshipService.getPublicChampionships(
        limit: 1,
      );
      if (mounted) {
        setState(() {
          _featuredChampionship = championships.isNotEmpty
              ? championships.first
              : null;
          _isLoadingChampionship = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar campeonato em destaque: $e');
      if (mounted) {
        setState(() {
          _isLoadingChampionship = false;
          _featuredChampionship = null;
        });
      }
    }
  }

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

            // Seção Campeonato em Destaque
            _buildSectionHeader(
              'Campeonato em Destaque',
              Icons.emoji_events_outlined,
            ),
            const SizedBox(height: KConstants.spacingMedium),
            _buildFeaturedChampionshipSection(),
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
    // Envolvemos o card com InkWell para dar um efeito de clique
    // e a funcionalidade de navegação.
    return InkWell(
      onTap: () {
        // Ação de clique: navegar para a página do player
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VideoPlayerPage(videoId: video['videoId']),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12), // Para o efeito de clique ter bordas arredondadas
      child: Container(
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
      ),
    );
  }

  Widget _buildFeaturedChampionshipSection() {
    if (_isLoadingChampionship) {
      return Container(
        height: 200,
        decoration: KDecoration.cardDecoration,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_featuredChampionship == null) {
      return Container(
        padding: const EdgeInsets.all(KConstants.spacingLarge),
        decoration: KDecoration.cardDecoration,
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: KConstants.spacingMedium),
            Text(
              'Nenhum campeonato disponível no momento',
              style: KTextStyle.titleText.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KConstants.spacingSmall),
            Text(
              'Novos campeonatos aparecerão aqui quando forem publicados',
              style: KTextStyle.bodyText.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KConstants.spacingLarge),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChampionshipsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.emoji_events),
                label: const Text('Ver Todos os Campeonatos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KConstants.primaryColor,
                  foregroundColor: KConstants.textLightColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildRealChampionshipCard(_featuredChampionship!),
        const SizedBox(height: KConstants.spacingMedium),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChampionshipsPage()),
              );
            },
            icon: const Icon(Icons.list),
            label: const Text('Ver Todos os Campeonatos'),
            style: OutlinedButton.styleFrom(
              foregroundColor: KConstants.primaryColor,
              side: BorderSide(color: KConstants.primaryColor),
              padding: const EdgeInsets.symmetric(
                vertical: KConstants.spacingMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRealChampionshipCard(Championship championship) {
    return Container(
      decoration: KDecoration.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem de cabeçalho
          if (championship.imageUrl != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    championship.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.emoji_events, size: 50),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: KConstants.spacingSmall,
                  right: KConstants.spacingSmall,
                  child: _buildStatusChip(championship.status),
                ),
              ],
            ),

          // Conteúdo do card
          Padding(
            padding: const EdgeInsets.all(KConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(championship.title, style: KTextStyle.cardTitleText),
                const SizedBox(height: KConstants.spacingSmall),
                Text(
                  championship.description,
                  style: KTextStyle.cardSubtitleText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: KConstants.spacingMedium),

                // Informações do campeonato
                _buildInfoRow(Icons.location_on, championship.location),
                const SizedBox(height: KConstants.spacingSmall),
                _buildInfoRow(
                  Icons.sports_soccer,
                  championship.typeDisplayName,
                ),
                const SizedBox(height: KConstants.spacingSmall),
                _buildInfoRow(
                  Icons.how_to_reg,
                  championship.registrationTypeDisplayName,
                ),
                const SizedBox(height: KConstants.spacingSmall),
                _buildInfoRow(
                  Icons.people,
                  'Máximo: ${championship.maxTeams} times',
                ),

                if (championship.registrationFee != null) ...[
                  const SizedBox(height: KConstants.spacingSmall),
                  _buildInfoRow(
                    Icons.attach_money,
                    'R\$ ${championship.registrationFee!.toStringAsFixed(2)}',
                    color: Colors.green[600],
                  ),
                ],

                // Datas
                if (championship.startDate != null ||
                    championship.endDate != null) ...[
                  const SizedBox(height: KConstants.spacingMedium),
                  Container(
                    padding: const EdgeInsets.all(KConstants.spacingSmall),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(
                        KConstants.borderRadiusSmall,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: KConstants.spacingSmall),
                        Expanded(
                          child: Text(
                            _formatDateRange(
                              championship.startDate,
                              championship.endDate,
                            ),
                            style: KTextStyle.smallText.copyWith(
                              color: Colors.blue[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: KConstants.spacingLarge),

                // Botões de inscrição baseados no tipo do campeonato
                if (championship.canRegisterTeams &&
                    championship.canRegisterIndividuals) ...[
                  // Ambos os tipos permitidos
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _goToRegistration(
                            championship,
                            RegistrationType.teamOnly,
                          ),
                          icon: const Icon(Icons.group),
                          label: const Text('Inscrever Time'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KConstants.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: KConstants.spacingSmall),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _goToRegistration(
                            championship,
                            RegistrationType.individualPairing,
                          ),
                          icon: const Icon(Icons.person),
                          label: const Text('Inscrever Individual'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: KConstants.primaryColor,
                            side: BorderSide(color: KConstants.primaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (championship.canRegisterTeams) ...[
                  // Apenas times
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _goToRegistration(
                        championship,
                        RegistrationType.teamOnly,
                      ),
                      icon: const Icon(Icons.group),
                      label: const Text('Inscrever Time'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KConstants.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ] else if (championship.canRegisterIndividuals) ...[
                  // Apenas individuais
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _goToRegistration(
                        championship,
                        RegistrationType.individualPairing,
                      ),
                      icon: const Icon(Icons.person),
                      label: const Text('Inscrever Individual'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KConstants.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ] else ...[
                  // Nenhum tipo permitido
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChampionshipDetailsPage(
                                  championship: championship,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.visibility),
                          label: const Text('Ver Detalhes'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ChampionshipStatus status) {
    Color color;
    String text;

    switch (status) {
      case ChampionshipStatus.published:
        color = Colors.blue;
        text = 'PUBLICADO';
        break;
      case ChampionshipStatus.registrationOpen:
        color = Colors.green;
        text = 'INSCRIÇÕES ABERTAS';
        break;
      case ChampionshipStatus.registrationClosed:
        color = Colors.orange;
        text = 'INSCRIÇÕES FECHADAS';
        break;
      case ChampionshipStatus.ongoing:
        color = Colors.purple;
        text = 'EM ANDAMENTO';
        break;
      case ChampionshipStatus.finished:
        color = Colors.teal;
        text = 'FINALIZADO';
        break;
      default:
        color = Colors.grey;
        text = status.name.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KConstants.spacingSmall,
        vertical: KConstants.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(KConstants.borderRadiusSmall),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? KConstants.textSecondaryColor),
        const SizedBox(width: KConstants.spacingExtraSmall),
        Expanded(
          child: Text(
            text,
            style: KTextStyle.cardSubtitleText.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  String _formatDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) return '';

    if (startDate != null && endDate != null) {
      if (startDate.day == endDate.day &&
          startDate.month == endDate.month &&
          startDate.year == endDate.year) {
        return '${startDate.day}/${startDate.month}/${startDate.year}';
      }
      return '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
    }

    if (startDate != null) {
      return 'Início: ${startDate.day}/${startDate.month}/${startDate.year}';
    }

    return 'Fim: ${endDate!.day}/${endDate.month}/${endDate.year}';
  }

  void _goToRegistration(
    Championship championship,
    RegistrationType registrationType,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChampionshipRegistrationPage(
          championship: championship,
          registrationType: registrationType,
        ),
      ),
    );
  }
}