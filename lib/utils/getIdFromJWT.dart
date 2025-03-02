import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

Future<String> getIdFromJWT() async {
  const storage = FlutterSecureStorage();

  final token = await storage.read(key: 'token');

  if(token == null) {
    throw Exception("No token provided");
  }

  Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  final id = decodedToken['id'];
  return id.toString();
}