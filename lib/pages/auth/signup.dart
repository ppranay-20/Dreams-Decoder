import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dreams_decoder/pages/dream_history.dart';
import 'package:dreams_decoder/pages/auth/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  signUp(String username, String email, String password, String confirmPassword) async {
    if (username == "" ||
        email == "" ||
        password == "" ||
        confirmPassword == "") {
      showAlertDialog("All fields are required!");
      return;
    } else if (password != confirmPassword) {
      showAlertDialog("Passwords do not match!");
      return;
    } else {
      try {
        UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String userId = userCred.user!.uid;
        DateTime now = DateTime.now();

        FirebaseFirestore.instance.collection("User").doc().set({
          "user_id": userId,
          "email": email,
          "message_limit": 20,
          "created_at": now
        }).then((value) => {
          if(mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DreamHistory()),
            )
          }
        });
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
                    Text("Username", style: TextStyle(color: Colors.white, fontSize: 16)),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        hintText: "Enter Username",
                        prefixIcon: Icon(Icons.person, color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 15),
                    Text("Email", style: TextStyle(color: Colors.white, fontSize: 16)),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "Enter Email",
                        prefixIcon: Icon(Icons.email, color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 15),
                    Text("Password", style: TextStyle(color: Colors.white, fontSize: 16)),
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
                    Text("Confirm Password", style: TextStyle(color: Colors.white, fontSize: 16)),
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
                        signUp(usernameController.text.toString(),emailController.text.toString(),passwordController.text.toString(), confirmPasswordController.text.toString());
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Signin()));
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
