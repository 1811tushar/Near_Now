
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/category_model.dart';
import '../providers/category_provider.dart';
import '../../products/providers/product_provider.dart';
import '../../products/widgets/product_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/shimmer_loading_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

/// Blinkit-style two-pane category browser: a scrollable icon rail of every
/// top-level category on the left, and a live product grid for whichever
/// category is currently selected on the right. Tapping a rail item swaps
/// the grid in place — no navigation, matching how Blinkit's own category
/// screen behaves.
class CategoryProductsPage extends StatefulWidget {
  final CategoryModel category;

  const CategoryProductsPage({super.key, required this.category});

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  late CategoryModel _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = context.read<CategoryProvider>();
      if (categoryProvider.categories.isEmpty) {
        categoryProvider.fetchTopLevelCategories();
      }
      context.read<ProductProvider>().fetchProductsByCategory(_selectedCategory.id);
    });
  }

  void _selectCategory(CategoryModel category) {
    if (category.id == _selectedCategory.id) return;
    setState(() => _selectedCategory = category);
    context.read<ProductProvider>().fetchProductsByCategory(category.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoryProvider = context.watch<CategoryProvider>();
    final productProvider = context.watch<ProductProvider>();
    final rail = categoryProvider.categories.isNotEmpty
        ? categoryProvider.categories
        : [_selectedCategory];

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: Text(_selectedCategory.name)),
      body: Row(
        children: [
          // Left icon rail
          Container(
            width: 84,
            color: AppColors.card,
            child: ListView.builder(
              itemCount: rail.length,
              itemBuilder: (context, index) {
                final category = rail[index];
                final isSelected = category.id == _selectedCategory.id;

                return InkWell(
                  onTap: () => _selectCategory(category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: 6),
                    color: isSelected ? AppColors.tint1 : Colors.transparent,
                    child: Column(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.meadow : AppColors.paper,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.category_outlined,
                            color: isSelected ? Colors.white : AppColors.inkSoft,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? AppColors.meadow : AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Right product grid
          Expanded(
            child: Container(
              color: AppColors.paper,
              child: productProvider.isLoading
                  ? const ShimmerProductGrid()
                  : productProvider.error != null
                      ? EmptyStateWidget(
                          icon: Icons.error_outline,
                          title: l10n.somethingWentWrong,
                          subtitle: productProvider.error,
                        )
                      : productProvider.products.isEmpty
                          ? EmptyStateWidget(
                              icon: Icons.inventory_2_outlined,
                              title: l10n.noProductsHereYet,
                              subtitle: l10n.checkBackSoon,
                            )
                          : MasonryGridView.count(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              // Each card sizes to its own natural content
                              // height — no fixed row height to guess or
                              // get wrong. This is the standard approach
                              // for grids of cards with variable content
                              // (discount badge or not, 1-line vs 2-line
                              // names, different text-scale settings) —
                              // overflow becomes structurally impossible
                              // rather than something to calculate around.
                              crossAxisCount: 2,
                              mainAxisSpacing: AppSpacing.md,
                              crossAxisSpacing: AppSpacing.md,
                              itemCount: productProvider.products.length,
                              itemBuilder: (context, index) {
                                return ProductCard(product: productProvider.products[index]);
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}