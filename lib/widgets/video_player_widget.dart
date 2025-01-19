import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final Color color;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.color,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late CachedVideoPlayerPlusController cachedVideoPlayerPlusController;
  bool isPlaying = false;

  @override
  void initState() {
    cachedVideoPlayerPlusController = CachedVideoPlayerPlusController.network(
      widget.videoUrl,
    )
      ..addListener(() {})
      ..initialize().then((_) {
        cachedVideoPlayerPlusController.setVolume(1);
      });
    super.initState();
  }

  @override
  void dispose() {
    cachedVideoPlayerPlusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 10 / 10,
      child: Stack(
        children: [
          CachedVideoPlayerPlus(cachedVideoPlayerPlusController),
          Center(
            child: IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: widget.color,
              ), // Icon
              onPressed: () {
                setState(() {
                  isPlaying = !isPlaying;
                  isPlaying
                      ? cachedVideoPlayerPlusController.play()
                      : cachedVideoPlayerPlusController.pause();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
