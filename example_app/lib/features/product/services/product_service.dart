import '../../../core/network/api_client.dart';
import '../models/product.dart';

class ProductService {
  final ApiClient _api = ApiClient();

  Future<List<Product>> fetchProducts() async {
    final response = await _api.get('/products');
    return (response['items'] as List?)
        ?.map((item) => Product.fromJson(item))
        .toList() ?? [];
  }

  Future<Product?> fetchProduct(String id) async {
    final response = await _api.get('/products/$id');
    return response.isNotEmpty ? Product.fromJson(response) : null;
  }
}
