import 'dart:convert';

import 'package:murkaverse/pages/auth/signin.dart';
import 'package:murkaverse/pages/profile/profile-page.dart';
import 'package:murkaverse/utils/convert-to-uri.dart';
import 'package:murkaverse/utils/snackbar.dart';
import 'package:murkaverse/widgets/buttons.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

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
    try {
      setState(() {
        isLoading = true;
      });
      final url = getAPIUrl('auth/register');
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(
              {'name': username, 'email': email, 'password': password}));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final id = data['data']['id'];
        final name = data['data']['name'];
        final password = data['data']['password'];
        if (!mounted) return;
        showSuccessSnackbar(context, "Signup successful!");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfilePage(
                    id: id.toString(), name: name, password: password)));
      } else {
        debugPrint("Error: ${response.statusCode} - ${response.body}");
        showAlertDialog("Signup failed: ${response.body}");
      }
    } catch (e) {
      showAlertDialog(e.toString());
    } finally {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Color(0xFF200E20),
                padding: EdgeInsets.fromLTRB(10, 32, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "To start decoding and expanding your dreams you need to create an account",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    TextFormField(
                      controller: usernameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          fillColor: Color(0xFF301530),
                          filled: true,
                          hintText: "Enter your name",
                          labelText: "Name",
                          labelStyle: TextStyle(color: Color(0xFFDFBAEF)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintStyle: TextStyle(color: Colors.grey)),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your name";
                        }

                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          fillColor: Color(0xFF301530),
                          filled: true,
                          hintText: "Enter your email",
                          labelText: "Email",
                          labelStyle: TextStyle(color: Color(0xFFDFBAEF)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintStyle: TextStyle(color: Colors.grey)),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        }

                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          fillColor: Color(0xFF301530),
                          filled: true,
                          hintText: "Enter your Password",
                          labelText: "Password",
                          labelStyle: TextStyle(color: Color(0xFFDFBAEF)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintStyle: TextStyle(color: Colors.grey)),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter you password";
                        } else if (value.length < 6) {
                          return "Password should be of 6 characters";
                        }

                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          fillColor: Color(0xFF301530),
                          filled: true,
                          hintText: "Confirm Password",
                          labelText: "Confirm Password",
                          labelStyle: TextStyle(color: Color(0xFFDFBAEF)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintStyle: TextStyle(color: Colors.grey)),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Please confirm your password";
                        } else if (value != passwordController.text) {
                          return "Passwords do not match";
                        }

                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE152C2),
                        disabledBackgroundColor: Color(0xFFE152C2),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          signUp(
                              usernameController.text,
                              emailController.text,
                              passwordController.text,
                              confirmPasswordController.text,
                              context);
                        }
                      }, // Handle login
                      child: Center(
                        child: isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                            : Text(
                                "Sign up",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white54)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "or",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white54)),
                      ],
                    ),
                    SizedBox(height: 20),
                    Button(
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.g_mobiledata_outlined,
                                size: 30,
                              ),
                              Text(
                                "Sign in With Google",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                              )
                            ],
                          ),
                        ),
                        onPressed: () {}),
                    SizedBox(height: 10),
                    Button(
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.apple,
                                size: 24,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                "Sign in With Apple",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                              )
                            ],
                          ),
                        ),
                        onPressed: () {}),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Signin()));
                            },
                            child: Text(
                              "Signin",
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 16),
                            ))
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
