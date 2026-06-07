// lib/screens/info_pages.dart
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

// یک کلاس پایه برای ساخت صفحات اطلاعاتی (جلوگیری از تکرار کد)
class InfoPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<InfoSection> sections;

  const InfoPage({Key? key, required this.title, required this.icon, required this.sections}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Peyda', fontWeight: FontWeight.w700)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildSectionCard(sections[index]);
        },
      ),
    );
  }

  Widget _buildSectionCard(InfoSection section) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.heading,
                  style: const TextStyle(
                    fontFamily: 'Peyda',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            section.content,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Peyda',
              fontSize: 14,
              height: 1.8,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// مدل داده‌ای برای بخش‌های متنی صفحات
class InfoSection {
  final String heading;
  final String content;

  InfoSection({required this.heading, required this.content});
}

// --------------------------------- صفحات مجزا ---------------------------------

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoPage(
      title: 'درباره ما',
      icon: Icons.info_outline,
      sections: [
        InfoSection(
          heading: 'چه کسی هستیم؟',
          content: 'تیم اصالت خودرو با هدف ایجاد امنیت و شفافیت در بازار خرید و فروش خودرو در سال ۱۴۰۲ تاسیس شد. ما با بهره‌گیری از جدیدترین تکنولوژی‌ها و اتصال مستقیم به پایگاه‌های داده معتبر، امکان استعلام دقیق و لحظه‌ای را برای کاربران فراهم کرده‌ایم.',
        ),
        InfoSection(
          heading: 'ماموریت ما',
          content: 'ماموریت ما جلوگیری از کلاهبرداری، فروش خودروهای تصادفی و مفقودی است. ما می‌خواهیم هر ایرانی پیش از انجام معامله، با خیالی آسوده اصالت خودروی مورد نظر خود را بررسی کند.',
        ),
        InfoSection(
          heading: 'توسعه‌دهندگان',
          content: 'این اپلیکیشن توسط تیم طراحی و توسعه JAM Programmer طراحی و پیاده‌سازی شده است.\nوبسایت: jamprogrammer.ir',
        ),
      ],
    );
  }
}

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoPage(
      title: 'تماس با ما',
      icon: Icons.headset_mic_outlined,
      sections: [
        InfoSection(
          heading: 'پشتیبانی مشتریان',
          content: 'برای سوالات، پیشنهادات و گزارش مشکلات فنی، می‌توانید از بخش "ثبت تیکت" در اپلیکیشن استفاده نمایید. تیم پشتیبانی ما در اسرع وقت به پیام شما پاسخ خواهد داد.',
        ),
        InfoSection(
          heading: 'شماره تماس',
          content: '۰۲۱-۱۲۳۴۵۶۷۸\n(شنبه تا پنجشنبه، ساعت ۹ الی ۱۸)',
        ),
        InfoSection(
          heading: 'پست الکترونیک',
          content: 'support@esalatkhodro.ir\nبرای مکاتبات رسمی و اداری از این ایمیل استفاده نمایید.',
        ),
        InfoSection(
          heading: 'آدرس دفتر',
          content: 'تهران، خیابان ولیعصر، برج ...، طبقه ...، تیم اصالت خودرو',
        ),
      ],
    );
  }
}

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoPage(
      title: 'حریم خصوصی و امنیت',
      icon: Icons.security_outlined,
      sections: [
        InfoSection(
          heading: 'محافظت از داده‌ها',
          content: 'ما به حریم خصوصی کاربران خود احترام می‌گذاریم. اطلاعات شخصی شما (مانند شماره موبایل) تنها برای احراز هویت و ارائه خدمات استفاده می‌شود و هرگز به شخص ثالث فروخته یا منتقل نخواهد شد.',
        ),
        InfoSection(
          heading: 'امنیت تراکنش‌ها',
          content: 'تمامی ارتباطات بین اپلیکیشن شما و سرورهای ما از طریق پروتکل‌های رمزنگاری شده (SSL/HTTPS) انجام می‌شود تا از شنود اطلاعات جلوگیری شود.',
        ),
        InfoSection(
          heading: 'رمز عبور برنامه',
          content: 'شما می‌توانید با تنظیم رمز عبور در بخش حساب کاربری، از ورود افراد غیرمجاز به اپلیکیشن خود جلوگیری کنید. این رمز به صورت محلی روی دستگاه شما ذخیره می‌شود.',
        ),
        InfoSection(
          heading: 'دسترسی‌های اپلیکیشن',
          content: 'این اپلیکیشن تنها به حداقل دسترسی‌های لازم (دسترسی به اینترنت برای ارسال درخواست‌ها) نیاز دارد و هیچ دسترسی غیرضروری به مخاطبین، گالری یا موقعیت مکانی شما ندارد.',
        ),
      ],
    );
  }
}

class FAQScreen extends StatelessWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoPage(
      title: 'سوالات متداول',
      icon: Icons.question_answer_outlined,
      sections: [
        InfoSection(
          heading: 'چگونه اشتراک خود را فعال کنم؟',
          content: 'پس از ثبت‌نام در اپلیکیشن، شما ۷ روز اشتراک رایگان خواهید داشت. پس از آن می‌توانید از بخش "خرید اشتراک" یکی از پلن‌های ماهانه یا سالانه را خریداری نمایید.',
        ),
        InfoSection(
          heading: 'اطلاعات استعلام شده چقدر دقیق است؟',
          content: 'اطلاعات مستقیماً از پایگاه‌های داده رسمی و شرکت‌های بیمه دریافت می‌شود، لذا دقت اطلاعات تا ۹۹.۹٪ تضمین شده است.',
        ),
        InfoSection(
          heading: 'آیا امکان بازگشت وجه وجود دارد؟',
          content: 'بله، در صورتی که به دلیل قطعی سرور نتوانید سرویس را دریافت کنید، تا ۲۴ ساعت پس از خرید امکان درخواست بازگشت وجه وجود دارد.',
        ),
        InfoSection(
          heading: 'چرا کد تایید برای من ارسال نمی‌شود؟',
          content: 'لطفاً مطمئن شوید شماره موبایل را به درستی وارد کرده‌اید و گوشی شما آنتن شبکه موبایل دارد. همچنین پیامک‌های تبلیغاتی گوشی خود را غیرمسدود کنید.',
        ),
      ],
    );
  }
}