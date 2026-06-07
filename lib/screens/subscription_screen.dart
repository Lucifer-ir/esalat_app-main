import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlan = 0;
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _plans = [
    {'months': 1, 'price': 49000, 'label': '۱ ماهه'},
    {'months': 3, 'price': 129000, 'label': '۳ ماهه', 'discount': '۱۲٪'},
    {'months': 6, 'price': 229000, 'label': '۶ ماهه', 'discount': '۲۲٪'},
    {'months': 12, 'price': 389000, 'label': '۱ ساله', 'discount': '۳۴٪'},
  ];

  void _processPayment() async {
    setState(() => _isProcessing = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = prefs.getString('userPhone') ?? '';
    int amount = _plans[_selectedPlan]['price'];

    // باز کردن صفحه payment.php در مرورگر درون برنامه‌ای
    String url = "http://websera.ir/payment.php?amount=$amount&phone=$phone&name=User";
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در اتصال به درگاه'), backgroundColor: AppColors.danger));
    }

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('خرید اشتراک', style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Peyda', fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureItem('استعلام نامحدود اصالت خودرو'),
                  _buildFeatureItem('مشاهده سابقه تصادفات و تعمیرات'),
                  _buildFeatureItem('استعلام خلافی لحظه‌ای'),
                  _buildFeatureItem('مشاهده مشخصات فنی کامل'),
                  const SizedBox(height: 24),
                  const Text('انتخاب پلن اشتراک:', style: TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildPlanSelector(),
                ],
              ),
            ),
          ),
          _buildBottomPaymentSection(),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontFamily: 'Peyda', fontSize: 14, color: AppColors.textPrimary)),
      ]),
    );
  }

  Widget _buildPlanSelector() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _plans.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedPlan == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedPlan = index),
            child: Container(
              width: 110,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_plans[index]['discount'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(8)),
                      child: Text(_plans[index]['discount'] + ' تخفیف', style: const TextStyle(color: Colors.white, fontFamily: 'Peyda', fontSize: 10)),
                    )
                  else const SizedBox(height: 18),
                  const SizedBox(height: 4),
                  Text(_plans[index]['label'] as String, style: TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.w700, fontSize: 16, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('${_plans[index]['price'] ~/ 1000} هزار تومان', style: TextStyle(fontFamily: 'Peyda', fontSize: 12, color: isSelected ? AppColors.primary : AppColors.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('مبلغ قابل پرداخت:', style: TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.w500)),
            Text('${_plans[_selectedPlan]['price'] ~/ 1000} هزار تومان', style: const TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.primary)),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _isProcessing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('پرداخت امن با درگاه زیبال', style: TextStyle(fontFamily: 'Peyda', color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}