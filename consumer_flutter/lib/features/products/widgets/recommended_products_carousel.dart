
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'product_card.dart';

class RecommendedProductsCarousel extends StatelessWidget {
  final List<ProductModel> products;
  final String title;

  const RecommendedProductsCarousel({
    super.key,
    required this.products,
    this.title = 'Similar products',
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 270,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => SizedBox(width: 140, child: ProductCard(product: products[i], width: 140)),
          ),
        ),
      ],
    );
  }
}
