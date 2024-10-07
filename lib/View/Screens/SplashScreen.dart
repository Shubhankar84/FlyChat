import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fly_chat/View/Screens/ChatPage.dart';
import 'package:fly_chat/View/Screens/LoginPage.dart';
import 'package:fly_chat/View/Screens/checkUser.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Variables for managing animations
  bool _showFlyChat = false;
  bool _showSubText = false;

  @override
  void initState() {
    super.initState();

    // Schedule animations
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _showFlyChat = true; // FlyChat appears after 0.5 sec
      });
    });
    Timer(const Duration(seconds: 1), () {
      setState(() {
        _showSubText = true; // Subtext appears after 1 sec
      });
    });

    // Navigate to home page after 5 seconds
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CheckUserScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _showFlyChat ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: const Text(
                "FlyChat",
                style: TextStyle(
                    fontSize: 40,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            AnimatedOpacity(
              opacity: _showSubText ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: Text(
                "A Safe Application for Kids",
                style: TextStyle(fontSize: 20, color: Colors.blue[900]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

