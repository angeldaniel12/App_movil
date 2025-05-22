import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveStreamingPage extends StatefulWidget {
  const LiveStreamingPage({super.key});

  @override
  State<LiveStreamingPage> createState() => _LiveStreamingPageState();
}

class _LiveStreamingPageState extends State<LiveStreamingPage> {
  late RtcEngine _engine;
  bool _isEngineReady = false;
  bool _isJoined = false;
  List<int> _remoteUsers = [];
  int? _hostUid;
  String? _userName; // Variable para almacenar el nombre del usuario

  // Credenciales de Agora
  final String appId = '38b883a464a74f04a20c763bb9abb136';
  final String channelName = 'iidlive';
  final String tempToken = 'ed1ff93438174298a6906792bd02f6ef';

  @override
  void initState() {
    super.initState();
    _initializeAgora();
    _loadUserName(); // Cargar el nombre del usuario al inicio
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName'); // Cargar el nombre guardado
    });
  }

  Future<void> _initializeAgora() async {
    await _requestPermissions();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          setState(() {
            _isJoined = true;
            _hostUid = connection.localUid; // Guarda el UID del usuario
          });
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() {
            _remoteUsers.add(remoteUid);
          });
        },
        onUserOffline: (connection, remoteUid, reason) {
          setState(() {
            _remoteUsers.remove(remoteUid);
          });
        },
      ),
    );

    await _engine.joinChannel(
      token: tempToken,
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );

    await _engine.startPreview();

    setState(() {
      _isEngineReady = true;
    });
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Streaming')),
      body: _isEngineReady
          ? Column(
              children: [
                if (_userName != null) // Muestra el nombre del usuario si está disponible
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Transmisión de: $_userName',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      ),
                      if (_remoteUsers.isNotEmpty)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Column(
                            children: _remoteUsers.map((uid) {
                              return Container(
                                width: 120,
                                height: 160,
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue, width: 2),
                                ),
                                child: AgoraVideoView(
                                  controller: VideoViewController.remote(
                                    rtcEngine: _engine,
                                    canvas: VideoCanvas(uid: uid),
                                    connection: RtcConnection(channelId: channelName),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_isJoined && _hostUid == 0)
                  ElevatedButton(
                    onPressed: () async {
                      await _engine.leaveChannel();
                      setState(() {
                        _isJoined = false;
                        _remoteUsers.clear();
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Terminar Transmisión'),
                  ),
                if (!_isJoined)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}


//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:iidlive_app/models/post.dart';
// import 'package:iidlive_app/models/reels.dart';
// import 'package:iidlive_app/models/usuarioperfil.dart';
// import 'package:iidlive_app/widgets/custom_drawer.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Home extends StatefulWidget {
//   final Map<String, dynamic> usuario;

//   const Home({Key? key, required this.usuario}) : super(key: key);

//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   String? categoriaSeleccionada;
//   List<String> categorias = [];
//   List<Post> _posts = [];
//   bool _isLoading = true;
//   Map<int, bool> _likedPosts = {};

//   @override
//   void initState() {
//     super.initState();
//     _fetchCategorias();
//     _loadPostsAndLikes();
//   }

//   String formatDate(String dateString) {
//     DateTime dateTime = DateTime.parse(dateString);
//     return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
//   }

//   Future<void> _fetchCategorias() async {
//     const String categoriasApiUrl =
//         "http://169.254.191.190:8080/plataforma/get_categorias.php";
//     // "http://169.254.85.101:8080/plataforma/get_categorias.php";

//     try {
//       final response = await http.get(Uri.parse(categoriasApiUrl));
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         if (data.containsKey('categorias') && data['categorias'] is List) {
//           setState(() {
//             categorias = ['Todos'];
//             categorias.addAll(List<String>.from(
//                 data['categorias'].map((c) => c['nameCategoria'] as String)));
//             categoriaSeleccionada = 'Todos'; // Selección inicial
//           });
//         } else {
//           throw Exception('La clave "categorias" no contiene una lista');
//         }
//       } else {
//         throw Exception('Error en la respuesta: ${response.statusCode}');
//       }
//     } catch (e) {
//       print("Error al cargar categorías: $e");
//     }
//   }

//   Future<List<Post>> _fetchPosts() async {
//     String apiUrl =
//         // "http://192.168.50.153:8080/plataforma/get_post.php";
//         "http://169.254.191.190:8080/plataforma/get_post.php";
//     if (categoriaSeleccionada != null && categoriaSeleccionada != 'Todos') {
//       apiUrl += "?categoria=${Uri.encodeComponent(categoriaSeleccionada!)}";
//     }

//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         if (data.containsKey('posts')) {
//           final List<dynamic> postsJson = data['posts'];
//           return postsJson.map((json) => Post.fromJson(json)).toList();
//         } else {
//           throw Exception('El JSON no contiene la clave "posts".');
//         }
//       } else {
//         throw Exception('Error HTTP: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error al obtener posts: $e');
//     }
//   }

//   Future<void> _sendReaction({
//     required int userId,
//     required int postId,
//     required int likes,
//   }) async {
//     final url = Uri.parse(
//         // "http://192.168.50.153:8080/plataforma/guardar_reaccion.php"
//         "http://169.254.191.190:8080/plataforma/guardar_reaccion.php");

//     try {
//       final response = await http.post(
//         url,
//         body: {
//           'user_id': userId.toString(),
//           'post_id': postId.toString(),
//           'likes': likes.toString(),
//           'likeable_type': 'App\\Models\\Post',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           print('✅ Reacción guardada: ${data['message']}');
//         } else {
//           print('⚠️ Error desde el servidor: ${data['error']}');
//         }
//       } else {
//         print('❌ Error HTTP: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❗ Error en reacción: $e');
//     }
//   }

//   Future<void> _loadPostsAndLikes() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final posts = await _fetchPosts();
//       final prefs = await SharedPreferences.getInstance();
//       final userId = int.parse(widget.usuario['id'].toString());

//       Map<int, bool> likedMap = {};
//       for (var post in posts) {
//         bool liked = prefs.getBool('like_post_${post.id}_$userId') ?? false;
//         likedMap[post.id] = liked;
//       }

//       setState(() {
//         _posts = posts;
//         _likedPosts = likedMap;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error cargando posts y likes: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _onCategoriaChanged(String? newCategoria) {
//     setState(() {
//       categoriaSeleccionada = newCategoria;
//     });
//     _loadPostsAndLikes();
//   }

//   Future<String?> _getUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('usuario');
//   }

//   Future<void> _logout(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   //imagen del post
//   String getImageUrl(String imagePath) {
//     const baseUrl =
//         // "http://192.168.50.153:8080/plataforma/"
//         'http://169.254.191.190:8080/plataforma/';
//     return baseUrl + imagePath.replaceFirst('plataforma/', '');
//   }

//   String getUserAvatarUrl(String? fileName) {
//     const baseUrl =
//         // 'http://192.168.50.153:8080/'
//         'http://169.254.191.190:8080/'; // tu IP y puerto
//     if (fileName == null || fileName.isEmpty) {
//       return
//           // 'http://192.168.50.153:8080/plataforma/perfil/avatar.png'
//           'http://169.254.191.190:8080/plataforma/perfil/avatar.png';
//     }
//     return baseUrl + fileName; // Concatenamos la ruta completa
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<String?>(
//       future: _getUserData(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError || !snapshot.hasData) {
//           return const Center(child: Text('Error al cargar datos'));
//         } else {
//           final userJson = jsonDecode(snapshot.data!) as Map<String, dynamic>;
//           final usuario = Usuario.fromJson(userJson);

//           return Scaffold(
//             backgroundColor: Colors.grey[10],
//             appBar: AppBar(
//               backgroundColor: const Color(0xFFC17C9C),
//               title: const Text('Bienvenido a tu muro',
//                   style: TextStyle(color: Colors.white)),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.video_collection,
//                       size: 30, color: Colors.white),
//                   onPressed: () {
//                     final myReel = Reel(
//                       videoId: '1',
//                       videoName: 'video.mp4',
//                       videoDescription: 'Descripción del video',
//                       videoUserId: 'user1',
//                       videoCreatedAt: DateTime.now(),
//                       reactions: {"likes": 0, "love": 0, "happy": 0},
//                       userName: 'Usuario',
//                       userAvatar: 'url_avatar',
//                     );
//                     Navigator.pushNamed(context, '/vistaReels',
//                         arguments: myReel);
//                   },
//                 )
//               ],
//             ),
//             drawer: CustomDrawer(
//               usuario: usuario,
//               parentContext: context,
//               onLogout: () => _logout(context),
//             ),
//             body: Stack(
//               children: [
//                 Container(
//                   color: const Color(0xFFC17C9C),
//                   height: MediaQuery.of(context).size.height * 0.6,
//                   width: double.infinity,
//                 ),
//                 SafeArea(
//                   child: Container(
//                     margin: const EdgeInsets.only(top: 20),
//                     child: Column(
//                       children: [
//                         if (categorias.isNotEmpty) ...[
//                           // Padding(
//                           //   padding: const EdgeInsets.symmetric(horizontal: 10),
//                           //   child: DropdownButton<String>(
//                           //     value: categoriaSeleccionada,
//                           //     hint: const Text('Selecciona una categoría'),
//                           //     isExpanded: true,
//                           //     onChanged: _onCategoriaChanged,
//                           //     items: categorias.map((categoria) {
//                           //       return DropdownMenuItem(
//                           //         value: categoria,
//                           //         child: Text(categoria),
//                           //       );
//                           //     }).toList(),
//                           //   ),
//                           // ),
//                           SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             child: Row(
//                               children: categorias.map((categoria) {
//                                 final isSelected =
//                                     categoria == categoriaSeleccionada;
//                                 return Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(horizontal: 4),
//                                   child: ElevatedButton(
//                                     onPressed: () {
//                                       _onCategoriaChanged(categoria);
//                                     },
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: isSelected
//                                           ? Colors.deepPurple
//                                           : Colors.grey[300],
//                                       foregroundColor: isSelected
//                                           ? Colors.white
//                                           : Colors.black,
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(20)),
//                                     ),
//                                     child: Text(categoria),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         ],
//                         Expanded(
//   child: _isLoading
//       ? const Center(child: CircularProgressIndicator())
//       : _posts.isEmpty
//           ? const Center(child: Text('No hay posts disponibles.'))
//           : ListView.builder(
//               itemCount: _posts.length,
//               itemBuilder: (context, index) {
//                 final post = _posts[index];
//                 final isLiked = _likedPosts[post.id] ?? false;

//                 return Card(
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20)),
//                   color: Colors.white,
//                   elevation: 5,
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             CircleAvatar(
//                               radius: 20,
//                               foregroundImage:
//                                   NetworkImage(getUserAvatarUrl(post.userAvatar)),
//                               backgroundColor: Colors.grey[200],
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     post.userName,
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   const SizedBox(height: 2),
//                                   Text(
//                                     formatDate(post.createdAt),
//                                     style: const TextStyle(
//                                         color: Colors.grey, fontSize: 12),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         Text(post.content),
//                         if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 10),
//                             child: Image.network(
//                               getImageUrl(post.imageUrl!),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         Row(
//                           children: [
//                             IconButton(
//                               icon: Icon(
//                                 isLiked
//                                     ? Icons.favorite
//                                     : Icons.favorite_border,
//                                 color: isLiked ? Colors.red : Colors.grey,
//                               ),
//                               onPressed: () async {
//                                 final prefs = await SharedPreferences.getInstance();
//                                 setState(() {
//                                   if (isLiked) {
//                                     post.likesCount--;
//                                     _likedPosts[post.id] = false;
//                                     prefs.remove(
//                                         'like_post_${post.id}_${widget.usuario['id']}');
//                                     _sendReaction(
//                                       userId: int.parse(widget.usuario['id'].toString()),
//                                       postId: post.id,
//                                       likes: 0,
//                                     );
//                                   } else {
//                                     post.likesCount++;
//                                     _likedPosts[post.id] = true;
//                                     prefs.setBool(
//                                         'like_post_${post.id}_${widget.usuario['id']}',
//                                         true);
//                                     _sendReaction(
//                                       userId: int.parse(widget.usuario['id'].toString()),
//                                       postId: post.id,
//                                       likes: 1,
//                                     );
//                                   }
//                                 });
//                               },
//                             ),
//                             Text('${post.likesCount} Likes'),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
// ),

//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//       },
//     );
//   }
// }


//otra vista de home 
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:iidlive_app/models/post.dart';
// import 'package:iidlive_app/models/reels.dart';
// import 'package:iidlive_app/models/usuarioperfil.dart';
// import 'package:iidlive_app/widgets/custom_drawer.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Home extends StatefulWidget {
//   final Map<String, dynamic> usuario;

//   const Home({Key? key, required this.usuario}) : super(key: key);

//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   String? categoriaSeleccionada;
//   List<String> categorias = [];
//   List<Post> _posts = [];
//   bool _isLoading = true;
//   Map<int, bool> _likedPosts = {};

//   @override
//   void initState() {
//     super.initState();
//     _fetchCategorias();
//     _loadPostsAndLikes();
//   }

//   String formatDate(String dateString) {
//     DateTime dateTime = DateTime.parse(dateString);
//     return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
//   }

//   Future<void> _fetchCategorias() async {
//     const String categoriasApiUrl =
//         "http://169.254.191.190:8080/plataforma/get_categorias.php";
//     // "http://169.254.85.101:8080/plataforma/get_categorias.php";

//     try {
//       final response = await http.get(Uri.parse(categoriasApiUrl));
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         if (data.containsKey('categorias') && data['categorias'] is List) {
//           setState(() {
//             categorias = ['Todos'];
//             categorias.addAll(List<String>.from(
//                 data['categorias'].map((c) => c['nameCategoria'] as String)));
//             categoriaSeleccionada = 'Todos'; // Selección inicial
//           });
//         } else {
//           throw Exception('La clave "categorias" no contiene una lista');
//         }
//       } else {
//         throw Exception('Error en la respuesta: ${response.statusCode}');
//       }
//     } catch (e) {
//       print("Error al cargar categorías: $e");
//     }
//   }

//   Future<List<Post>> _fetchPosts() async {
//     String apiUrl =
//         // "http://192.168.50.153:8080/plataforma/get_post.php";
//         "http://169.254.191.190:8080/plataforma/get_post.php";
//     if (categoriaSeleccionada != null && categoriaSeleccionada != 'Todos') {
//       apiUrl += "?categoria=${Uri.encodeComponent(categoriaSeleccionada!)}";
//     }

//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         if (data.containsKey('posts')) {
//           final List<dynamic> postsJson = data['posts'];
//           return postsJson.map((json) => Post.fromJson(json)).toList();
//         } else {
//           throw Exception('El JSON no contiene la clave "posts".');
//         }
//       } else {
//         throw Exception('Error HTTP: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error al obtener posts: $e');
//     }
//   }

//   Future<void> _sendReaction({
//     required int userId,
//     required int postId,
//     required int likes,
//   }) async {
//     final url = Uri.parse(
//         // "http://192.168.50.153:8080/plataforma/guardar_reaccion.php"
//         "http://169.254.191.190:8080/plataforma/guardar_reaccion.php");

//     try {
//       final response = await http.post(
//         url,
//         body: {
//           'user_id': userId.toString(),
//           'post_id': postId.toString(),
//           'likes': likes.toString(),
//           'likeable_type': 'App\\Models\\Post',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           print('✅ Reacción guardada: ${data['message']}');
//         } else {
//           print('⚠️ Error desde el servidor: ${data['error']}');
//         }
//       } else {
//         print('❌ Error HTTP: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❗ Error en reacción: $e');
//     }
//   }

//   Future<void> _loadPostsAndLikes() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final posts = await _fetchPosts();
//       final prefs = await SharedPreferences.getInstance();
//       final userId = int.parse(widget.usuario['id'].toString());

//       Map<int, bool> likedMap = {};
//       for (var post in posts) {
//         bool liked = prefs.getBool('like_post_${post.id}_$userId') ?? false;
//         likedMap[post.id] = liked;
//       }

//       setState(() {
//         _posts = posts;
//         _likedPosts = likedMap;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error cargando posts y likes: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _onCategoriaChanged(String? newCategoria) {
//     setState(() {
//       categoriaSeleccionada = newCategoria;
//     });
//     _loadPostsAndLikes();
//   }

//   Future<String?> _getUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('usuario');
//   }

//   Future<void> _logout(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   //imagen del post
//   String getImageUrl(String imagePath) {
//     const baseUrl =
//         // "http://192.168.50.153:8080/plataforma/"
//         'http://169.254.191.190:8080/plataforma/';
//     return baseUrl + imagePath.replaceFirst('plataforma/', '');
//   }

//   String getUserAvatarUrl(String? fileName) {
//     const baseUrl =
//         // 'http://192.168.50.153:8080/'
//         'http://169.254.191.190:8080/'; // tu IP y puerto
//     if (fileName == null || fileName.isEmpty) {
//       return
//           // 'http://192.168.50.153:8080/plataforma/perfil/avatar.png'
//           'http://169.254.191.190:8080/plataforma/perfil/avatar.png';
//     }
//     return baseUrl + fileName; // Concatenamos la ruta completa
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<String?>(
//       future: _getUserData(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError || !snapshot.hasData) {
//           return const Center(child: Text('Error al cargar datos'));
//         } else {
//           final userJson = jsonDecode(snapshot.data!) as Map<String, dynamic>;
//           final usuario = Usuario.fromJson(userJson);

//           return Scaffold(
//             backgroundColor: Colors.grey[10],
//             appBar: AppBar(
//               backgroundColor: const Color(0xFFC17C9C),
//               title: const Text('Bienvenido a tu muro',
//                   style: TextStyle(color: Colors.white)),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.video_collection,
//                       size: 30, color: Colors.white),
//                   onPressed: () {
//                     final myReel = Reel(
//                       videoId: '1',
//                       videoName: 'video.mp4',
//                       videoDescription: 'Descripción del video',
//                       videoUserId: 'user1',
//                       videoCreatedAt: DateTime.now(),
//                       reactions: {"likes": 0, "love": 0, "happy": 0},
//                       userName: 'Usuario',
//                       userAvatar: 'url_avatar',
//                     );
//                     Navigator.pushNamed(context, '/vistaReels',
//                         arguments: myReel);
//                   },
//                 )
//               ],
//             ),
//             drawer: CustomDrawer(
//               usuario: usuario,
//               parentContext: context,
//               onLogout: () => _logout(context),
//             ),
//             body: Stack(
//               children: [
//                 Container(
//                   color: const Color(0xFFC17C9C),
//                   height: MediaQuery.of(context).size.height * 0.6,
//                   width: double.infinity,
//                 ),
//                 SafeArea(
//                   child: Container(
//                     margin: const EdgeInsets.only(top: 20),
//                     child: Column(
//                       children: [
//                         if (categorias.isNotEmpty) ...[
//                           // Padding(
//                           //   padding: const EdgeInsets.symmetric(horizontal: 10),
//                           //   child: DropdownButton<String>(
//                           //     value: categoriaSeleccionada,
//                           //     hint: const Text('Selecciona una categoría'),
//                           //     isExpanded: true,
//                           //     onChanged: _onCategoriaChanged,
//                           //     items: categorias.map((categoria) {
//                           //       return DropdownMenuItem(
//                           //         value: categoria,
//                           //         child: Text(categoria),
//                           //       );
//                           //     }).toList(),
//                           //   ),
//                           // ),
//                           SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             child: Row(
//                               children: categorias.map((categoria) {
//                                 final isSelected =
//                                     categoria == categoriaSeleccionada;
//                                 return Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(horizontal: 4),
//                                   child: ElevatedButton(
//                                     onPressed: () {
//                                       _onCategoriaChanged(categoria);
//                                     },
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: isSelected
//                                           ? Colors.deepPurple
//                                           : Colors.grey[300],
//                                       foregroundColor: isSelected
//                                           ? Colors.white
//                                           : Colors.black,
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(20)),
//                                     ),
//                                     child: Text(categoria),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         ],
//                         Expanded(
//                           child: _isLoading
//                               ? const Center(child: CircularProgressIndicator())
//                               : _posts.isEmpty
//                                   ? const Center(
//                                       child: Text('No hay posts disponibles.'))
//                                   : ListView.builder(
//                                       itemCount: _posts.length,
//                                       itemBuilder: (context, index) {
//                                         final post = _posts[index];
//                                         final isLiked =
//                                             _likedPosts[post.id] ?? false;

//                                         return Card(
//                                           margin: const EdgeInsets.symmetric(
//                                               horizontal: 12, vertical: 8),
//                                           shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(20)),
//                                           color: Colors.white,
//                                           elevation: 5,
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(12),
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Row(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     CircleAvatar(
//                                                       radius: 20,
//                                                       foregroundImage:
//                                                           NetworkImage(
//                                                               getUserAvatarUrl(post
//                                                                   .userAvatar)),
//                                                       backgroundColor:
//                                                           Colors.grey[200],
//                                                     ),
//                                                     const SizedBox(width: 10),
//                                                     Expanded(
//                                                       child: Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           Text(
//                                                             post.userName,
//                                                             style: const TextStyle(
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .bold),
//                                                           ),
//                                                           const SizedBox(
//                                                               height: 2),
//                                                           Text(
//                                                             formatDate(
//                                                                 post.createdAt),
//                                                             style:
//                                                                 const TextStyle(
//                                                                     color: Colors
//                                                                         .grey,
//                                                                     fontSize:
//                                                                         12),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 const SizedBox(height: 10),
//                                                 Text(post.content),
//                                                 if (post.imageUrl != null &&
//                                                     post.imageUrl!.isNotEmpty)
//                                                   Padding(
//                                                     padding: const EdgeInsets
//                                                         .symmetric(
//                                                         vertical: 10),
//                                                     child: Image.network(
//                                                       getImageUrl(
//                                                           post.imageUrl!),
//                                                       fit: BoxFit.cover,
//                                                     ),
//                                                   ),
//                                                 Row(
//                                                   children: [
//                                                     IconButton(
//                                                       icon: Icon(
//                                                         isLiked
//                                                             ? Icons.favorite
//                                                             : Icons
//                                                                 .favorite_border,
//                                                         color: isLiked
//                                                             ? Colors.red
//                                                             : Colors.grey,
//                                                       ),
//                                                       onPressed: () async {
//                                                         final prefs =
//                                                             await SharedPreferences
//                                                                 .getInstance();
//                                                         setState(() {
//                                                           if (isLiked) {
//                                                             post.likesCount--;
//                                                             _likedPosts[post
//                                                                 .id] = false;
//                                                             prefs.remove(
//                                                                 'like_post_${post.id}_${widget.usuario['id']}');
//                                                             _sendReaction(
//                                                               userId: int.parse(
//                                                                   widget
//                                                                       .usuario[
//                                                                           'id']
//                                                                       .toString()),
//                                                               postId: post.id,
//                                                               likes: 0,
//                                                             );
//                                                           } else {
//                                                             post.likesCount++;
//                                                             _likedPosts[
//                                                                 post.id] = true;
//                                                             prefs.setBool(
//                                                                 'like_post_${post.id}_${widget.usuario['id']}',
//                                                                 true);
//                                                             _sendReaction(
//                                                               userId: int.parse(
//                                                                   widget
//                                                                       .usuario[
//                                                                           'id']
//                                                                       .toString()),
//                                                               postId: post.id,
//                                                               likes: 1,
//                                                             );
//                                                           }
//                                                         });
//                                                       },
//                                                     ),
//                                                     Text(
//                                                         '${post.likesCount} Likes'),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//       },
//     );
//   }
// }