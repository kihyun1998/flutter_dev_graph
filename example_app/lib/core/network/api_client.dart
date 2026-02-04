import '../utils/constants.dart';

class ApiClient {
  final String baseUrl = Constants.apiBaseUrl;

  Future<Map<String, dynamic>> get(String path) async {
    // HTTP GET
    return {};
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    // HTTP POST
    return {};
  }
}
