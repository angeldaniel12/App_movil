import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Espera 30 segundos antes de navegar
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 212, 154), // Color de fondo
      body: Center(
        child: Image.asset(
          'assets/images/logo-Photoroom.png', // Tu logo
          width: 10,
          height: 10,
        ),
      ),
    );
  }
}
