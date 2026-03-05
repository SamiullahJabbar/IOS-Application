import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/user_model.dart';
import 'models/scan_model.dart';
import 'models/customization_model.dart';
import 'models/order_model.dart';
import 'providers/auth_provider.dart';
import 'providers/scan_provider.dart';
import 'providers/customization_provider.dart';
import 'providers/order_provider.dart';
import 'utils/app_theme.dart';
import 'utils/routes.dart';
import 'services/stripe_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.darkBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ScanModelAdapter());
  Hive.registerAdapter(CustomizationModelAdapter());
  Hive.registerAdapter(OrderModelAdapter());

  // Open Hive boxes
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<ScanModel>('scans');
  await Hive.openBox<OrderModel>('orders');

  // Initialize Stripe
  StripeService.init();

  runApp(const BodyScanApp());
}

class BodyScanApp extends StatelessWidget {
  const BodyScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider(create: (_) => CustomizationProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.router(context);
          return MaterialApp.router(
            title: 'Body Scan Pro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
