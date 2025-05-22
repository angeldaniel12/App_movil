import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveStreamingPages extends StatefulWidget {
  const LiveStreamingPages({super.key});

  @override
  State<LiveStreamingPages> createState() => _LiveStreamingPageState();
}

class _LiveStreamingPageState extends State<LiveStreamingPages> {
  late RtcEngine _engine;
  bool _isEngineReady = false;
  bool _isJoined = false;
  List<int> _remoteUsers = [];
  String? _userName;
// Variable para verificar si es el host o espectador

  // Credenciales de Agora
  final String appId = '38b883a464a74f04a20c763bb9abb136';
  final String channelName = 'iidlive';
  final String tempToken = 'ed1ff93438174298a6906792bd02f6ef';

  @override
  void initState() {
    super.initState();
    _initializeAgora();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName');
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
// Guarda el UID del usuario
// Verifica si el usuario es el host
          });

          // Deshabilitar audio y video para el espectador
          _engine.enableLocalAudio(false);
          _engine.enableLocalVideo(false);
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
      uid: 0, // El uid 0 indica que este es un espectador
      options: const ChannelMediaOptions(),
    );

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
      appBar: AppBar(title: const Text('salas de live')),
      body: _isEngineReady
          ? Column(
              children: [
                if (_userName != null)
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
                      // El espectador no tiene vista local, solo ve a los demás
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
