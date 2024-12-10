import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:gestion_vetement/Dashboard.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return AnimatedSplashScreen(
      splash: Center(
        child: SizedBox(
          child: Image.asset(
            'assets/animation/Good-gif.gif',
            fit: BoxFit.contain,
          ),
        ),
      ),
      nextScreen: const Dashboard(),
      duration: 5130,
      splashIconSize: screenHeight,
      backgroundColor: Colors.white,
    );
  }
}
