import '../../../core/network/api_client.dart';
import '../../../core/utils/validators.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  Future<bool> login(String email, String password) async {
    if (!Validators.isValidEmail(email)) return false;
    if (!Validators.isValidPassword(password)) return false;

    await _api.post('/auth/login', {'email': email, 'password': password});
    return true;
  }

  Future<void> logout() async {
    await _api.post('/auth/logout', {});
  }
}
