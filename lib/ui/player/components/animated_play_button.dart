import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';

import '../../widgets/loader.dart';

/// A button that animates between a play and pause icon.
///
/// It also shows a loading indicator when the audio is in a loading state.
class AnimatedPlayButton extends StatefulWidget {
  /// size of the icon.
  final double iconSize;

  const AnimatedPlayButton({super.key, this.iconSize = 40.0});

  @override
  State<AnimatedPlayButton> createState() => _AnimatedPlayButtonState();
}

class _AnimatedPlayButtonState extends State<AnimatedPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetX<PlayerController>(builder: (controller) {
      final buttonState = controller.buttonState.value;
      final isPlaying = buttonState == PlayButtonState.playing;
      final isLoading = buttonState == PlayButtonState.loading;

      if (isPlaying) {
        _controller.forward();
      } else if (!isLoading) {
        _controller.reverse();
      }

      return IconButton(
        iconSize: widget.iconSize,
        onPressed: () {
          isPlaying ? controller.pause() : controller.play();
        },
        icon: isLoading
            ? const LoadingIndicator(
                dimension: 20,
              )
            : AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: _controller,
              ),
      );
    });
  }
}
