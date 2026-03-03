class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final String? mediaUrl;
  final String? mediaType;
  final int likesCount;
  final DateTime createdAt;
  bool isLiked;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.mediaUrl,
    this.mediaType,
    this.likesCount = 0,
    required this.createdAt,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // El JSON puede venir del join con profiles
    final authorInfo = json['author'] as Map<String, dynamic>?;

    return Post(
      id: json['id'],
      authorId: json['author_id'],
      authorName: authorInfo != null ? authorInfo['nombre_artistico'] ?? 'Artista' : 'Cargando...',
      authorAvatar: authorInfo != null ? authorInfo['foto_perfil'] : null,
      content: json['content'] ?? '',
      mediaUrl: json['media_url'],
      mediaType: json['media_type'],
      likesCount: json['likes_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      // isLiked se determinará por separado o con otro join
    );
  }
}
