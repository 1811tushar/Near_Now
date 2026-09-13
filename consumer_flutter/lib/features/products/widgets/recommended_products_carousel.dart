import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'product_card.dart';

class RecommendedProductsCarousel extends StatelessWidget {
  final List<ProductModel> products;
  final String title;
  const RecommendedProductsCarousel({super.key, required this.products, this.title = 'You may also like'});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))), const SizedBox(height: 12), SizedBox(height: 270, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: products.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => SizedBox(width: 155, child: ProductCard(product: products[i], width: 155))))]);
}