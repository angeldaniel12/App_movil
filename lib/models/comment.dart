class Comment {
  final int id;
  final int userId;
  final String userName;
  final int postId;
  final String body;
  final String createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.postId,
    required this.body,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? 'Usuario',
      postId: json['post_id'],
      body: json['body'],
      createdAt: json['created_at'],
    );
  }
}
