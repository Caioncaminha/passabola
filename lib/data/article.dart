// No imports required at the moment

class Article {
  final String title;
  final String subtitle;
  final String body;
  final String? imageUrl;
  final DateTime createdAt;

  const Article({
    required this.title,
    required this.subtitle,
    required this.body,
    this.imageUrl,
    required this.createdAt,
  });

  Article copyWith({
    String? title,
    String? subtitle,
    String? body,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Article(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Article(title: ' + title + ', subtitle: ' + subtitle + ')';
  }
}
