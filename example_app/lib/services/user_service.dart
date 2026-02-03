import '../models/user.dart';
import 'api_service.dart';

class UserService {
  final ApiService _api = ApiService();

  Future<User?> getProfile() async {
    // 프로필 조회
    return null;
  }

  Future<void> updateProfile(User user) async {
    // 프로필 수정
  }
}
