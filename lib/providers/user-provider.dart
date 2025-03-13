import 'dart:convert';

import 'package:murkaverse/utils/convert-to-uri.dart';
import 'package:murkaverse/utils/getIdFromJWT.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? userData;
  bool isLoading = false;

  Future<void> getUserData() async {
    try {
      isLoading = true;
      final id = await getIdFromJWT();
      final url = getAPIUrl('users/$id');
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userData = data['data'];
      } else {
        throw Exception();
      }
    } catch (err) {
      debugPrint("An error occured $err");
      throw Exception();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
