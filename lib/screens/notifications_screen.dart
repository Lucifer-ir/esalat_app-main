import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('پیام‌ها', style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Peyda', fontWeight: FontWeight.w700)),
      ),
      body: _isLoading ? _buildShimmer() : _buildList(),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[200]!, highlightColor: Colors.white,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 150, height: 14, color: Colors.white),
              const SizedBox(height: 8),
              Container(width: 100, height: 10, color: Colors.white),
              const SizedBox(height: 12),
              Container(width: double.infinity, height: 10, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMessageCard(
          title: 'به‌روزرسانی جدید',
          date: '1404/02/07',
          content: 'نسخه جدید اپلیکیشن با قابلیت استعلام سریع‌تر منتشر شد.',
          hasButton: true,
        ),
        _buildMessageCard(
          title: 'تخفیف ویژه اشتراک',
          date: '1404/02/05',
          content: 'به مناسبت روز خودرو، ۳۰ درصد تخفیف روی اشتراک ماهانه!',
          hasImage: true,
        ),
      ],
    );
  }

  Widget _buildMessageCard({required String title, required String date, required String content, bool hasButton = false, bool hasImage = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.error_outline, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Peyda', color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 4),
          Text(date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Peyda')),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontFamily: 'Peyda', height: 1.5, color: AppColors.textPrimary)),
          if (hasImage) ...[
            const SizedBox(height: 8),
            Container(height: 150, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image, color: AppColors.textSecondary)),
          ],
          if (hasButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 40,
              child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(elevation: 0), child: const Text('مشاهده جزئیات', style: TextStyle(fontFamily: 'Peyda'))),
            ),
          ],
        ],
      ),
    );
  }
}