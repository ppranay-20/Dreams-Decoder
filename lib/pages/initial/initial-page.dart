import 'package:murkaverse/pages/auth/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  void initState() {
    super.initState();
    // Set timer to navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => AuthWrapper()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          width: MediaQuery.of(context).size.width * 0.4,
        ),
      ),
    );
  }
}
