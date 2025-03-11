import 'package:dreams_decoder/pages/auth/signin.dart';
import 'package:dreams_decoder/pages/auth/signup.dart';
import 'package:dreams_decoder/widgets/buttons.dart';
import 'package:flutter/material.dart';

class LoggedOut extends StatefulWidget {
  const LoggedOut({super.key});

  @override
  State<LoggedOut> createState() => _LoggedOutState();
}

class _LoggedOutState extends State<LoggedOut> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              "cat.png",
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "logo.png",
                          fit: BoxFit.contain,
                          width: 300,
                        ),
                        SizedBox(height: 40),
                        Text(
                          "Hey there, dreamer! I'm Murka, your feline guide to the mystical world of dreams. Are you ready to explore the secrets of your nighttime adventures?",
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "With Murkaverse, we'll decode hidden messages and unravel mysteries.",
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Let's dive into the dreamscape and see what amazing stories await!",
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Button(
                        color: Color(0xFFE152C2),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Signup()));
                        },
                        child: Text("Register",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                      SizedBox(height: 10),
                      Button(
                        color: Colors.white,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Signin()));
                        },
                        child: Text("Sign In",
                            style:
                                TextStyle(color: Colors.black, fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
