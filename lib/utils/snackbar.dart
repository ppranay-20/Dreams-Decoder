import 'package:flutter/material.dart';

// success snackbar 
void showSuccessSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: Colors.green,
     behavior: SnackBarBehavior.floating,
     duration: const Duration(seconds: 1),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

// error snackbar
void showErrorSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: Colors.red,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 1),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}