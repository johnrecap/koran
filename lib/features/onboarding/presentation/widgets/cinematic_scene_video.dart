import 'package:flutter/material.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:video_player/video_player.dart';

class CinematicSceneVideo extends StatefulWidget {
  const CinematicSceneVideo({
    required this.assetPath,
    required this.fallbackIcon,
    super.key,
  });

  final String assetPath;
  final IconData fallbackIcon;

  @override
  State<CinematicSceneVideo> createState() => _CinematicSceneVideoState();
}

class _CinematicSceneVideoState extends State<CinematicSceneVideo> {
  VideoPlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final controller = VideoPlayerController.asset(widget.assetPath);
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
      });
    } catch (error, stackTrace) {
      AppLogger.error(
        'CinematicSceneVideo._initialize',
        error,
        stackTrace,
      );
      await controller.dispose();
      if (!mounted) {
        return;
      }

      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_hasError || controller == null || !controller.value.isInitialized) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.06),
              Colors.black.withValues(alpha: 0.22),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            widget.fallbackIcon,
            size: 72,
            color: Colors.white.withValues(alpha: 0.82),
          ),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}
