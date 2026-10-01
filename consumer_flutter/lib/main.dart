
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/auth/pages/login_page.dart';
import 'features/profile/providers/user_provider.dart';

import 'features/products/providers/product_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/wishlist/providers/wishlist_provider.dart';
import 'features/orders/providers/order_provider.dart';
import 'features/address/providers/address_provider.dart';
import 'features/category/providers/category_provider.dart';
import 'features/reviews/providers/review_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/pages/splash_page.dart';
import 'core/pages/app_shell.dart';
import 'core/providers/locale_provider.dart';
import 'l10n/app_localizations.dart';
import 'core/services/push_notification_service.dart';
import 'features/ai/providers/order_status_push_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  final orderStatusPushProvider = OrderStatusPushProvider();
  // TODO: provide the order-tracking navigation callback when the real push contract is wired.
  await PushNotificationService.instance.initialize(onOrderStatusChanged: orderStatusPushProvider.update);
  final userProvider = UserProvider();
  final authProvider = AuthProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: orderStatusPushProvider),
      ],
      // tryAutoLogin runs AFTER runApp — SplashPage stays visible while
      // it checks for a saved token, exactly the "restore session before
      // showing Login/Home" moment Firebase used to handle invisibly.
      child: _AppStartup(authProvider: authProvider, userProvider: userProvider),
    ),
  );
}

class _AppStartup extends StatefulWidget {
  final AuthProvider authProvider;
  final UserProvider userProvider;

  const _AppStartup({required this.authProvider, required this.userProvider});

  @override
  State<_AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<_AppStartup> {
  @override
  void initState() {
    super.initState();
    widget.authProvider.tryAutoLogin(widget.userProvider);
  }

  @override
  Widget build(BuildContext context) => const MyApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Clamp system font-size scaling to a safe, tested range (0.9x–1.2x)
      // rather than leaving it fully unbounded. Fixed-height product-grid
      // cards are pixel-budgeted against this range; an uncapped device
      // accessibility font size (users regularly set 1.5x–2x) would
      // silently overflow any fixed-height layout no matter what number
      // is chosen. This is standard practice in production commerce apps
      // (Swiggy, Zomato, Amazon, etc.) — accessibility scaling is still
      // respected within a range that keeps dense card grids reliable.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final clampedScaler = mediaQuery.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.2,
        );
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedScaler),
          child: child!,
        );
      },
      home: SplashPage(nextScreen: const AuthWrapper()),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!auth.isLoggedIn) {
      return const LoginPage();
    }
    return const AppShell();
  }
}