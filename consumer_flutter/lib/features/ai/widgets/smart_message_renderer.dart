import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../../products/widgets/product_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class SmartMessageRenderer extends StatelessWidget {
  final ChatMessage message;
  final Future<void> Function(bool confirmed)? onConfirmation;
  final void Function(String productId)? onProductTap;

  const SmartMessageRenderer({super.key, required this.message, this.onConfirmation, this.onProductTap});

  @override
  Widget build(BuildContext context) {
    switch (message.responseType) {
      case ChatResponseType.text:
        return _bubble(context, message.text);
      case ChatResponseType.productCards:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _bubble(context, message.text),
          const SizedBox(height: 8),
          SizedBox(height: 270, child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 12),
            itemCount: message.products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => SizedBox(width: 155, child: ProductCard(product: message.products[i], width: 155)),
          )),
        ]);
      case ChatResponseType.confirmationButton:
        return Container(
          margin: const EdgeInsets.only(right: 38, bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppTheme.cardDepth,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(message.text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => onConfirmation?.call(false), child: const Text('No'))),
              const SizedBox(width: 8),
              Expanded(child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.meadow),
                onPressed: () => onConfirmation?.call(true),
                child: Text(message.actionLabel ?? 'Yes'),
              )),
            ]),
          ]),
        );
    }
  }

  Widget _bubble(BuildContext context, String text) => Container(
    margin: const EdgeInsets.only(right: 38, bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(14),
        topRight: Radius.circular(14),
        bottomLeft: Radius.circular(4),
        bottomRight: Radius.circular(14),
      ),
      boxShadow: AppTheme.cardDepth,
    ),
    child: Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
  );
}