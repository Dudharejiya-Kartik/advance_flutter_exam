import 'dart:async';

import 'package:flutter/material.dart';
import '../home_page/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    animation = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    controller.forward();

    Timer(const Duration(seconds: 4), () {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.gavel,
                  size: 100,
                  color: Colors.blueAccent,
                ),
                SizedBox(height: 20),
                // App Name
                Text(
                  "Auction App",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
