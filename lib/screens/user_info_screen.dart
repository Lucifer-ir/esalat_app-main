import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/app_theme.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneController.text = prefs.getString('userPhone') ?? '';
      _nameController.text = prefs.getString('userName') ?? '';
    });
  }

  void _saveUserInfo() async {
    if (_nameController.text.isEmpty) {
      _showAlert('لطفا نام و نام خانوادگی را وارد کنید', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ارسال به سرور برای آپدیت دیتابیس
      var response = await http.post(
        Uri.parse("http://websera.ir/auth.php?action=update_user"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"phone": _phoneController.text, "name": _nameController.text}),
      );

      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', _nameController.text);
        _showAlert('اطلاعات با موفقیت ثبت شد', isError: false);
      } else {
        _showAlert(data['message'] ?? 'خطا در ثبت اطلاعات', isError: true);
      }
    } catch (e) {
      // ذخیره محلی در صورت عدم اتصال به اینترنت
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      _showAlert('اطلاعات به صورت محلی ذخیره شد', isError: false);
    }

    setState(() => _isLoading = false);
  }

  void _showAlert(String msg, {bool isError = false}) {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50, left: 16, right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(color: isError ? AppColors.danger : Colors.green, borderRadius: BorderRadius.circular(12)),
            child: Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: 'Peyda', fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry?.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('اطلاعات کاربری', style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Peyda', fontWeight: FontWeight.w700)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نام و نام خانوادگی', style: TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(fontFamily: 'Peyda'),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'مثلا: علی محمدی',
                filled: true, fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('شماره موبایل (غیرقابل تغییر)', style: TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              enabled: false, // غیرفعال بودن
              style: const TextStyle(fontFamily: 'Peyda', color: AppColors.textSecondary),
              decoration: InputDecoration(
                filled: true, fillColor: AppColors.mattedGrey.withOpacity(0.5),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveUserInfo,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0),
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('ثبت اطلاعات', style: TextStyle(fontFamily: 'Peyda', color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}