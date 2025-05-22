import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/reels.dart';
import '../services/reels_services.dart';

class ReelsScreen extends StatefulWidget {
  @override
  _ReelsScreenState createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late Future<List<Reel>> _reelsFuture;

  @override
  void initState() {
    super.initState();
    _reelsFuture = ReelService.fetchReels();
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[10], // 🎨 Fondo general gris clarito
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 165, 144, 200), // 🎨 AppBar morado
        title: const Text(
          'Reels',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.post_add, color: Colors.white),
            tooltip: 'Post',
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFD04284), // 🎨 Fondo morado en la parte superior
            height: MediaQuery.of(context).size.height * 0.4, // 40% de alto
            width: double.infinity,
          ),
          FutureBuilder<List<Reel>>(
            future: _reelsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final reels = snapshot.data!;
                return PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: reels.length,
                  itemBuilder: (context, index) {
                    return ReelPlayer(reel: reels[index]);
                  },
                );
              } else {
                return const Center(child: Text('No hay reels disponibles.'));
              }
            },
          ),
        ],
      ),
    );
  }
}

class ReelPlayer extends StatefulWidget {
  final Reel reel;

  const ReelPlayer({Key? key, required this.reel}) : super(key: key);

  @override
  _ReelPlayerState createState() => _ReelPlayerState();
}

class _ReelPlayerState extends State<ReelPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  // bool _isPlaying = false;
  String? _userReaction;
  Map<String, int> _reactionsCount = {
    "likes": 0,
    "love": 0,
    "happy": 0,
  };

  @override
  void initState() {
    super.initState();
    _loadReactions();
    String videoUrl = getVideoUrl(widget.reel.videoName);
    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.play();
          // _isPlaying = true;
        });
      }).catchError((error) {
        print('Error al cargar el video: $error');
      });

    _controller.setLooping(true);
    _loadUserReaction();
  }
void _loadReactions() async {
  try {
    int videoId = int.tryParse(widget.reel.videoId.toString()) ?? 0;
    if (videoId == 0) return;

    Map<String, dynamic> reactionData = await ReelService.getReactions(videoId);

    setState(() {
      _userReaction = reactionData["userReaction"];
      _reactionsCount = {
        "likes": reactionData["likes"] ?? 0,
        "love": reactionData["love"] ?? 0,
        "happy": reactionData["happy"] ?? 0,
      };
    });
  } catch (error) {
    print("Error al obtener reacciones: $error");
  }
}

void _toggleReaction(String reaction) async {
  try {
    int videoId = int.tryParse(widget.reel.videoId.toString()) ?? 0;
    if (videoId == 0) return;

    if (_userReaction == reaction) {
      await ReelService.removeReaction(videoId, reaction);
      setState(() {
        _userReaction = null;
        _reactionsCount[reaction] = (_reactionsCount[reaction]! - 1).clamp(0, double.infinity).toInt();
      });
    } else {
      await ReelService.saveReaction(videoId, reaction);
      setState(() {
        _userReaction = reaction;
        _reactionsCount[reaction] = (_reactionsCount[reaction]! + 1);
      });
    }
  } catch (error) {
    print("Error al guardar la reacción: $error");
  }
}




  void _loadUserReaction() async {
    try {
      int videoId = int.tryParse(widget.reel.videoId.toString()) ?? 0;
      if (videoId == 0) return;

      Map<String, dynamic> reactionData = await ReelService.getReactions(videoId);
     setState(() {
      _userReaction = reactionData["userReaction"];
      _reactionsCount = {
        "likes": reactionData["likes"] ?? 0,
        "love": reactionData["love"] ?? 0,
        "happy": reactionData["happy"] ?? 0,
      };
    });
    } catch (error) {
      print("Error al cargar las reacciones: $error");
    }
  }

  void _togglePlayPause() {
    if (!_controller.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("El video no está listo aún.")),
      );
      return;
    }

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  

  String getVideoUrl(String videoPath) {
    // 172.20.10.2:8080
      //final baseUrl = 'http://192.168.1.201:8080/plataforma/reels/';

    final baseUrl = 'http://172.20.10.2:8080/plataforma/reels/';
    return baseUrl + videoPath.replaceFirst('plataforma/reels/', '');
  }

  String getAvatarUrl(String avatarPath) {
     //final baseUrl = 'http://172.20.10.2:8080/plataforma/avatars/';

     final baseUrl = 'http://172.20.10.2:8080/plataforma/avatars/';
    return baseUrl + avatarPath;
  }
   String _formatDateTime(DateTime dateTime) {
     return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} - ${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
   }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Video player ocupando toda la pantalla
        Center(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
        // Fondo semitransparente para la parte inferior con la descripción y el avatar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.black.withOpacity(0.6),
            child: Row(
              children: [
                // Avatar y nombre del usuario
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(getAvatarUrl(widget.reel.userAvatar)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.reel.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.reel.videoDescription,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatDateTime(widget.reel.videoCreatedAt),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Reacciones fuera de la caja de descripción, en la parte superior derecha
        // Reacciones fuera de la caja de descripción, en la parte superior derecha
Positioned(
  top: 50,
  right: 10,
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center, // Centrar verticalmente
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      // Like button y cantidad
      IconButton(
        icon: Icon(
          _userReaction == "likes" ? Icons.thumb_up : Icons.thumb_up_outlined,
          color: Colors.blue,
        ),
        onPressed: () => _toggleReaction('likes'),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Text(
          _reactionsCount["likes"]!.toString(),
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
      // Love button y cantidad
      IconButton(
        icon: Icon(
          _userReaction == "love" ? Icons.favorite : Icons.favorite_border,
          color: Colors.red,
        ),
        onPressed: () => _toggleReaction('love'),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Text(
          _reactionsCount["love"]!.toString(),
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
      // Happy button y cantidad
      IconButton(
        icon: Icon(
          _userReaction == "happy" ? Icons.sentiment_satisfied : Icons.sentiment_satisfied_alt,
          color: Colors.green,
        ),
        onPressed: () => _toggleReaction('happy'),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Text(
          _reactionsCount["happy"]!.toString(),
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    ],
  ),
),

      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
