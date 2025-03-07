import 'dart:convert';

import 'package:dreams_decoder/utils/convert-to-uri.dart';
import 'package:dreams_decoder/utils/getIdFromJWT.dart';
import 'package:http/http.dart' as http;

Future<dynamic> getUserData() async {
  try {
    final id = await getIdFromJWT();
    final url = getAPIUrl('users/$id');
    final response = await http.get(url);

    if(response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userData = data['data'];
      return userData;
    } else {
      throw Exception("Failed to fetch user data");
    }
  } catch(e) {
    throw Exception("User Data not found $e");
  }
}