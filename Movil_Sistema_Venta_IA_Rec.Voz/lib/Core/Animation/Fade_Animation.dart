import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

enum AniProps { opacity, translateY }

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  const FadeAnimation({required this.delay, required this.child, Key? key}) 
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tween = MovieTween()
      ..tween(
        AniProps.opacity,
        Tween(begin: 0.0, end: 1.0),
        duration: 500.milliseconds,
      )
      ..tween(
        AniProps.translateY,
        Tween(begin: -30.0, end: 0.0),
        duration: 500.milliseconds,
        curve: Curves.easeOut,
      );

    return PlayAnimationBuilder<Movie>(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.get(AniProps.opacity),
          child: Transform.translate(
            offset: Offset(0, value.get(AniProps.translateY)), 
            child: child,
          ),
        );
      },
    );
  }
}