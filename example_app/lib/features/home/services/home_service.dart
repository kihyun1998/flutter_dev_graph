import '../../../core/network/api_client.dart';

class HomeService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> fetchDashboard() async {
    return await _api.get('/home/dashboard');
  }
}
