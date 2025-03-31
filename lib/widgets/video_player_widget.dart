import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.color,
    required this.viewOnly,
    this.autoPlay = false,
    this.looping = false,
  });

  final String videoUrl;
  final Color color;
  final bool viewOnly;
  final bool autoPlay;
  final bool looping;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _showReplay = false;
  bool _isReplaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final file = await DefaultCacheManager().getSingleFile(widget.videoUrl);
      _videoController = VideoPlayerController.file(file)
        ..setLooping(widget.looping)
        ..addListener(_checkVideoStatus);

      await _videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        allowMuting: true,
        allowPlaybackSpeedChanging: false,
        showControls: !widget.viewOnly,
        materialProgressColors: ChewieProgressColors(
          playedColor: widget.color,
          handleColor: widget.color,
          bufferedColor: Colors.grey.shade300,
        ),
        placeholder: Container(color: Colors.black),
        autoInitialize: true,
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Video player error: $e');
    }
  }

  void _checkVideoStatus() {
    if (_videoController.value.isInitialized &&
        !_videoController.value.isPlaying &&
        _videoController.value.position == _videoController.value.duration) {
      if (mounted) {
        setState(() => _showReplay = true);
      }
    } else {
      if (mounted && _showReplay) {
        setState(() => _showReplay = false);
      }
    }
  }

  Future<void> _replayVideo() async {
    setState(() {
      _isReplaying = true;
      _showReplay = false;
    });

    await _videoController.seekTo(Duration.zero);
    await _videoController.play();

    if (mounted) {
      setState(() => _isReplaying = false);
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_checkVideoStatus);
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 16,
      child: Stack(
        children: [
          if (_isLoading && !_isReplaying)
            Container(
              color: Colors.black,
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (_chewieController == null)
            Container(
              color: Colors.black,
              child: const Center(
                child: Icon(Icons.error_outline, color: Colors.red, size: 40),
              ),
            )
          else
            Chewie(controller: _chewieController!),

          // Replay button overlay
          if (_showReplay && !_isReplaying)
            Center(
              child: GestureDetector(
                onTap: _replayVideo,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.replay,
                    color: widget.color,
                    size: 40,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}