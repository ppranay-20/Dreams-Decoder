import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

Future<String> getIdFromJWT() async {
  SharedPreferences pref = await SharedPreferences.getInstance();

  final token = pref.get('token');

  if(token == null) {
    throw Exception("No token provided");
  }

  Map<String, dynamic> decodedToken = JwtDecoder.decode(token as String);
  final id = decodedToken['id'];
  return id.toString();
}