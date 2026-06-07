import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/app_theme.dart';

class FineInquiryScreen extends StatefulWidget {
  const FineInquiryScreen({Key? key}) : super(key: key);

  @override
  State<FineInquiryScreen> createState() => _FineInquiryScreenState();
}

class _FineInquiryScreenState extends State<FineInquiryScreen> {
  final TextEditingController _nationalCodeController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _plateController = TextEditingController(); // فرمت: ایران 11 – 1111 ب 11
  
  bool _isLoading = false;
  List<dynamic> _violations = [];
  int _totalAmount = 0;

  void _inquiryFines() async {
    if (_nationalCodeController.text.isEmpty || _mobileController.text.isEmpty || _plateController.text.isEmpty) {
      _showAlert('لطفا تمامی فیلدها را پر کنید', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://s.api.ir/api/sw1/VehicleViolation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer UH1kaxsUo3+EqeqAP1INB+x7rg0d8KBXmG4fmUAuVq7z+9ozoU9zI/o35uyx9xGLqrMgmtAl6vhL/T/gMKoxK4+Syk2JuaPx5+gn5eVBbp8='
        },
        body: jsonEncode({
          "nationalCode": _nationalCodeController.text,
          "mobile": _mobileController.text,
          "plateNumber": _plateController.text
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        setState(() {
          _violations = data['data']['violations'] ?? [];
          _totalAmount = data['data']['totalAmount'] ?? 0;
        });
      } else {
        _showAlert(data['message'] ?? 'خلافی یافت نشد یا خطایی رخ داده است', isError: true);
      }
    } catch (e) {
      _showAlert('خطا در اتصال به سرور', isError: true);
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
            child: Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: 'Peyda')),
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
        title: const Text('استعلام خلافی خودرو', style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Peyda', fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    TextField(
                      controller: _nationalCodeController, keyboardType: TextInputType.number,
                      style: const TextStyle(fontFamily: 'Peyda'),
                      decoration: InputDecoration(
                        labelText: 'کد ملی مالک', filled: true, fillColor: AppColors.mattedGrey,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _mobileController, keyboardType: TextInputType.phone,
                      style: const TextStyle(fontFamily: 'Peyda'),
                      decoration: InputDecoration(
                        labelText: 'شماره موبایل', filled: true, fillColor: AppColors.mattedGrey,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _plateController,
                      style: const TextStyle(fontFamily: 'Peyda'),
                      decoration: InputDecoration(
                        labelText: 'پلاک خودرو', hintText: 'ایران 11 – 1111 ب 11', filled: true, fillColor: AppColors.mattedGrey,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _inquiryFines,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('استعلام خلافی', style: TextStyle(fontFamily: 'Peyda', color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_violations.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
                    const SizedBox(width: 12),
                    Text('مبلغ کل خلافی: ${_totalAmount.toString().sefyan()} ریال', style: const TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.w700, color: AppColors.danger)),
                  ]),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  itemCount: _violations.length,
                  itemBuilder: (context, index) {
                    var item = _violations[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item['type'] ?? '', style: const TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Text('مبلغ: ${item['price'].toString().sefyan()} ریال', style: const TextStyle(fontFamily: 'Peyda', color: AppColors.danger, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text('شهر: ${item['city'] ?? '-'}', style: const TextStyle(fontFamily: 'Peyda', fontSize: 12, color: AppColors.textSecondary)),
                        Text('تاریخ: ${item['date'] ?? '-'}', style: const TextStyle(fontFamily: 'Peyda', fontSize: 12, color: AppColors.textSecondary)),
                      ]),
                    );
                  },
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// Extension برای فرمت کردن اعداد با کاما (مثل 600,000)
extension StringExtension on String {
  String sefyan() {
    return replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',');
  }
}