import 'dart:convert';

import 'package:dreams_decoder/pages/home/dream_history.dart';
import 'package:dreams_decoder/pages/auth/signup.dart';
import 'package:dreams_decoder/utils/convert-to-uri.dart';
import 'package:dreams_decoder/utils/snackbar.dart';
import 'package:dreams_decoder/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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

  void login(String email, String password, BuildContext context) async {
    if (email == "" || password == "") {
      showErrorSnackBar(context, "Email and Password required");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });
      final url = getAPIUrl('auth/login');
      final response = await http.post(url,
          body: jsonEncode({"email": email, "password": password}),
          headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        const storage = FlutterSecureStorage();
        final data = jsonDecode(response.body);
        final token = data['token'];
        await storage.write(key: 'token', value: token);
        showSuccessSnackbar(context, "Login Successful");
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => DreamHistory()));
      } else {
        showErrorSnackBar(context, "Either email or password incorrect");
      }
    } catch (ex) {
      debugPrint("Error $ex");
      showAlertDialog("An error occured");
    } finally {
      setState(() {
        isLoading = false;
      });
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
                      "Sign in",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Glad to see you again!",
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    Row(
                      children: [
                        Text(
                          "Are you a new User?",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Signup()));
                            },
                            child: Text(
                              "Register",
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 14),
                            ))
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            return "Please enter you email";
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 10),
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
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your password";
                          } else if (value.length < 6) {
                            return "Please enter a valid password";
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
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  login(emailController.text,
                                      passwordController.text, context);
                                }
                              }, // Handle login
                        child: Center(
                          child: isLoading
                              ? SizedBox(
                                  height: 23, // Smaller height
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth:
                                        2.0, // Thinner stroke for a more delicate spinner
                                  ))
                              : Text(
                                  "Sign in",
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
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
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
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                          onPressed: () {}),
                      SizedBox(height: 20),
                      Center(
                        child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "Forgot Password?",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            )),
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
