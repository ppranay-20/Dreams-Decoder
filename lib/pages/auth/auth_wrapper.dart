import 'package:dreams_decoder/pages/dream_history.dart';
import 'package:dreams_decoder/pages/auth/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Listen for auth changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Show loading while checking auth
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const DreamHistory(); // User is logged in
        } else {
          return const Signin(); // No user logged in
        }
      },
    );
  }
}