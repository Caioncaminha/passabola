import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart'; 
import '../data/constants.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoId;

  const VideoPlayerPage({super.key, required this.videoId});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: KConstants.primaryColor,
        title: Text('Player de Vídeo', style: KTextStyle.buttonText),
      ),
      body: Center(
        child: YoutubePlayerScaffold(
          controller: _controller,
          builder: (context, player) {
            return player;
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}