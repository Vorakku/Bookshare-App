import 'dart:async';
import 'package:bookshare/tests/screens/Authentication/login.dart';
import 'package:flutter/material.dart';
// Make sure to replace this with your actual home screen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;

Route createFadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}



  @override
  void initState() {
    super.initState();

    // Initialize the Animation Controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 1), // Animation duration of 2 seconds
      vsync: this,
    );

    // Define the Tween animation
    _animation = Tween(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOut,
      ),
    );

    // Start the animation on init
    _animationController!.forward();

    // Navigate to HomeScreen after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).push(
         createFadeRoute(const LoginScreen(),)
      );
    });
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AnimatedBuilder(
          animation: _animationController!,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.translationValues(
                  _animation!.value * width, 0.0, 0.0),
              child: Center(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset('img/logo.png'),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
