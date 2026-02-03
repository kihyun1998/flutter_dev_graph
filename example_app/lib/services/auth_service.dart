import '../models/user.dart';
import '../utils/validators.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<User?> login(String email, String password) async {
    if (!Validators.isValidEmail(email)) {
      throw Exception('Invalid email');
    }
    if (!Validators.isValidPassword(password)) {
      throw Exception('Invalid password');
    }
    // 로그인 로직
    return null;
  }

  Future<void> logout() async {
    // 로그아웃 로직
  }
}
