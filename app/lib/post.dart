class Post {
  final int id;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
