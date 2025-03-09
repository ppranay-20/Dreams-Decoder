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
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                ),
                Text(
                  "Sign in",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      "Glad to see you again!",
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      hintText: "Enter your email",
                      labelText: "Email",
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
                    hintText: "Enter your Password",
                    labelText: "Password",
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
                TextButton(
                  onPressed: () {}, // Forgot password action
                  child: Text(
                    "Forgot password?",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    disabledBackgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            login(emailController.text, passwordController.text,
                                context);
                          }
                        }, // Handle login
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            width: 22, // Smaller width
                            height: 22, // Smaller height
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth:
                                  2.0, // Thinner stroke for a more delicate spinner
                            ))
                        : Text(
                            "Submit",
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
                            style: TextStyle(color: Colors.black, fontSize: 15),
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
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          )
                        ],
                      ),
                    ),
                    onPressed: () {}),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Signup()));
                        },
                        child: Text(
                          "Signup",
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
