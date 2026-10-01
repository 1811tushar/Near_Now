
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/order_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/models/cart_item_model.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import 'order_detail_page.dart';
import '../../../l10n/app_localizations.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<OrderProvider>().fetchOrders(uid);
      }
    });
  }

  (Color, Color) _statusColors(String status) {
    switch (status) {
      case 'delivered':
        return (AppColors.tint1, AppColors.success);
      case 'cancelled':
        return (AppColors.tint3, AppColors.error);
      case 'out_for_delivery':
        return (AppColors.tint4, const Color(0xFF185FA5));
      case 'packed':
        return (AppColors.tint5, AppColors.warning);
      default:
        return (AppColors.tint6, const Color(0xFF534AB7));
    }
  }

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'delivered':
        return l10n.statusDelivered;
      case 'out_for_delivery':
        return l10n.statusOutForDelivery;
      case 'packed':
        return l10n.statusPacked;
      case 'cancelled':
        return l10n.statusCancelled;
      default:
        return l10n.statusPlaced;
    }
  }

  void _reorder(BuildContext context, OrderModel order) {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;
    final cartProvider = context.read<CartProvider>();
    for (final item in order.items) {
      cartProvider.addToCart(
        uid,
        CartItemModel(
          id: '',
          productId: item.productId,
          name: item.name,
          image: item.image,
          price: item.price,
          unit: item.unit,
          quantity: item.quantity,
        ),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Items added to your cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: Text(l10n.orders)),
      body: orderProvider.isLoading
          ? const LoadingWidget()
          : orderProvider.error != null
              ? EmptyStateWidget(
                  icon: Icons.error_outline,
                  title: l10n.somethingWentWrong,
                  subtitle: orderProvider.error,
                  actionLabel: l10n.retry,
                  onAction: () {
                    final uid = context.read<AuthProvider>().user?.uid;
                    if (uid != null) orderProvider.fetchOrders(uid);
                  },
                )
              : orderProvider.orders.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.receipt_long_outlined,
                      title: l10n.noOrdersYet,
                    )
                  : RefreshIndicator(
                      onRefresh: () {
                        final uid = context.read<AuthProvider>().user?.uid;
                        return uid != null ? orderProvider.fetchOrders(uid) : Future.value();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: orderProvider.orders.length,
                        itemBuilder: (context, index) {
                          final order = orderProvider.orders[index];
                          final (bgColor, fgColor) = _statusColors(order.status);
                          final itemNames = order.items.map((i) => i.name).join(', ');

                          return Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.md),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              boxShadow: AppTheme.cardDepth,
                            ),
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => OrderDetailPage(orderId: order.id)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              l10n.orderNumber(order.id.length <= 8 ? order.id : order.id.substring(0, 8)),
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              order.createdAt.toString().split(' ').first,
                                              style: const TextStyle(fontSize: 10.5, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
                                        child: Text(
                                          _statusLabel(l10n, order.status),
                                          style: TextStyle(color: fgColor, fontSize: 10.5, fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    itemNames,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  const Divider(height: 1, color: AppColors.line),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    children: [
                                      Text(
                                        "₹${order.totalAmount.toStringAsFixed(0)}",
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                      ),
                                      const Spacer(),
                                      OutlinedButton(
                                        onPressed: () => _reorder(context, order),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          minimumSize: const Size(0, 0),
                                        ),
                                        child: Text(l10n.reorder, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
