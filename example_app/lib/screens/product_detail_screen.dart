import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/helpers.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';

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
    final product = await _productService.getProductById(widget.productId);
    setState(() {
      _product = product;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingIndicator();

    return Scaffold(
      appBar: AppBar(title: Text(_product?.name ?? 'Product')),
      body: Column(
        children: [
          Text(_product?.name ?? ''),
          Text(Helpers.formatPrice(_product?.price ?? 0)),
          CustomButton(text: 'Add to Cart', onPressed: () {}),
        ],
      ),
    );
  }
}
