import 'dart:convert';

import 'package:dreams_decoder/pages/home/dream_history.dart';
import 'package:dreams_decoder/pages/auth/signup.dart';
import 'package:dreams_decoder/utils/convert-to-uri.dart';
import 'package:dreams_decoder/utils/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void login(String email, String password, BuildContext context) async {
    if (email == "" || password == "") {
      showErrorSnackBar(context, "Email and Password required");
      return;
    }

    try {
      final url = getAPIUrl('auth/login');
      final response = await http.post(url,body: jsonEncode({
        "email": email,
        "password": password
      }), headers: {
        'Content-Type': 'application/json'
      });

      if (response.statusCode == 200) {
        SharedPreferences pref = await SharedPreferences.getInstance();
        final data = jsonDecode(response.body);
        final token = data['token'];
        pref.setString('token', token);
        showSuccessSnackbar(context, "Login Successful");
        Navigator.push(context, MaterialPageRoute(builder: (context) => DreamHistory()));
      } else {
        showErrorSnackBar(context, "Either email or password incorrect");
      }

    }  catch (ex) {
      debugPrint("Error $ex");
      showAlertDialog("An error occured");
    }
  }

  googleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final creds = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      await FirebaseAuth.instance.signInWithCredential(creds).then((value) => {
            if (mounted)
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DreamHistory()))
          });
    } catch (e) {
      showAlertDialog("Google signin failed $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: double.infinity,
            color: Colors.black,
            child: Center(
              child: Container(
                width: 350,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white, width: 1.5)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Email",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "Enter Email",
                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.white,
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 15),
                    Text("Password",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    TextField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: InputDecoration(
                          hintText: "Enter Password",
                          prefixIcon: Icon(Icons.lock, color: Colors.white)),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        login(emailController.text.toString(),
                            passwordController.text.toString(),
                            context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: Text("Login"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Signup()));
                        },
                        child: Text(
                          "Don't have an account? Register Now!",
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    socialMediaButton(
                        Icons.apple, "Continue with Apple", () {}),
                    socialMediaButton(
                        Icons.g_mobiledata, "Continue with Google", googleLogin),
                    socialMediaButton(
                        Icons.facebook, "Continue with Facebook", () {})
                  ],
                ),
              ),
            )));
  }
}

Widget socialMediaButton(IconData icon, String text, VoidCallback login) {
  return Padding(
    padding: EdgeInsets.only(top: 10),
    child: ElevatedButton.icon(
      onPressed: () => login(),
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          minimumSize: Size(double.infinity, 45),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      icon: Icon(icon),
      label: Text(text),
    ),
  );
}
