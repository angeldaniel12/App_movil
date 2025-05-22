class Reel {
  final String videoId;
  final String videoName;
  final String videoDescription;
  final String videoUserId;
  final DateTime videoCreatedAt;
  final Map<String, int> reactions;
  final String userName;
  final String userAvatar;

  Reel({
    required this.videoId,
    required this.videoName,
    required this.videoDescription,
    required this.videoUserId,
    required this.videoCreatedAt,
    required this.reactions,
    required this.userName,
    required this.userAvatar,
  });

  factory Reel.fromJson(Map<String, dynamic> json) {
  return Reel(
    videoId: json['video_id'] ?? '',
    videoName: json['video_name'] ?? '',
    videoDescription: json['video_description'] ?? '',
    videoUserId: json['video_user_id'] ?? '',
    videoCreatedAt: json['video_created_at'] != null
        ? DateTime.parse(json['video_created_at'])
        : DateTime.now(),
    userName: json['user_name'] ?? '',
    userAvatar: json['user_avatar'] ?? '',
    reactions: {
      "likes": json['likes'] ?? 0,
      "love": json['love'] ?? 0,
      "happy": json['happy'] ?? 0,
    },
  );
}

}


// class Reel {
//   final String videoId;
//   final String videoName;
//   final String videoDescription;
//   final String videoUserId;
//   final DateTime videoCreatedAt;
//   final Map<String, dynamic>? likes; // ✅ Ahora es un Mapa en vez de un String
//   final String userName;
//   final String userAvatar;

//   // Constructor de la clase Reel
//   Reel({
//     required this.videoId,
//     required this.videoName,
//     required this.videoDescription,
//     required this.videoUserId,
//     required this.videoCreatedAt,
//     this.likes,
//     required this.userName,
//     required this.userAvatar,
//   });

//   factory Reel.fromJson(Map<String, dynamic> json) {
//     return Reel(
//       videoId: json['video_id'] as String? ?? '', // Si es null, usa un valor vacío
//       videoName: json['video_name'] as String? ?? '', // Si es null, usa un valor vacío
//       videoDescription: json['video_description'] as String? ?? '', // Si es null, usa un valor vacío
//       videoUserId: json['video_user_id'] as String? ?? '', // Si es null, usa un valor vacío
//       videoCreatedAt: json['video_created_at'] != null
//           ? DateTime.parse(json['video_created_at'] as String)
//           : DateTime.now(), // Si es null, usa la fecha actual
//       userName: json['user_name'] as String? ?? '', // Si es null, usa un valor vacío
//       likes: json['likes'] as Map<String, dynamic>?, // ✅ Se asigna correctamente como Mapa
//       userAvatar: json['user_avatar'] as String? ?? '', // Si es null, usa un valor vacío
//     );
//   }
// }

// // class Reel {
// //   final int id;
// //   final String title;
// //   final String videoUrl;
// //   final String thumbnail;
// //   final String createdAt;

// //   Reel({
// //     required this.id,
// //     required this.title,
// //     required this.videoUrl,
// //     required this.thumbnail,
// //     required this.createdAt,
// //   });

// //   factory Reel.fromJson(Map<String, dynamic> json) {
// //     return Reel(
// //       id: json['id'],
// //       title: json['title'],
// //       videoUrl: json['video_url'],
// //       thumbnail: json['thumbnail'],
// //       createdAt: json['created_at'],
// //     );
// //   }
// // }
