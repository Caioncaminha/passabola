import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../data/article_model.dart';
import '../data/article_service.dart';

class ArticleListWidget extends StatelessWidget {
  final bool
  showAllArticles; // Se true, mostra todos os artigos (admin), se false, apenas publicados
  final String? searchQuery;
  final String? tagFilter;

  const ArticleListWidget({
    super.key,
    this.showAllArticles = false,
    this.searchQuery,
    this.tagFilter,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Article>>(
      stream: _getArticleStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: KConstants.errorColor,
                ),
                const SizedBox(height: KConstants.spacingMedium),
                Text('Erro ao carregar artigos', style: KTextStyle.titleText),
                const SizedBox(height: KConstants.spacingSmall),
                Text(
                  snapshot.error.toString(),
                  style: KTextStyle.bodyText,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: KConstants.spacingMedium),
                ElevatedButton(
                  onPressed: () {
                    // Força rebuild do StreamBuilder
                    (context as Element).markNeedsBuild();
                  },
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        final articles = snapshot.data ?? [];

        if (articles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 64,
                  color: KConstants.textSecondaryColor,
                ),
                const SizedBox(height: KConstants.spacingMedium),
                Text(
                  showAllArticles
                      ? 'Nenhum artigo encontrado'
                      : 'Nenhum artigo publicado ainda',
                  style: KTextStyle.titleText.copyWith(
                    color: KConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: KConstants.spacingSmall),
                Text(
                  showAllArticles
                      ? 'Crie o primeiro artigo usando o botão acima.'
                      : 'Os artigos aparecerão aqui quando forem publicados.',
                  style: KTextStyle.bodyText.copyWith(
                    color: KConstants.textTertiaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(KConstants.spacingMedium),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return _ArticleCard(
              article: article,
              showAdminActions: showAllArticles,
              onTap: () => _navigateToArticleDetail(context, article),
            );
          },
        );
      },
    );
  }

  Stream<List<Article>> _getArticleStream() {
    if (tagFilter != null) {
      return ArticleService.getArticlesByTag(tagFilter!);
    } else if (searchQuery != null && searchQuery!.isNotEmpty) {
      return ArticleService.searchArticles(searchQuery!);
    } else if (showAllArticles) {
      return ArticleService.getAllArticles();
    } else {
      return ArticleService.getPublishedArticles();
    }
  }

  void _navigateToArticleDetail(BuildContext context, Article article) {
    // Incrementar visualizações
    ArticleService.incrementViews(article.id);

    // Navegar para detalhes do artigo (implementar depois)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ArticleDetailPage(article: article),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  final bool showAdminActions;
  final VoidCallback onTap;

  const _ArticleCard({
    required this.article,
    required this.showAdminActions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: KConstants.spacingMedium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(KConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com título e status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      article.title,
                      style: KTextStyle.cardTitleText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showAdminActions) ...[
                    const SizedBox(width: KConstants.spacingSmall),
                    _buildStatusChip(),
                  ],
                ],
              ),
              const SizedBox(height: KConstants.spacingSmall),

              // Imagem (se houver)
              if (article.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    KConstants.borderRadiusSmall,
                  ),
                  child: Image.network(
                    article.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: KConstants.surfaceColor.withValues(alpha: 0.3),
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 48),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: KConstants.spacingSmall),
              ],

              // Resumo do conteúdo
              Text(
                article.summary,
                style: KTextStyle.cardBodyText.copyWith(
                  color: KConstants.textSecondaryColor,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: KConstants.spacingSmall),

              // Tags
              if (article.tags.isNotEmpty) ...[
                Wrap(
                  spacing: KConstants.spacingExtraSmall,
                  runSpacing: KConstants.spacingExtraSmall,
                  children: article.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: KConstants.spacingSmall,
                        vertical: KConstants.spacingExtraSmall,
                      ),
                      decoration: BoxDecoration(
                        color: KConstants.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          KConstants.borderRadiusSmall,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: KTextStyle.smallText.copyWith(
                          color: KConstants.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: KConstants.spacingSmall),
              ],

              // Rodapé com informações
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: KConstants.textTertiaryColor,
                  ),
                  const SizedBox(width: KConstants.spacingExtraSmall),
                  Text(
                    article.authorName,
                    style: KTextStyle.smallText.copyWith(
                      color: KConstants.textTertiaryColor,
                    ),
                  ),
                  const SizedBox(width: KConstants.spacingMedium),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: KConstants.textTertiaryColor,
                  ),
                  const SizedBox(width: KConstants.spacingExtraSmall),
                  Text(
                    _formatDate(article.createdAt),
                    style: KTextStyle.smallText.copyWith(
                      color: KConstants.textTertiaryColor,
                    ),
                  ),
                  const Spacer(),
                  if (article.views > 0) ...[
                    Icon(
                      Icons.visibility,
                      size: 16,
                      color: KConstants.textTertiaryColor,
                    ),
                    const SizedBox(width: KConstants.spacingExtraSmall),
                    Text(
                      '${article.views}',
                      style: KTextStyle.smallText.copyWith(
                        color: KConstants.textTertiaryColor,
                      ),
                    ),
                  ],
                ],
              ),

              // Ações de admin (se aplicável)
              if (showAdminActions) ...[
                const SizedBox(height: KConstants.spacingMedium),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editArticle(context),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Editar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: KConstants.primaryColor,
                          side: BorderSide(color: KConstants.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: KConstants.spacingSmall),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteArticle(context),
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Excluir'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: KConstants.errorColor,
                          side: BorderSide(color: KConstants.errorColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KConstants.spacingSmall,
        vertical: KConstants.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: article.isPublished
            ? KConstants.successColor.withValues(alpha: 0.1)
            : KConstants.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(KConstants.borderRadiusSmall),
      ),
      child: Text(
        article.isPublished ? 'Publicado' : 'Rascunho',
        style: KTextStyle.smallText.copyWith(
          color: article.isPublished
              ? KConstants.successColor
              : KConstants.warningColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _editArticle(BuildContext context) {
    // Implementar edição de artigo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de edição será implementada em breve'),
        backgroundColor: KConstants.infoColor,
      ),
    );
  }

  void _deleteArticle(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o artigo "${article.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ArticleService.deleteArticle(article.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Artigo excluído com sucesso!'),
                      backgroundColor: KConstants.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao excluir artigo: $e'),
                      backgroundColor: KConstants.errorColor,
                    ),
                  );
                }
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _ArticleDetailPage extends StatelessWidget {
  final Article article;

  const _ArticleDetailPage({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artigo'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(article.title, style: KTextStyle.largeTitleText),
            const SizedBox(height: KConstants.spacingMedium),

            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: KConstants.textSecondaryColor,
                ),
                const SizedBox(width: KConstants.spacingExtraSmall),
                Text(
                  article.authorName,
                  style: KTextStyle.bodyText.copyWith(
                    color: KConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(width: KConstants.spacingMedium),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: KConstants.textSecondaryColor,
                ),
                const SizedBox(width: KConstants.spacingExtraSmall),
                Text(
                  _formatDate(article.createdAt),
                  style: KTextStyle.bodyText.copyWith(
                    color: KConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: KConstants.spacingLarge),

            if (article.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  KConstants.borderRadiusMedium,
                ),
                child: Image.network(
                  article.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: KConstants.surfaceColor.withValues(alpha: 0.3),
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 48),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: KConstants.spacingLarge),
            ],

            Text(
              article.content,
              style: KTextStyle.bodyText.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
