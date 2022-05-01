class Post {
  final int id;
  final String name;

  const Post({
    required this.id,
    required this.name,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      name: json['name'],
    );
  }
}
