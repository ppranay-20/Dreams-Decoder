
import 'package:flutter_dotenv/flutter_dotenv.dart';

Uri getAPIUrl(String endpoint) {
  final baseUrl = dotenv.env['API_URL'];

  if(baseUrl == null) {
    throw Exception("No url in env file");
  }

  if (endpoint.endsWith('/')) {
    endpoint = endpoint.substring(0, endpoint.length - 1);
  }

  return Uri.parse('$baseUrl$endpoint');
}