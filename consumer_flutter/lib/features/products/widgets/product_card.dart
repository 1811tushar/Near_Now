
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_model.dart';
import '../pages/product_detail_page.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/models/cart_item_model.dart';
import '../../address/providers/address_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/product_image_resolver.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/utils/delivery_estimate.dart';
import '../../../l10n/app_localizations.dart';

/// Shared product card — used on Home rails, Category/Search grids, and
/// recommendation carousels. Visual redesign only: every existing
/// interaction (tap-through to detail, wishlist toggle with auth guard,
/// add-to-cart with auth guard + snackbar) is preserved unchanged.
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final double? width;

  const ProductCard({super.key, required this.product, this.width});

  String _formatReviewCount(int count) {
    if (count >= 100000) return "${(count / 100000).toStringAsFixed(1)} lac";
    if (count >= 1000) return "${(count / 1000).toStringAsFixed(1)}k";
    return "$count";
  }

  void _addToCart(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseLogInToContinue)),
      );
      return;
    }

    final cartItem = CartItemModel(
      id: '',
      productId: product.id,
      name: product.name,
      image: product.images.isNotEmpty ? product.images.first : '',
      price: product.effectivePrice,
      unit: product.unit,
      quantity: 1,
    );

    context.read<CartProvider>().addToCart(uid, cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.addedToCart(product.name)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Real, correctly-matched photo where verified; a clean tinted icon
  /// chip otherwise — never the backend's picsum/seed placeholder, never
  /// emoji. See ProductImageResolver for sourcing status.
  Widget _image(BuildContext context) {
    final resolved = ProductImageResolver.resolve(product.name);
    if (resolved != null) {
      return CachedNetworkImage(
        imageUrl: resolved,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: AppColors.tint1),
        errorWidget: (_, __, ___) => _fallbackTile(),
      );
    }
    return _fallbackTile();
  }

  Widget _fallbackTile() {
    return Container(
      color: AppColors.tint1,
      alignment: Alignment.center,
      child: Icon(Icons.shopping_basket_outlined,
          size: 30, color: AppColors.meadowDark.withOpacity(0.7)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedAddress = context.watch<AddressProvider>().selectedAddress;
    final l10n = AppLocalizations.of(context)!;
    final hasDiscount = product.discountPercent > 0;

    final card = GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppTheme.cardDepth,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(child: _image(context)),
                  if (hasDiscount)
                    Positioned(
                      top: 7,
                      left: 7,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.meadow,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          "${product.discountPercent}% OFF",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Consumer<WishlistProvider>(
                      builder: (context, wishlistProvider, _) {
                        final isSaved = wishlistProvider.isInWishlist(product.id);
                        return GestureDetector(
                          onTap: () {
                            final uid = context.read<AuthProvider>().user?.uid;
                            if (uid != null) {
                              wishlistProvider.toggleWishlist(uid, product.id);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.pleaseLogInToContinue)),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved ? Icons.favorite : Icons.favorite_border,
                              size: 14,
                              color: isSaved ? AppColors.error : AppColors.inkSoft,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "₹${product.effectivePrice.toStringAsFixed(0)}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 4),
                        Text(
                          "₹${product.price.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.unit,
                    style: const TextStyle(fontSize: 10, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      RatingStars(rating: product.rating, size: 11),
                      const SizedBox(width: 3),
                      Text(_formatReviewCount(product.reviewCount),
                          style: const TextStyle(fontSize: 9.5, color: AppColors.inkSoft)),
                      const Spacer(),
                      const Icon(Icons.bolt, size: 11, color: AppColors.meadow),
                      const SizedBox(width: 1),
                      Text(
                        DeliveryEstimate.estimateFor(
                          latitude: selectedAddress?.latitude,
                          longitude: selectedAddress?.longitude,
                        ),
                        style: const TextStyle(fontSize: 9.5, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    width: double.infinity,
                    child: _PressScaleButton(
                      enabled: product.stock != 0,
                      onTap: () => _addToCart(context),
                      child: OutlinedButton(
                        onPressed: null, // tap handled by _PressScaleButton so it can animate first
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          side: BorderSide(
                            color: product.stock == 0 ? AppColors.line : AppColors.meadow,
                            width: 1.4,
                          ),
                          disabledForegroundColor: product.stock == 0 ? AppColors.inkSoft : AppColors.meadow,
                          minimumSize: const Size(0, 0),
                        ),
                        child: Text(
                          product.stock == 0 ? "Out of stock" : l10n.addShort,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return width != null ? SizedBox(width: width, child: card) : card;
  }
}

/// Small scale-down/scale-back tap animation, used for the ADD button so
/// the single most common interaction in the app (add-to-cart, used on
/// Home rails, Search, Category grids, and recommendation carousels via
/// this shared card) has real tactile feedback instead of a flat tap.
class _PressScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool enabled;

  const _PressScaleButton({
    required this.child,
    required this.onTap,
    this.enabled = true,
  });

  @override
  State<_PressScaleButton> createState() => _PressScaleButtonState();
}

class _PressScaleButtonState extends State<_PressScaleButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}