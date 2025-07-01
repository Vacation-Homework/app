import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  static String aiKey = dotenv.env['AI_SECRET_KEY'] ?? '';
}