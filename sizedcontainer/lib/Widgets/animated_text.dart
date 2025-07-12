import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';


class AnimatedTextWidget extends StatelessWidget {
  const AnimatedTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Text'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText('Ahmad Latif',textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
                speed: const Duration( milliseconds: 100 ))
              ],
              totalRepeatCount: 4,
              pause: const Duration(milliseconds: 200),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),
            AnimatedTextKit(
              animatedTexts: [
                RotateAnimatedText('Hello',textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white60,
                  fontSize: 30),
                  ),
                RotateAnimatedText('Beautiful',textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
                ),
                RotateAnimatedText('World',textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
                )
              ],
              // totalRepeatCount: 4,
              // pause: Duration(milliseconds: 200),
              // displayFullTextOnTap: true,
              // stopPauseOnTap: true,
            ),
            AnimatedTextKit(animatedTexts: [
              WavyAnimatedText('Hello World'),
              WavyAnimatedText('Hello World')
            ])
          ],
        ),
      ),
    );
  }
}
