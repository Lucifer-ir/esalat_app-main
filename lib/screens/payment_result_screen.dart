import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';

class PaymentResultScreen extends StatefulWidget {
  final bool isSuccess;
  final String? amount;

  const PaymentResultScreen({Key? key, required this.isSuccess, this.amount}) : super(key: key);

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    
    if (widget.isSuccess) {
      _activateSubscription();
    }
  }

  void _activateSubscription() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime newExpire = DateTime.now().add(const Duration(days: 30)); // اضافه شدن 30 روز اشتراک
    await prefs.setString('subExpire', newExpire.toIso8601String());
    await prefs.setBool('isSubActive', true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _controller.drive(CurveTween(curve: Curves.elasticOut)),
              child: Icon(
                widget.isSuccess ? Icons.check_circle : Icons.cancel,
                size: 100,
                color: widget.isSuccess ? Colors.green : AppColors.danger,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.isSuccess ? 'پرداخت موفق!' : 'پرداخت ناموفق',
              style: TextStyle(fontFamily: 'Peyda', fontSize: 24, fontWeight: FontWeight.w700, color: widget.isSuccess ? Colors.green : AppColors.danger),
            ),
            const SizedBox(height: 12),
            if (widget.isSuccess && widget.amount != null)
              Text('مبلغ پرداخت شده: ${int.tryParse(widget.amount!) ?? 0 ~/ 1000} هزار ریال', style: const TextStyle(fontFamily: 'Peyda', color: AppColors.textSecondary)),
            const SizedBox(height: 40),
            SizedBox(
              width: 200, height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('بازگشت', style: TextStyle(fontFamily: 'Peyda', color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}