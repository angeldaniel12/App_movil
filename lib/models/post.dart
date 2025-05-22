// Modelo para los Posts
class Post {
  final int id;
  final String userName;
  final String content;
  final String? imageUrl; // URL de la imagen del post
  final String createdAt;
  final String categoryName;
   final String userAvatar;
   int likesCount;
  

  Post({
    required this.id,
    required this.userName,
    required this.categoryName,
    required this.content,
    this.imageUrl, // Imagen opcional del post
    required this.createdAt,
    required this.userAvatar,
    required this.likesCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
       id: int.tryParse(json['id'].toString()) ?? 0,  // Asegura que 'id' sea un entero
       content: json['content'] as String,
       imageUrl: json['image_url'] as String?, // URL de la imagen del post
       userName: json['user_name'] as String,
       categoryName: json['category_name'] as String, // Nombre de la categoría
       createdAt: json['created_at'] as String,
        userAvatar: json['user_avatar']?.toString() ?? '', // URL de la imagen de perfil
       likesCount: json['likes_count'] ?? 0,      
    );
  }
}