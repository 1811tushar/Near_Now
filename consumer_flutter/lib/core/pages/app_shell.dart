import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/cart/pages/cart_page.dart';
import '../../features/cart/providers/cart_provider.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/orders/pages/order_history_page.dart';
import '../../features/profile/pages/view_profile_page.dart';
import '../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../features/ai/widgets/ai_chat_fab.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => AppShellState();

  static AppShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppShellState>();
  }
}

class AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    HomePage(),
    CartPage(),
    OrderHistoryPage(),
    ViewProfilePage(),
  ];

  void switchToTab(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cartItemCount = context.watch<CartProvider>().itemCount;

    Widget cartIcon(bool filled) {
      final icon = Icon(filled ? Icons.shopping_cart : Icons.shopping_cart_outlined);
      if (cartItemCount <= 0) return icon;
      return Badge(
        label: Text(cartItemCount > 99 ? '99+' : '$cartItemCount'),
        backgroundColor: AppColors.meadow,
        textColor: Colors.white,
        child: icon,
      );
    }

    return Scaffold(
      floatingActionButton: const AiChatFab(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 64,
          backgroundColor: AppColors.card,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.meadow.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.meadow : AppColors.inkSoft,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AppColors.meadow : AppColors.inkSoft,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: switchToTab,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n.home,
            ),
            NavigationDestination(
              icon: cartIcon(false),
              selectedIcon: cartIcon(true),
              label: l10n.cart,
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long),
              label: l10n.orders,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}