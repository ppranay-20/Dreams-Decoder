import 'dart:convert';

import 'package:murkaverse/pages/auth/signup.dart';
import 'package:murkaverse/providers/user-provider.dart';
import 'package:murkaverse/utils/convert-to-uri.dart';
import 'package:murkaverse/utils/snackbar.dart';
import 'package:murkaverse/widgets/buttons.dart';
import 'package:murkaverse/widgets/main-screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

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
        Provider.of<UserProvider>(context, listen: false).getUserData();
        showSuccessSnackbar(context, "Login Successful");
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainScreen()));
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
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      color: Color(0xFF180C12),
                      padding: EdgeInsets.fromLTRB(10, 32, 10, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sign in",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                          Text(
                            "Glad to see you again!",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Are you a new User?",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Signup()));
                                },
                                child: Text(
                                  "Register",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                TextFormField(
                                  controller: emailController,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 25, vertical: 18),
                                      fillColor: Color(0xFF330E22),
                                      filled: true,
                                      hintText: "Enter your email",
                                      labelText: "Email",
                                      labelStyle: TextStyle(
                                          color: Color(0xFFDD4594),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                              color: Colors.transparent)),
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                              color: Colors.transparent)),
                                      hintStyle: TextStyle(color: Colors.grey)),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter you email";
                                    }

                                    return null;
                                  },
                                ),
                                SizedBox(height: 14),
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: true,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 25, vertical: 18),
                                    fillColor: Color(0xFF330E22),
                                    filled: true,
                                    hintText: "Enter your Password",
                                    labelText: "Password",
                                    labelStyle: TextStyle(
                                        color: Color(0xFFDD4594),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                            color: Colors.transparent)),
                                    disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                            color: Colors.transparent)),
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
                                    backgroundColor: Color(0xFFDD4594),
                                    disabledBackgroundColor: Color(0xFFDD4594),
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            login(
                                                emailController.text,
                                                passwordController.text,
                                                context);
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
                                            "Continue",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Divider(color: Colors.white)),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        "or",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    Expanded(
                                        child: Divider(color: Colors.white)),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Button(
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset("assets/apple.png",
                                              height: 17, width: 14),
                                          SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            "Continue With Apple",
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
                                          Image.asset("assets/google.png",
                                              height: 17, width: 14),
                                          SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            "Continue With Google",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                          )
                                        ],
                                      ),
                                    ),
                                    onPressed: () {}),
                              ],
                            ),
                          ],
                        )),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Center(
                    child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        )),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
