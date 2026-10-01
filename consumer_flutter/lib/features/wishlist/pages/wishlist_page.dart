import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/wishlist_provider.dart';
import '../../products/models/product_model.dart';
import '../../products/providers/product_provider.dart';
import '../../products/widgets/product_card.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class WishlistPage extends StatefulWidget {
  final String uid;

  const WishlistPage({super.key, required this.uid});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<ProductModel> _products = [];
  bool _loadingProducts = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWishlistProducts();
    });
  }

  Future<void> _loadWishlistProducts() async {
    setState(() {
      _loadingProducts = true;
      _error = null;
    });

    try {
      final wishlistProvider = context.read<WishlistProvider>();
      final productProvider = context.read<ProductProvider>();
      await wishlistProvider.fetchWishlist(widget.uid);

      final ids = wishlistProvider.wishlistIds;

      // One batched query instead of one sequential await per item — see
      // ProductService.getProductsByIds for why.
      final loaded = await productProvider.fetchProductsByIds(ids);

      // Any ID with no matching product means the underlying product was
      // deleted after being wishlisted — clean those orphaned IDs out of
      // the wishlist now rather than letting them sit there forever.
      final foundIds = loaded.map((p) => p.id).toSet();
      final orphanedIds = ids.where((id) => !foundIds.contains(id)).toList();
      for (final orphanId in orphanedIds) {
        // toggleWishlist removes it, since it's currently present.
        await wishlistProvider.toggleWishlist(widget.uid, orphanId);
      }

      if (!mounted) return;
      setState(() {
        _products = loaded;
        _loadingProducts = false;
      });
    } catch (e) {
      // Previously an exception mid-load left _loadingProducts stuck
      // true forever (an infinite spinner) — now it's always resolved,
      // success or failure.
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loadingProducts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: Text(l10n.myWishlist)),
      body: _loadingProducts
          ? const LoadingWidget()
          : _error != null
              ? EmptyStateWidget(
                  icon: Icons.error_outline,
                  title: l10n.somethingWentWrong,
                  subtitle: _error,
                  actionLabel: l10n.retry,
                  onAction: _loadWishlistProducts,
                )
              : _products.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.favorite_border,
                      title: l10n.wishlistEmpty,
                    )
                  : RefreshIndicator(
                      onRefresh: _loadWishlistProducts,
                      child: MasonryGridView.count(
                        padding: const EdgeInsets.all(16),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: _products[index]);
                        },
                      ),
                    ),
    );
  }
}