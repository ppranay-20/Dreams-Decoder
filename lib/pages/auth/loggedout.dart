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
      backgroundColor:  Colors.black,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 100, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network("assets/logo.png",fit: BoxFit.contain,width: 300,),
            SizedBox(
              height: 40,
            ),
            Text(
              "Hey there, dreamer! I'm Murka, your feline guide to the mystical world of dreams. Are you ready to explore the secrets of your nighttime adventures?",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white
              ),
            ),
            SizedBox(height: 20,),
            Text(
              "With Murkaverse, we'll decode hidden messages and unravel mysteries.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white
              ),
            ),
            SizedBox(height: 20,),
            Text(
              "Let's dive into the dreamscape and see what amazing stories await!",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white
              ),
            ),
            SizedBox(height: 20,),
            Image.asset("assets/murka.png", fit: BoxFit.contain,),
            SizedBox(height: 20,),
            Button(color: Colors.blue, onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Signup())
              );
            },child: Text("Sign Up",  style: TextStyle(color: Colors.white, fontSize: 18)),),
            SizedBox(height: 10,),
            Button(color: Colors.white, onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Signin())
              );
            },child: Text("Sign In",  style: TextStyle(color: Colors.black, fontSize: 18)),),
          ],
        ),
      ),
    );
  }
}