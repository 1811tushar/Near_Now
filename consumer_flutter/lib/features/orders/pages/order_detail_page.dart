
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../cart/models/cart_item_model.dart';
import '../../cart/providers/cart_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/pages/app_shell.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/product_image_resolver.dart';
import '../../../l10n/app_localizations.dart';
import 'return_refund_page.dart';
import '../../ai/providers/order_status_push_provider.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  static const _statusSteps = ['placed', 'packed', 'out_for_delivery', 'delivered'];
  static const _stepIcons = [Icons.check, Icons.inventory_2_outlined, Icons.local_shipping_outlined, Icons.home_outlined];

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'placed':
        return l10n.statusPlaced;
      case 'packed':
        return l10n.statusPacked;
      case 'out_for_delivery':
        return l10n.statusOutForDelivery;
      default:
        return l10n.statusDelivered;
    }
  }

  int _currentStepIndex(String status) {
    final index = _statusSteps.indexOf(status);
    return index == -1 ? 0 : index;
  }

  Future<void> _reorder(BuildContext context, OrderModel order) async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;

    final cartProvider = context.read<CartProvider>();
    final l10n = AppLocalizations.of(context)!;

    final cartItems = order.items
        .map((item) => CartItemModel(
              id: '',
              productId: item.productId,
              name: item.name,
              image: item.image,
              price: item.price,
              unit: item.unit,
              quantity: item.quantity,
            ))
        .toList();

    await cartProvider.addMultipleToCart(uid, cartItems);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.itemsAddedToCart)),
    );

    Navigator.of(context).popUntil((route) => route.isFirst);
    AppShell.of(context)?.switchToTab(1);
  }

  Future<void> _confirmCancel(BuildContext context, String orderId) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.cancelOrderConfirmTitle),
        content: Text(l10n.cancelOrderConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.keepOrder),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.yesCancel, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await context.read<OrderProvider>().cancelOrder(orderId);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? l10n.orderCancelled : l10n.failedToCancelOrder)),
    );
  }

  String _displayOrderId(String id) => id.length <= 8 ? id : id.substring(0, 8);

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.read<OrderProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: Text(l10n.orderNumber(_displayOrderId(orderId)))),
      body: StreamBuilder<OrderModel?>(
        stream: orderProvider.streamOrder(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text(l10n.orderNotFound));
          }

          final order = snapshot.data!;
          final pushedStatus = context.watch<OrderStatusPushProvider>().statusFor(order.id);
          final displayStatus = pushedStatus ?? order.status;
          final currentStep = _currentStepIndex(displayStatus);

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (displayStatus != 'cancelled')
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: AppTheme.cardDepth,
                  ),
                  child: Column(
                    children: List.generate(_statusSteps.length, (index) {
                      final isDone = index <= currentStep;
                      final isLast = index == _statusSteps.length - 1;
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: isDone ? AppColors.meadow : AppColors.line,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(_stepIcons[index], size: 14, color: isDone ? Colors.white : AppColors.inkSoft),
                                ),
                                if (!isLast)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: index < currentStep ? AppColors.meadow : AppColors.line,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg, top: 3),
                                child: Text(
                                  _statusLabel(l10n, _statusSteps[index]),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isDone ? AppColors.ink : AppColors.inkSoft,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.tint3,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    l10n.statusCancelled,
                    style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w800),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.placedOn(order.createdAt.toString().split(' ').first),
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.deliveringToFull(order.deliveryAddress.fullName, order.deliveryAddress.addressLine, order.deliveryAddress.city, order.deliveryAddress.pincode),
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: AppTheme.cardDepth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.items, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                    const SizedBox(height: AppSpacing.sm),
                    ...order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ProductImageResolver.resolve(item.name) != null
                                  ? CachedNetworkImage(
                                      imageUrl: ProductImageResolver.resolve(item.name)!,
                                      width: 42,
                                      height: 42,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Container(
                                        width: 42,
                                        height: 42,
                                        color: AppColors.tint1,
                                        child: const Icon(Icons.shopping_basket_outlined, size: 18, color: AppColors.meadowDark),
                                      ),
                                    )
                                  : Container(
                                      width: 42,
                                      height: 42,
                                      color: AppColors.tint1,
                                      child: const Icon(Icons.shopping_basket_outlined, size: 18, color: AppColors.meadowDark),
                                    ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                  Text("${item.unit} • Qty: ${item.quantity}",
                                      style: const TextStyle(fontSize: 10.5, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Text("₹${item.price.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: AppSpacing.lg, color: AppColors.line),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.total, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        Text("₹${order.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _reorder(context, order),
                  icon: const Icon(Icons.replay, size: 18),
                  label: Text(l10n.reorder),
                ),
              ),
              if (order.status == 'delivered') ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReturnRefundPage(order: order))),
                    icon: const Icon(Icons.assignment_return_outlined, size: 18),
                    label: const Text('Return / Refund'),
                  ),
                ),
              ],
              if (order.isCancellable) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error, width: 1.4)),
                    onPressed: () => _confirmCancel(context, order.id),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: Text(l10n.cancelOrder),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
