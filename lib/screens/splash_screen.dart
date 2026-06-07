// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(); // تکرار انیمیشن

    // بعد از ۳ ثانیه میره به صفحه ورود
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary, // پس‌زمینه آبی اصلی
      body: Center( // اضافه شدن Center برای وسط چین شدن کامل در حالت RTL
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            // لوگو سفید وسط صفحه
            Icon(Icons.directions_car, size: 100, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'اصالت خودرو',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Peyda',
              ),
            ),
            Spacer(),
            // لودینگ سه نقطه سفید در پایین صفحه
            Padding(
              padding: EdgeInsets.only(bottom: 50.0),
              child: _ThreeDotsLoading(),
            ),
          ],
        ),
      ),
    );
  }
}

// ویجت انیمیشن سه نقطه سفید (اصلاح شده)
class _ThreeDotsLoading extends StatelessWidget {
  const _ThreeDotsLoading();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, // مهم برای وسط چین ماندن در RTL
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: DotBounce(index: index),
        );
      }),
    );
  }
}

class DotBounce extends StatefulWidget {
  final int index;
  const DotBounce({required this.index, Key? key}) : super(key: key);

  @override
  State<DotBounce> createState() => _DotBounceState();
}

class _DotBounceState extends State<DotBounce> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    Future.delayed(Duration(milliseconds: widget.index * 200), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller.drive(Tween(begin: 0.5, end: 1.2)),
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}