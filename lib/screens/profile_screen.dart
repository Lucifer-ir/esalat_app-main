import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shamsi_date/shamsi_date.dart'; // حتما در pubspec اضافه شود
import '../core/app_theme.dart';
import 'password_screen.dart';
import 'auth_screen.dart';
import 'info_pages.dart';
import 'user_info_screen.dart';
import 'subscription_screen.dart';
import 'fine_inquiry_screen.dart'; // صفحه استعلام خلافی

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _daysLeft = 0;
  DateTime? _expireDate;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  void _loadSubscriptionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? expireStr = prefs.getString('subExpire');
    if (expireStr != null) {
      DateTime expire = DateTime.parse(expireStr);
      int diff = expire.difference(DateTime.now()).inDays;
      setState(() {
        _expireDate = expire;
        _isActive = diff > 0;
        _daysLeft = diff > 0 ? diff : 0;
      });
    }
  }

  void _shareApp() {
    Share.share(
      'اپلیکیشن اصالت خودرو را نصب کنید و پیش از خرید، اصالت هر خودرو را استعلام کنید!\nدانلود از سایت: https://websera.ir',
      subject: 'دعوت به اپلیکیشن اصالت خودرو',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('حساب کاربری', style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Peyda', fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSubscriptionIndicator(),
              const SizedBox(height: 16),
              _buildMenuItem(context, icon: Icons.person_outline, title: 'اطلاعات کاربری', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserInfoScreen()))),
              const SizedBox(height: 8),
              // حذف const قبل از SubscriptionScreen
              _buildMenuItem(context, icon: Icons.card_membership_outlined, title: _isActive ? 'تمدید اشتراک' : 'خرید اشتراک', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubscriptionScreen())),
              ),
              const SizedBox(height: 8),
              _buildMenuItem(context, icon: Icons.lock_outline, title: 'رمز عبور', onTap: () => _handlePasswordTap(context)),
              const SizedBox(height: 8),
              _buildMenuItem(context, icon: Icons.headset_mic_outlined, title: 'تماس با ما', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen()))),
              const SizedBox(height: 8),
              _buildMenuItem(context, icon: Icons.info_outline, title: 'درباره ما', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen()))),
              const SizedBox(height: 8),
              _buildMenuItem(context, icon: Icons.security_outlined, title: 'حریم خصوصی و امنیت', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()))),
              const SizedBox(height: 8),
              _buildMenuItem(context, icon: Icons.question_answer_outlined, title: 'سوالات متداول', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQScreen()))),
              const SizedBox(height: 8),
              _buildMenuItem(context, icon: Icons.group_outlined, title: 'دعوت از دوستان', onTap: _shareApp),
              const SizedBox(height: 24),
              _buildMenuItem(context, icon: Icons.exit_to_app, title: 'خروج از حساب', color: AppColors.danger, onTap: () => _showLogoutSheet(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionIndicator() {
    double percent = _daysLeft / 7;
    if (percent > 1.0) percent = 1.0;
    if (percent < 0.0) percent = 0.0;

    String persianExpDate = '';
    if (_expireDate != null) {
      Jalali j = Jalali.fromDateTime(_expireDate!);
      persianExpDate = "${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}";
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 100.0, lineWidth: 15.0, percent: _isActive ? percent : 0.0, animation: true, animationDuration: 1200,
            circularStrokeCap: CircularStrokeCap.round, backgroundColor: AppColors.mattedGrey, progressColor: _isActive ? AppColors.primary : AppColors.danger,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_isActive ? Icons.check_circle_outline : Icons.cancel_outlined, color: _isActive ? AppColors.primary : AppColors.danger, size: 36),
                const SizedBox(height: 8),
                Text(_isActive ? '$_daysLeft روز' : 'منقضی', style: TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.w700, fontSize: 24, color: _isActive ? AppColors.primary : AppColors.danger)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(_isActive ? 'اشتراک شما فعال است' : 'اشتراک شما به پایان رسیده است', style: TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.w600, fontSize: 16, color: _isActive ? AppColors.textPrimary : AppColors.danger)),
          if (persianExpDate.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('تاریخ انقضا: $persianExpDate', style: const TextStyle(fontFamily: 'Peyda', fontSize: 14, color: AppColors.textSecondary)),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color color = AppColors.textPrimary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [Icon(icon, color: color), const SizedBox(width: 12), Text(title, style: TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.w500, color: color))]),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
          ]),
        ),
      ),
    );
  }

  void _handlePasswordTap(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasPassword = prefs.getBool('hasPassword') ?? false;
    if (hasPassword) { _showPasswordOptionsSheet(context); } 
    else { Navigator.push(context, MaterialPageRoute(builder: (_) => const PasswordScreen(mode: PasswordMode.set))); }
  }

  void _showPasswordOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const PasswordScreen(mode: PasswordMode.confirmForEdit))); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12)),
              child: Directionality(textDirection: TextDirection.rtl, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: const [Icon(Icons.edit_outlined, color: AppColors.primary), SizedBox(width: 12), Text('ویرایش رمز عبور', style: TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.w500))]), const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary)])),
            ),
          ),
          const SizedBox(height: 8), const Divider(color: Color(0xFFE0E0E0), height: 1, indent: 40, endIndent: 40), const SizedBox(height: 8),
          GestureDetector(
            onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const PasswordScreen(mode: PasswordMode.confirmForRemove))); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12)),
              child: Directionality(textDirection: TextDirection.rtl, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: const [Icon(Icons.delete_outline, color: AppColors.danger), SizedBox(width: 12), Text('حذف رمز عبور', style: TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.w500, color: AppColors.danger))]), const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary)])),
            ),
          ),
        ]),
      ),
    );
  }

  void _showLogoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 16),
          const Text('آیا تمایل برای خروج از حساب کاربری خود را دارید؟', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.w500, fontSize: 16)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: SizedBox(height: 50, child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('انصراف', style: TextStyle(fontFamily: 'Peyda', color: AppColors.primary))))),
            const SizedBox(width: 12),
            Expanded(child: SizedBox(height: 50, child: ElevatedButton(onPressed: () async { SharedPreferences prefs = await SharedPreferences.getInstance(); await prefs.clear(); Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (route) => false); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0), child: const Text('خروج', style: TextStyle(fontFamily: 'Peyda', color: Colors.white))))),
          ]),
        ]),
      ),
    );
  }
}