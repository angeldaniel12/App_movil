// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/reels.dart';

// class ReelService {
//   static Future<List<Reel>> fetchReels() async {
//     final response = await http.get(Uri.parse('http://192.168.50.54:8080/plataforma/get_reels.php'));

//     print('🔹 Respuesta del servidor: ${response.body}');

//     if (response.statusCode == 200) {
//       try {
//         final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));

//         if (data.containsKey('reels') && data['reels'] is List) {
//           return (data['reels'] as List).map((item) => Reel.fromJson(item)).toList();
//         } else {
//           print('⚠️ No hay reels en la respuesta.');
//           return [];
//         }
//       } catch (e) {
//         print('❌ Error al decodificar JSON: $e');
//         return [];
//       }
//     } else {
//       throw Exception('⚠️ Error al cargar reels: ${response.statusCode}');
//     }
//   }
// }

// reels_services.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/reels.dart';

// class ReelService {
//   static const String baseUrl = 'http://192.168.50.54:8080/plataforma/get_reels.php';
//   //static const String baseUrl ="http://172.20.10.2:8080/plataforma/get_reels.php";
//   static Future<List<Reel>> fetchReels() async {
//     final url = Uri.parse(baseUrl);
//     // final url = Uri.parse('$baseUrl/get_reels.php');
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final List<dynamic> reelsJson = data['reels'];
//       return reelsJson.map((json) => Reel.fromJson(json)).toList();
//     } else {
//       throw Exception('Error al cargar los reels');
//     }
//   }
//   static Future<Map<String, dynamic>> getReactions(int videoId) async {
//   final response = await http.get(
//     Uri.parse("http://192.168.50.54:8080/plataforma/likes.php?video_id=$videoId"),
//   );

//   if (response.statusCode == 200) {
//     return jsonDecode(response.body);
//   } else {
//     throw Exception("Error al obtener reacciones");
//   }
// }

// static Future<void> saveReaction(int videoId, String reaction) async {
//   final response = await http.post(
//     Uri.parse("http://192.168.50.54:8080/plataforma/get_reels.php"),
//     headers: {"Content-Type": "application/json"},
//     body: jsonEncode({
//       "video_id": videoId,
//       "reaction": reaction,
//     }),
//   );

//   if (response.statusCode != 200) {
//     throw Exception("Error al guardar la reacción: ${response.body}");
//   }
// }

// static Future<void> removeReaction(int videoId, String reaction) async {
//   final response = await http.delete(
//     Uri.parse("http://192.168.50.54:8080/plataforma/get_reels.php?video_id=$videoId"),
//   );

//   if (response.statusCode != 200) {
//     throw Exception("Error al eliminar la reacción: ${response.body}");
//   }
// }


//   // static Future<void> saveReaction(int videoId, String reaction) async {
//   //   final response = await http.post(
//   //     Uri.parse(baseUrl),
//   //     headers: {"Content-Type": "application/json"},
//   //     body: jsonEncode({
//   //       "video_id": videoId,
//   //       "reaction": reaction,
//   //     }),
//   //   );

//   //   if (response.statusCode != 200) {
//   //     throw Exception("Error al guardar la reacción: ${response.body}");
//   //   }
//   // }

//   // static Future<void> removeReaction(int videoId, String reaction) async {
//   //   final response = await http.delete(
//   //     Uri.parse(baseUrl),
//   //     headers: {"Content-Type": "application/json"},
//   //     body: jsonEncode({
//   //       "video_id": videoId,
//   //       "reaction": reaction,
//   //     }),
//   //   );

//   //   if (response.statusCode != 200) {
//   //     throw Exception("Error al eliminar la reacción: ${response.body}");
//   //   }
//   // }
//   static Future<Map<String, dynamic>> getUserReaction(int videoId) async {
//    final response = await http.get(
//      Uri.parse('http://192.168.50.54:8080/plataforma/get_reels.php?video_id=$videoId'),
//    );

//    if (response.statusCode == 200) {
//      final data = jsonDecode(response.body);
//      return {
//        "userReaction": data['user_reaction'], 
//        "reactionsCount": data['reactions_count']
//      };
//    } else {
//      throw Exception("Error al obtener las reacciones del usuario");
//    }
//  }


  
// }

  // // Implementación para guardar o actualizar la reacción
  // static Future<void> saveReaction(dynamic videoId, String reaction) async {
  //   final url = Uri.parse('$baseUrl/save_reaction.php');
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({
  //       'video_id': videoId,
  //       'reaction': reaction,
  //       // Puedes incluir otros datos, por ejemplo, el ID del usuario
  //     }),
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception('Error al guardar la reacción. Código: ${response.statusCode}');
  //   }
  // }

  // // Implementación para eliminar la reacción del usuario para un video
  // static Future<void> removeReaction(dynamic videoId) async {
  //   final url = Uri.parse('$baseUrl/remove_reaction.php');
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({
  //       'video_id': videoId,
  //       // Si es necesario, puedes enviar otros parámetros (como el ID del usuario)
  //     }),
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception('Error al eliminar la reacción. Código: ${response.statusCode}');
  //   }
  // }
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reels.dart';

class ReelService {
    //static const String baseUrl = 'http://172.20.10.2:8080/plataforma/get_reels.php';
    static const String baseUrl = 'http://172.20.10.2:8080/plataforma/get_reels.php';

   //static const String baseUrl = 'http://192.168.50.54:8080/plataforma/get_reels.php';

  /// ✅ Obtener todos los Reels
  static Future<List<Reel>> fetchReels() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> reelsJson = data['reels'];
      return reelsJson.map((json) => Reel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los reels');
    }
  }

  /// ✅ Agregar o quitar reacción (LIKE, LOVE, HAPPY)
 static Future<bool> updateReaction(int videoId, String reaction, bool isAdding) async {
  final url = Uri.parse(baseUrl);

  final response = isAdding
      ? await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "video_id": videoId,
            "reaction": reaction,
          }),
        )
      : await http.delete(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "video_id": videoId,
            "reaction": reaction,
          }),
        );

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    return result['success'] ?? false;
  }
  return false;
}

  /// ✅ Obtener reacciones de un video específico
  static Future<Map<String, int>> getReactions(int videoId) async {
    final url = Uri.parse("$baseUrl?video_id=$videoId");
    final response = await http.get(url);

    print("Respuesta API: ${response.body}"); // 👀 Depuración

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data == null || !data.containsKey("reels")) {
        throw Exception("La respuesta no contiene datos de reacciones");
      }

      final reel = data['reels'].firstWhere(
        (r) => r['video_id'].toString() == videoId.toString(),
        orElse: () => null,
      );

      if (reel == null) throw Exception("No se encontró el video");

      return {
        "likes": reel['likes'] ?? 0,
        "love": reel['love'] ?? 0,
        "happy": reel['happy'] ?? 0,
      };
    } else {
      throw Exception("Error al obtener reacciones");
    }
  }

  /// ✅ Guardar reacción (LIKE, LOVE, HAPPY)
  static Future<void> saveReaction(int videoId, String reaction) async {
    await updateReaction(videoId, reaction, true);
  }

  /// ✅ Eliminar reacción (LIKE, LOVE, HAPPY)
  static Future<void> removeReaction(int videoId, String reaction) async {
    await updateReaction(videoId, reaction, false);
  }
}

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/reels.dart';

// class ReelService {
//    //static const String baseUrl = 'http://172.20.10.2:8080/plataforma/get_reels.php';
//   static const String baseUrl = 'http://192.168.50.54:8080/plataforma/get_reels.php';

//   static Future<List<Reel>> fetchReels() async {
//     final url = Uri.parse(baseUrl);
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final List<dynamic> reelsJson = data['reels'];
//       return reelsJson.map((json) => Reel.fromJson(json)).toList();
//     } else {
//       throw Exception('Error al cargar los reels');
//     }
//   }
//    Future<bool> updateReaction(String videoId, String reaction, bool isAdding) async {
//    final url = Uri.parse('http://192.168.50.54:8080/plataforma/get_reels.php');
//    final response = await http.post(
//      url,
//      headers: {"Content-Type": "application/json"},
//      body: jsonEncode({
//        "video_id": videoId,
//        "reaction": reaction,
//      }),
//    );

//    if (response.statusCode == 200) {
//      return jsonDecode(response.body)['success'] ?? false;
//    }
//    return false;
//  }

//   static Future<Map<String, dynamic>> getReactions(int videoId) async {
//   final response = await http.get(
//         Uri.parse("http://192.168.50.54:8080/plataforma/get_reels.php?video_id=$videoId"),

//     // Uri.parse("http://192.168.50.54:8080/plataforma/get_reels.php?video_id=$videoId"),
//   );

//   print("Respuesta API: ${response.body}"); // 👀 Depuración

//   if (response.statusCode == 200) {
//     if (response.body.isEmpty) {
//       throw Exception("La respuesta está vacía");
//     }

//     var data = jsonDecode(response.body);
//     if (data == null) {
//       throw Exception("La respuesta es nula");
//     }

//     return data;
//   } else {
//     throw Exception("Error al obtener reacciones");
//   }
// }

// // static Future<Map<String, dynamic>> getReactions(int videoId) async {
// //   final response = await http.get(
// //         Uri.parse("http://192.168.50.54:8080/plataforma/get_reels.php?video_id=$videoId"),

// //     // Uri.parse("http://172.20.10.2:8080/plataforma/get_reels.php?video_id=$videoId"),
// //   );

// //   if (response.statusCode == 200) {
// //     if (response.body.isEmpty) {
// //       throw Exception("La respuesta está vacía");
// //     }

// //     var data = jsonDecode(response.body);
// //     if (data == null) {
// //       throw Exception("La respuesta es nula");
// //     }

// //     return data;
// //   } else {
// //     throw Exception("Error al obtener reacciones");
// //   }
// // }


//   static Future<void> saveReaction(int videoId, String reaction) async {
//     final response = await http.post(
//       Uri.parse("http://192.168.50.54:8080/plataforma/get_reels.php"),
//       // Uri.parse("http://172.20.10.2:8080/plataforma/get_reels.php"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "video_id": videoId,
//         "reaction": reaction,
//       }),
//     );

//     if (response.statusCode != 200) {
//       throw Exception("Error al guardar la reacción: ${response.body}");
//     }
//   }
// static Future<void> removeReaction(int videoId, String reaction) async {
//   final response = await http.delete(
//     Uri.parse("http://192.168.50.54:8080/plataforma/get_reels.php?video_id=$videoId&reaction=$reaction"),

// // Uri.parse("http://172.20.10.2:8080/plataforma/get_reels.php?video_id=$videoId&reaction=$reaction"),
//     headers: {"Content-Type": "application/json"},
//   );

//   if (response.statusCode == 200) {
//     print("Reacción eliminada correctamente");
//   } else {
//     print("Error al eliminar la reacción: ${response.body}");
//   }
// }
// }
  // static Future<void> removeReaction(int videoId, String reaction) async {
  //   final response = await http.delete(
  //     Uri.parse("http://192.168.50.54:8080/plataforma/likes.php"),
  //     // Uri.parse("http://172.20.10.2:8080/plataforma/likes.php"),
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode({
  //       "video_id": videoId,
  //       "reaction": reaction,
  //     }),
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception("Error al eliminar la reacción");
  //   }
  // }
//}
