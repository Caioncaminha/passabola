import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final List<String> tags;
  final int views;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = true,
    this.tags = const [],
    this.views = 0,
  });

  // Construtor para criar a partir de um DocumentSnapshot
  factory Article.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Article(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isPublished: data['isPublished'] ?? true,
      tags: List<String>.from(data['tags'] ?? []),
      views: data['views'] ?? 0,
    );
  }

  // Método para converter para Map (para salvar no Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublished': isPublished,
      'tags': tags,
      'views': views,
    };
  }

  // Método para criar uma cópia com campos atualizados
  Article copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
    List<String>? tags,
    int? views,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
      tags: tags ?? this.tags,
      views: views ?? this.views,
    );
  }

  // Método para obter resumo do artigo (primeiros 150 caracteres)
  String get summary {
    if (content.length <= 150) return content;
    return '${content.substring(0, 150)}...';
  }

  // Método para verificar se o artigo é recente (últimos 7 dias)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays <= 7;
  }
}
