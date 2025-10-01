import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'article_model.dart';

class ArticleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'articles';

  /// Criar um novo artigo
  static Future<String> createArticle({
    required String title,
    required String content,
    String? imageUrl,
    List<String> tags = const [],
    bool isPublished = true,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final now = DateTime.now();
      final article = Article(
        id: '', // Será definido pelo Firestore
        title: title,
        content: content,
        authorId: user.uid,
        authorName: user.displayName ?? 'Autor',
        imageUrl: imageUrl,
        createdAt: now,
        updatedAt: now,
        isPublished: isPublished,
        tags: tags,
        views: 0,
      );

      final docRef = await _firestore
          .collection(_collection)
          .add(article.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar artigo: $e');
    }
  }

  /// Obter todos os artigos publicados
  static Stream<List<Article>> getPublishedArticles() {
    return _firestore
        .collection(_collection)
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final articles = snapshot.docs
              .map((doc) => Article.fromFirestore(doc))
              .toList();

          // Ordenar por data de criação (mais recente primeiro)
          articles.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return articles;
        });
  }

  /// Obter todos os artigos (incluindo não publicados) - apenas para admins
  static Stream<List<Article>> getAllArticles() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      final articles = snapshot.docs
          .map((doc) => Article.fromFirestore(doc))
          .toList();

      // Ordenar por data de criação (mais recente primeiro)
      articles.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return articles;
    });
  }

  /// Obter um artigo específico por ID
  static Future<Article?> getArticleById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Article.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar artigo: $e');
    }
  }

  /// Atualizar um artigo
  static Future<void> updateArticle({
    required String id,
    String? title,
    String? content,
    String? imageUrl,
    List<String>? tags,
    bool? isPublished,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (title != null) updateData['title'] = title;
      if (content != null) updateData['content'] = content;
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;
      if (tags != null) updateData['tags'] = tags;
      if (isPublished != null) updateData['isPublished'] = isPublished;

      await _firestore.collection(_collection).doc(id).update(updateData);
    } catch (e) {
      throw Exception('Erro ao atualizar artigo: $e');
    }
  }

  /// Excluir um artigo
  static Future<void> deleteArticle(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao excluir artigo: $e');
    }
  }

  /// Incrementar visualizações de um artigo
  static Future<void> incrementViews(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      // Não lançar erro para não interromper a experiência do usuário
      // print('Erro ao incrementar visualizações: $e');
    }
  }

  /// Buscar artigos por título ou conteúdo
  static Stream<List<Article>> searchArticles(String query) {
    if (query.isEmpty) {
      return getPublishedArticles();
    }

    // Para busca, vamos buscar todos os artigos publicados e filtrar localmente
    // Isso evita problemas de índice com consultas complexas
    return _firestore
        .collection(_collection)
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final articles = snapshot.docs
              .map((doc) => Article.fromFirestore(doc))
              .toList();

          // Filtrar localmente por título ou conteúdo
          final filteredArticles = articles.where((article) {
            final searchQuery = query.toLowerCase();
            return article.title.toLowerCase().contains(searchQuery) ||
                article.content.toLowerCase().contains(searchQuery) ||
                article.tags.any(
                  (tag) => tag.toLowerCase().contains(searchQuery),
                );
          }).toList();

          // Ordenar por data de criação (mais recente primeiro)
          filteredArticles.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return filteredArticles;
        });
  }

  /// Obter artigos por tag
  static Stream<List<Article>> getArticlesByTag(String tag) {
    return _firestore
        .collection(_collection)
        .where('isPublished', isEqualTo: true)
        .where('tags', arrayContains: tag)
        .snapshots()
        .map((snapshot) {
          final articles = snapshot.docs
              .map((doc) => Article.fromFirestore(doc))
              .toList();

          // Ordenar por data de criação (mais recente primeiro)
          articles.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return articles;
        });
  }

  /// Obter estatísticas dos artigos
  static Future<Map<String, int>> getArticleStats() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final articles = snapshot.docs
          .map((doc) => Article.fromFirestore(doc))
          .toList();

      return {
        'total': articles.length,
        'published': articles.where((a) => a.isPublished).length,
        'draft': articles.where((a) => !a.isPublished).length,
        'totalViews': articles.fold(
          0,
          (total, article) => total + article.views,
        ),
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }
}
