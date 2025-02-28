import 'dart:convert';

import 'package:dreams_decoder/pages/auth/signin.dart';
import 'package:dreams_decoder/utils/convert-to-uri.dart';
import 'package:dreams_decoder/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

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

  void signUp(String username, String email, String password,
      String confirmPassword, BuildContext context) async {
    if (username == "" ||
        email == "" ||
        password == "" ||
        confirmPassword == "") {
      showErrorSnackBar(context, "All fields are required");
      return;
    } else if (password != confirmPassword) {
      showErrorSnackBar(context,"Passwords do not match!");
      return;
    } else {
      try {
        final url = getAPIUrl('auth/register');
        final response = await http.post(url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(
                {'name': username, 'email': email, 'password': password}));

        if (response.statusCode == 200 || response.statusCode == 201) {
          showSuccessSnackbar(context,"Signup successful!");
          Navigator.push(context, MaterialPageRoute(builder: (context) => Signin()));
        } else {
          debugPrint("Error: ${response.statusCode} - ${response.body}");
          showAlertDialog("Signup failed: ${response.body}");
        }
      } catch (e) {
        showAlertDialog(e.toString());
      }
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
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text("Username",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        hintText: "Enter Username",
                        prefixIcon: Icon(Icons.person, color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 15),
                    Text("Email",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "Enter Email",
                        prefixIcon: Icon(Icons.email, color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 15),
                    Text("Password",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        prefixIcon: Icon(Icons.lock, color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 15),
                    Text("Confirm Password",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        prefixIcon: Icon(Icons.lock, color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        signUp(
                            usernameController.text.toString(),
                            emailController.text.toString(),
                            passwordController.text.toString(),
                            confirmPasswordController.text.toString(),
                            context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: Text("Sign Up"),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Signin()));
                        },
                        child: Text(
                          "Already have an account? Login Now!",
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}
