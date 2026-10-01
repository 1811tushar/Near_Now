
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../address/providers/address_provider.dart';
import '../../address/pages/address_list_page.dart';
import '../../category/providers/category_provider.dart';
import '../../category/models/category_model.dart';
import '../../category/pages/category_products_page.dart';
import '../../orders/providers/order_provider.dart';
import '../../orders/pages/order_detail_page.dart';
import '../../products/providers/product_provider.dart';
import '../../products/models/product_model.dart';
import '../../products/pages/product_detail_page.dart';
import '../../products/pages/product_list_page.dart';
import '../../products/pages/barcode_scanner_page.dart';
import '../../products/pages/image_search_page.dart';
import '../../products/widgets/product_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/shimmer_loading_widget.dart';
import '../../../core/widgets/category_icon_illustrations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/product_image_resolver.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/language_picker_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _promoController = PageController();
  Timer? _searchHintTimer;
  int _searchHintIndex = 0;
  int _promoIndex = 0;

  // Brand-consistent citrus/meadow gradients — replaces the old
  // black/blue/green mix so banners stay on-palette.
  List<(String, String, List<Color>)> _promos(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      (l10n.promoNewArrivalsTitle, l10n.promoNewArrivalsSubtitle,
          [AppColors.citrus, const Color(0xFFDCEF9E)]),
      (l10n.promoFreshPicksTitle, l10n.promoFreshPicksSubtitle,
          [const Color(0xFFA9D97C), AppColors.citrus]),
      (l10n.promoQuickEssentialsTitle, l10n.promoQuickEssentialsSubtitle,
          [const Color(0xFFB9E0A0), const Color(0xFFDCEF9E)]),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<AddressProvider>().fetchAddresses(uid);
        context.read<OrderProvider>().fetchOrders(uid);
      }
      context.read<CategoryProvider>().fetchTopLevelCategories();
      context.read<ProductProvider>().fetchFeaturedProducts();
      context.read<ProductProvider>().fetchProducts();
    });
    _searchHintTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() => _searchHintIndex++);
    });
  }

  @override
  void dispose() {
    _searchHintTimer?.cancel();
    _promoController.dispose();
    super.dispose();
  }

  Map<String, List<ProductModel>> _groupByCategory(
      List<ProductModel> products) {
    final Map<String, List<ProductModel>> grouped = {};
    for (final product in products) {
      grouped.putIfAbsent(product.categoryId, () => []).add(product);
    }
    return grouped;
  }

  /// Maps a real backend category name to one of the 8 flat illustrated
  /// icons; categories outside that set (Cleaning, Personal Care, Baby,
  /// Pet, ...) still get a clean depth-tile, just with a generic Material
  /// icon glyph instead of a custom doodle — never emoji, never blank.
  CategoryIllustration? _illustrationFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('fruit') || n.contains('veg')) return CategoryIllustration.fruitsVeg;
    if (n.contains('dairy') || n.contains('breakfast')) return CategoryIllustration.dairy;
    if (n.contains('snack')) return CategoryIllustration.snacks;
    if (n.contains('beverage') || n.contains('drink')) return CategoryIllustration.beverages;
    if (n.contains('bakery') || n.contains('bread')) return CategoryIllustration.bakery;
    if (n.contains('atta') || n.contains('rice') || n.contains('dal') || n.contains('grain')) {
      return CategoryIllustration.grains;
    }
    if (n.contains('masala') || n.contains('spice') || n.contains('dry fruit')) {
      return CategoryIllustration.masala;
    }
    if (n.contains('frozen')) return CategoryIllustration.frozen;
    return null;
  }

  Widget _liveOrderCard(BuildContext context, OrderProvider orderProvider) {
    if (orderProvider.orders.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final active = orderProvider.orders.firstWhere(
      (o) => o.status != 'delivered' && o.status != 'cancelled',
      orElse: () => orderProvider.orders.first,
    );
    if (active.status == 'delivered' || active.status == 'cancelled') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailPage(orderId: active.id)),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppTheme.cardDepth,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: AppColors.tint1, shape: BoxShape.circle),
                child: const Icon(Icons.local_shipping_outlined, size: 18, color: AppColors.meadow),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.orderInProgress,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.meadow)),
                    const SizedBox(height: 1),
                    Text('Order #${active.id}',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentlyOrderedRail(BuildContext context, OrderProvider orderProvider) {
    if (orderProvider.orders.isEmpty) return const SizedBox.shrink();
    final items = orderProvider.orders.first.items;
    if (items.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.recentlyOrdered),
        SizedBox(
          height: 168,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final resolved = ProductImageResolver.resolve(item.name);
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(productId: item.productId),
                    ),
                  ),
                  child: Container(
                    width: 118,
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
                          height: 90,
                          width: double.infinity,
                          child: resolved != null
                              ? CachedNetworkImage(imageUrl: resolved, fit: BoxFit.cover)
                              : Container(
                                  color: AppColors.tint1,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.shopping_basket_outlined,
                                      size: 26, color: AppColors.meadowDark),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('₹${item.price.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                              Text(item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10.5, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final productProvider = context.watch<ProductProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final selectedAddress = addressProvider.selectedAddress;
    final productsByCategory = _groupByCategory(productProvider.products);

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddressListPage()),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, size: 20, color: AppColors.meadow),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  selectedAddress != null
                      ? l10n.deliverTo(selectedAddress.label)
                      : l10n.selectDeliveryAddress,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: l10n.language,
            onPressed: () => showLanguagePicker(context),
          ),
          // Notification bell — UI affordance only for now; wiring this to
          // a real notifications feed is separate, pending backend support.
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: [
            // Search bar + barcode/image search shortcuts
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProductListPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.button + 3),
                          boxShadow: AppTheme.cardDepth,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: AppColors.inkSoft),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: Text(
                                  categoryProvider.categories.isEmpty
                                      ? l10n.searchProductsHint
                                      : l10n.searchCategoryHint(
                                          categoryProvider.categories[
                                                  _searchHintIndex % categoryProvider.categories.length]
                                              .name),
                                  key: ValueKey(_searchHintIndex),
                                  style: const TextStyle(fontSize: 13, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.button + 3),
                        boxShadow: AppTheme.cardDepth,
                      ),
                      child: const Icon(Icons.qr_code_scanner, color: AppColors.inkSoft),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ImageSearchPage()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.button + 3),
                        boxShadow: AppTheme.cardDepth,
                      ),
                      child: const Icon(Icons.camera_alt_outlined, color: AppColors.inkSoft),
                    ),
                  ),
                ],
              ),
            ),

            _liveOrderCard(context, orderProvider),

            // Swipeable promotional banners
            SizedBox(
              height: 130,
              child: PageView.builder(
                controller: _promoController,
                itemCount: _promos(context).length,
                onPageChanged: (index) => setState(() => _promoIndex = index),
                itemBuilder: (context, index) {
                  final promo = _promos(context)[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        gradient: LinearGradient(
                          colors: promo.$3,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Text(
                          '${promo.$1}\n${promo.$2}',
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _promos(context).length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _promoIndex == index ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: _promoIndex == index ? AppColors.meadow : AppColors.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Coupons / wallet-credit / delivery-time strip — still
            // decorative pending the real Coupons feature.
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  _infoChip(Icons.percent, 'FLAT ₹50 OFF above ₹249'),
                  const SizedBox(width: AppSpacing.sm),
                  _infoChip(Icons.local_shipping_outlined, 'FREE delivery, all orders'),
                  const SizedBox(width: AppSpacing.sm),
                  _infoChip(Icons.bolt, '9 min delivery'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Shop by category — single consolidated grid (real backend
            // categories, mapped to a flat illustration where we have one).
            if (categoryProvider.categories.isNotEmpty) ...[
              SectionHeader(title: l10n.shopByCategory),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 14,
                  children: categoryProvider.categories.map((category) {
                    final illustration = _illustrationFor(category.name);
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - AppSpacing.lg * 2 - 18) / 4,
                      child: illustration != null
                          ? CategoryTile(
                              type: illustration,
                              label: category.name,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => CategoryProductsPage(category: category)),
                              ),
                            )
                          : _genericCategoryTile(context, category),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            _recentlyOrderedRail(context, orderProvider),

            // Featured products carousel
            SectionHeader(
              title: l10n.featuredProducts,
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductListPage()),
                );
              },
            ),
            SizedBox(
              height: 300,
              child: productProvider.featuredProducts.isEmpty
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      itemCount: 4,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: SizedBox(
                          width: 150,
                          child: ShimmerBox(width: 150, height: 280, borderRadius: AppRadius.card),
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      itemCount: productProvider.featuredProducts.length,
                      itemBuilder: (context, index) {
                        final product = productProvider.featuredProducts[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.md),
                          child: ProductCard(product: product, width: 150),
                        );
                      },
                    ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Bestsellers — per-category thumbnail previews
            if (productsByCategory.isNotEmpty && categoryProvider.categories.isNotEmpty) ...[
              SectionHeader(title: l10n.bestsellers),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.1,
                ),
                itemCount: categoryProvider.categories.length > 6 ? 6 : categoryProvider.categories.length,
                itemBuilder: (context, index) {
                  final category = categoryProvider.categories[index];
                  final categoryProducts = productsByCategory[category.id] ?? [];
                  if (categoryProducts.isEmpty) return const SizedBox();
                  final previewItems = categoryProducts.take(4).toList();
                  final remaining = categoryProducts.length - 4;

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CategoryProductsPage(category: category)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        boxShadow: AppTheme.cardDepth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                              ),
                              itemCount: previewItems.length,
                              itemBuilder: (context, i) {
                                final p = previewItems[i];
                                final resolved = ProductImageResolver.resolve(p.name);
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: resolved != null
                                      ? CachedNetworkImage(imageUrl: resolved, fit: BoxFit.cover)
                                      : Container(
                                          color: AppColors.tint1,
                                          child: const Icon(Icons.shopping_basket_outlined,
                                              size: 16, color: AppColors.meadowDark),
                                        ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          if (remaining > 0)
                            Text("+$remaining more",
                                style: const TextStyle(fontSize: 10, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
                          Text(
                            category.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.button - 1),
        boxShadow: AppTheme.cardDepth,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.meadow),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _genericCategoryTile(BuildContext context, CategoryModel category) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CategoryProductsPage(category: category)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.tile),
              boxShadow: AppTheme.cardDepth,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.storefront_outlined, color: AppColors.meadow),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 62,
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}
