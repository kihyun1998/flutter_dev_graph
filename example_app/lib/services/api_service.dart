import '../utils/constants.dart';

class ApiService {
  final String baseUrl = Constants.apiBaseUrl;

  Future<Map<String, dynamic>> get(String endpoint) async {
    // HTTP GET 구현
    return {};
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    // HTTP POST 구현
    return {};
  }
}
