import '../models/product.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _api = ApiService();

  Future<List<Product>> getProducts() async {
    // 상품 목록 조회
    return [];
  }

  Future<Product?> getProductById(String id) async {
    // 상품 상세 조회
    return null;
  }
}
