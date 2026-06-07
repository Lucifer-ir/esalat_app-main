import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart'; // پکیج جایگزین
import 'core/app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/payment_result_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _handleIncomingLinks(); // چک کردن لینک ورودی از درگاه پرداخت
  runApp(const MyApp());
}

// مدیریت لینک‌های ورودی (پرداخت درگاه)
void _handleIncomingLinks() async {
  final _appLinks = AppLinks();
  
  // اگر اپلیکیشن با کلیک روی لینک باز شده باشد (Cold start)
  try {
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _processLink(Uri.parse(initialLink.toString()));
    }
  } catch (e) {
    // در صورت عدم پشتیبانی یا خطا، نادیده می‌گیریم
  }
}

void _processLink(Uri uri) {
  if (uri.host == 'payment-result') {
    String status = uri.queryParameters['status'] ?? 'fail';
    String amount = uri.queryParameters['amount'] ?? '0';
    bool isSuccess = status == 'success';

    // مکث کوتاه برای اطمینان از لود کامل اپلیکیشن
    Future.delayed(const Duration(seconds: 1), () {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentResultScreen(isSuccess: isSuccess, amount: amount),
        ),
      );
    });
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _loadSavedTheme();
  }

  void _loadSavedTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'اصالت خودرو',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          navigatorKey: navigatorKey,
          home: const AuthScreen(),
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },
        );
      },
    );
  }
}