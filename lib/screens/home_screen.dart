import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shamsi_date/shamsi_date.dart'; // تقویم شمسی
import '../core/app_theme.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'password_screen.dart';
import 'subscription_screen.dart';
import 'fine_inquiry_screen.dart'; // صفحه استعلام خلافی

class HomeScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  const HomeScreen({Key? key, required this.themeNotifier}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  bool _hasSubscription = false;
  bool _isUnlocked = false;
  bool _checkingLock = true;

  String _bannerUrl = '';
  String _bannerLink = '';
  Map<String, dynamic>? _announcement;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.history, 'title': 'استعلام اصالت'},
    {'icon': Icons.gavel_outlined, 'title': 'استعلام خلافی'}, // اضافه شد
    {'icon': Icons.directions_car_filled_outlined, 'title': 'مشخصات فنی'},
    {'icon': Icons.build_outlined, 'title': 'سابقه تعمیرات'},
    {'icon': Icons.local_shipping_outlined, 'title': 'سابقه تصادف'},
    {'icon': Icons.color_lens_outlined, 'title': 'تغییر رنگ'},
    {'icon': Icons.assignment_outlined, 'title': 'نمایش خلافی'},
    {'icon': Icons.price_check_outlined, 'title': 'ارزش‌گذاری'},
    {'icon': Icons.local_gas_station_outlined, 'title': 'مصرف سوخت'},
  ];

  @override
  void initState() {
    super.initState();
    _checkLockStatus();
  }

  void _checkLockStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasPassword = prefs.getBool('hasPassword') ?? false;
    String? savedPass = prefs.getString('appPassword');

    if (hasPassword && savedPass != null) {
      setState(() => _checkingLock = false);
      _showLockScreen();
    } else {
      _loadHomeData();
    }
  }

  void _showLockScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PasswordScreen(mode: PasswordMode.lockScreen), fullscreenDialog: true)).then((isSuccess) {
      if (isSuccess == true) { setState(() => _isUnlocked = true); _loadHomeData(); } 
      else { SystemNavigator.pop(); }
    });
  }

  void _loadHomeData() async {
    setState(() { _checkingLock = false; _isUnlocked = true; });
    _checkSubscription();
    await _fetchHomeData(); // گرفتن بنر و اعلامیه از سایت
    Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _isLoading = false); });
  }

  void _checkSubscription() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? expireStr = prefs.getString('subExpire');
    if (expireStr != null) {
      DateTime expireDate = DateTime.parse(expireStr);
      if (DateTime.now().isBefore(expireDate)) { setState(() => _hasSubscription = true); }
    }
  }

  Future<void> _fetchHomeData() async {
    try {
      // شبیه‌سازی درخواست به سایت (آدرس واقعی سایت)
      // final response = await http.get(Uri.parse('https://websera.ir/api/home_data.php'));
      // final data = jsonDecode(response.body);
      
      // داده‌های فرضی از سایت:
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _bannerUrl = 'https://websera.ir/banner.jpg';
        _bannerLink = 'https://websera.ir/offer';
        _announcement = {
          'title': 'نسخه جدید منتشر شد!',
          'message': 'همین الان اپلیکیشن را آپدیت کنید و از قابلیت‌های جدید استفاده کنید.',
          'button_text': 'دانلود',
          'expiry_date': '2025-05-20' // تاریخ انقضای اعلان از سایت
        };
      });

      // چک کردن انقضای اعلان
      if (_announcement != null) {
        DateTime expiry = DateTime.parse(_announcement!['expiry_date']);
        if (DateTime.now().isBefore(expiry)) {
          _showAnnouncementSheet();
        }
      }
    } catch (e) {
      print("Error fetching home data: $e");
    }
  }

  void _showAnnouncementSheet() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isDismissible: false,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 24),
          Text(_announcement!['title'] as String, style: const TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 12),
          Text(_announcement!['message'] as String, style: const TextStyle(fontFamily: 'Peyda', color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () { Navigator.pop(context); launchUrl(Uri.parse('https://websera.ir/update')); },
              child: Text(_announcement!['button_text'] as String, style: const TextStyle(fontFamily: 'Peyda', color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  void _toggleTheme() async {
    bool isCurrentlyDark = widget.themeNotifier.value == ThemeMode.dark;
    widget.themeNotifier.value = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', !isCurrentlyDark);
    setState(() {});
  }

  String _toPersianDate(DateTime dt) {
    Jalali j = Jalali.fromDateTime(dt);
    return "${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLock || !_isUnlocked) {
      return const Scaffold(backgroundColor: AppColors.primary, body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }
    bool isDark = widget.themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F7FA), elevation: 0, centerTitle: false, automaticallyImplyLeading: false,
        title: Text('اصالت خودرو', style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimary, fontFamily: 'Peyda')),
        actions: [
          _buildAppBarAction(context: context, isDark: isDark, icon: Icons.person_outline, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
          _buildAppBarAction(context: context, isDark: isDark, icon: Icons.notifications_none, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
          _buildAppBarAction(context: context, isDark: isDark, icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, onTap: _toggleTheme),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildBanner(isDark),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 12),
                      itemCount: _menuItems.length,
                      itemBuilder: (context, index) {
                        if (_isLoading) return _buildSkeletonGrid(isDark);
                        return _buildGridItem(_menuItems[index], isDark);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomActions(isDark),
        ],
      ),
    );
  }

  // بنر تبلیغاتی
  Widget _buildBanner(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: _isLoading 
        ? Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            highlightColor: isDark ? Colors.grey[700]! : Colors.white,
            child: Container(width: double.infinity, height: 150, decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(16))),
          )
        : GestureDetector(
            onTap: () {
              if(_bannerLink.isNotEmpty) launchUrl(Uri.parse(_bannerLink));
            },
            child: CachedNetworkImage(
              imageUrl: _bannerUrl,
              height: 150, width: double.infinity, fit: BoxFit.cover,
              httpHeaders: const {"Accept": "image/*"}, // برای سایت‌های ایرانی
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                highlightColor: isDark ? Colors.grey[700]! : Colors.white,
                child: Container(width: double.infinity, height: 150, decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white)),
              ),
              errorWidget: (context, url, error) => Container(
                height: 150, width: double.infinity, decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary),
              ),
            ),
          ),
    );
  }

  // آیتم‌های گرید با لاجیک ناوبری
  Widget _buildGridItem(Map<String, dynamic> item, bool isDark) {
    return GestureDetector(
      onTap: () {
        if (!_hasSubscription) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برای دسترسی نیاز به خرید اشتراک دارید'), backgroundColor: AppColors.danger));
          return;
        }

        // ناوبری به صفحات مربوطه
        String title = item['title'] as String;
        if (title == 'استعلام خلافی') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FineInquiryScreen()));
        } else if (title == 'استعلام اصالت') {
          // Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthInquiryScreen()));
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('صفحه $title در حال توسعه است'), backgroundColor: AppColors.primary));
        } else {
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('صفحه $title در حال توسعه است'), backgroundColor: AppColors.primary));
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
            child: Icon(item['icon'] as IconData, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(item['title'] as String, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.textSecondary, fontFamily: 'Peyda', fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSkeletonGrid(bool isDark) {
    return Column(
      children: [
        Shimmer.fromColors(baseColor: isDark ? Colors.grey[800]! : Colors.grey[200]!, highlightColor: isDark ? Colors.grey[700]! : Colors.white, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.circle, size: 28))),
        const SizedBox(height: 8),
        Shimmer.fromColors(baseColor: isDark ? Colors.grey[800]! : Colors.grey[200]!, highlightColor: isDark ? Colors.grey[700]! : Colors.white, child: Container(width: 50, height: 10, decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(4)))),
      ],
    );
  }

  // دو دکمه پایین صفحه با فاصله از کنترل‌های اندروید
  Widget _buildBottomActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), // 32 پیکسل فاصله از پایین
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () { 
                  // TODO: ناوبری به صفحه ثبت خودروی جدید
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                label: const Text('ثبت خودروی جدید', style: TextStyle(fontFamily: 'Peyda', color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () { 
                  // TODO: ناوبری به صفحه ثبت تصویر
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
                label: const Text('ثبت تصویر', style: TextStyle(fontFamily: 'Peyda', color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarAction({required BuildContext context, required bool isDark, required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 42, height: 42, margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2C) : Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))]),
      child: IconButton(padding: EdgeInsets.zero, icon: Icon(icon, color: isDark ? Colors.white70 : Colors.black87, size: 22), onPressed: onTap),
    );
  }
}