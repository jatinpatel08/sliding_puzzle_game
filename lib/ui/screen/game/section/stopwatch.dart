import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:slide_puzzle/ui/icons/stopwatch.dart';
import 'package:slide_puzzle/ui/screen/game/utils/format.dart';

/// Widget shows the current time of
/// a game.
class GameStopwatchWidget extends StatefulWidget {
  final int time;

  final String Function(int) timeFormatter;

  final double fontSize;

  const GameStopwatchWidget({
    super.key,
    required this.time,
    required this.fontSize,
    this.timeFormatter = formatElapsedTime,
  });

  @override
  State<GameStopwatchWidget> createState() => _GameStopwatchWidgetState();
}

class _GameStopwatchWidgetState extends State<GameStopwatchWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  Timer? timer;

  @override
  void initState() {
    controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.ease,
    );

    super.initState();

    final isPlaying = widget.time != 0;
    _performSetIsPlaying(isPlaying);
  }

  @override
  void didUpdateWidget(GameStopwatchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasPlaying = oldWidget.time != 0;
    final isPlaying = widget.time != 0;

    if (isPlaying != wasPlaying) {
      _performSetIsPlaying(isPlaying);
    }
  }

  void _performSetIsPlaying(final bool isPlaying) {
    // Play scale animation when the state of the
    // game changes.
    if (isPlaying) {
      controller.forward();
    } else {
      controller.reverse();
    }

    // Control the timer.
    _disposeTimer();

    if (isPlaying) {
      timer = Timer.periodic(
        const Duration(milliseconds: 100),
        (timer) => setState(() {}), // rebuild the widget
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = widget.time != 0
        ? DateTime.now().millisecondsSinceEpoch - widget.time
        : 0;
    final timeStr = widget.timeFormatter(time);
    // final timeStrAtStartOfMinute = widget.timeFormatter(time - time % (1000 * 60));

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          alignment: const Alignment(0.0, 0.75),
          scale: 0.8 + 0.2 * animation.value,
          child: child,
        );
      },
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 200,
            child: Text(
              timeStr,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).iconTheme.color,
                    fontSize: widget.fontSize,
                  ),
            ),
          ),
          // const SizedBox(width: 16.0),
          Visibility(
            visible: false,
            child: StopwatchIcon(
              size: 24,
              millis: time,
              color: Theme.of(context).iconTheme.color ?? Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _disposeTimer();
    super.dispose();
  }

  void _disposeTimer() {
    timer?.cancel();
    timer = null;
  }
}
