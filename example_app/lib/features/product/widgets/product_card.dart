import 'package:flutter/material.dart';
import '../models/product.dart';
import '../../../shared/widgets/custom_button.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(product.name),
          Text('\$${product.price}'),
          CustomButton(text: 'View', onPressed: onTap),
        ],
      ),
    );
  }
}
