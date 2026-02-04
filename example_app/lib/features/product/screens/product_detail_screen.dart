import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/custom_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _productService = ProductService();
  Product? _product;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  void _loadProduct() async {
    _product = await _productService.fetchProduct(widget.productId);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingIndicator();

    return Scaffold(
      appBar: AppBar(title: Text(_product?.name ?? 'Product')),
      body: Column(
        children: [
          Text(_product?.name ?? ''),
          Text('\$${_product?.price ?? 0}'),
          CustomButton(text: 'Add to Cart', onPressed: () {}),
        ],
      ),
    );
  }
}
