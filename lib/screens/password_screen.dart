import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';

enum PasswordMode { set, confirm, confirmForEdit, confirmForRemove, lockScreen }
enum PassStatus { idle, correct, wrong } // اضافه شدن حالت‌های فیدبک بصری

class PasswordScreen extends StatefulWidget {
  final PasswordMode mode;
  final String? firstPass;

  const PasswordScreen({Key? key, required this.mode, this.firstPass}) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  String _enteredPass = '';
  late String _firstPass;
  bool _isLoading = false;
  String _title = '';
  PassStatus _passStatus = PassStatus.idle; // متغیر کنترل رنگ و آیکون

  @override
  void initState() {
    super.initState();
    _firstPass = widget.firstPass ?? '';
    _setTitle();
  }

  void _setTitle() {
    if (widget.mode == PasswordMode.set) _title = 'تنظیم رمز عبور';
    else if (widget.mode == PasswordMode.confirm) _title = 'تایید رمز عبور';
    else if (widget.mode == PasswordMode.confirmForEdit) _title = 'وارد کردن رمز فعلی';
    else if (widget.mode == PasswordMode.confirmForRemove) _title = 'تایید برای حذف رمز';
    else if (widget.mode == PasswordMode.lockScreen) _title = 'رمز عبور';
  }

  void _onKeyTap(String value) {
    if (_enteredPass.length < 6) {
      setState(() {
        _enteredPass += value;
        _passStatus = PassStatus.idle; // ریست شدن حالت در هنگام تایپ
      });
      if (_enteredPass.length == 6) _handleFullPass();
    }
  }

  void _onDeleteTap() {
    if (_enteredPass.isNotEmpty) {
      setState(() {
        _enteredPass = _enteredPass.substring(0, _enteredPass.length - 1);
        _passStatus = PassStatus.idle;
      });
    }
  }

  void _handleFullPass() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPass = prefs.getString('appPassword');

    // بررسی درستی یا اشتباه بودن رمز برای فیدبک بصری
    bool isCorrect = false;

    if (widget.mode == PasswordMode.set) {
      isCorrect = true; // در مرحله اول تنظیم رمز، همیشه درست است
    } else if (widget.mode == PasswordMode.confirm) {
      isCorrect = (_firstPass == _enteredPass);
    } else if (widget.mode == PasswordMode.confirmForEdit || widget.mode == PasswordMode.confirmForRemove || widget.mode == PasswordMode.lockScreen) {
      isCorrect = (_enteredPass == savedPass);
    }

    // اعمال فیدبک بصری (سبز یا قرمز)
    setState(() {
      _passStatus = isCorrect ? PassStatus.correct : PassStatus.wrong;
    });

    // تاخیر برای نمایش فیدبک به کاربر
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    // پاک کردن رمز در صورت اشتباه
    if (!isCorrect) {
      setState(() => _enteredPass = '');
      _showAlertError(widget.mode == PasswordMode.confirm ? 'رمز تطابق ندارد' : 'رمز اشتباه است');
      return;
    }

    // ادامه عملیات در صورت درست بودن رمز
    if (widget.mode == PasswordMode.set) {
      _firstPass = _enteredPass;
      setState(() => _enteredPass = '');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PasswordScreen(mode: PasswordMode.confirm, firstPass: _firstPass)));
    } 
    else if (widget.mode == PasswordMode.confirm) {
      await prefs.setString('appPassword', _enteredPass);
      await prefs.setBool('hasPassword', true);
      _showAlertSuccess('رمز با موفقیت ثبت شد');
    }
    else if (widget.mode == PasswordMode.confirmForEdit) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PasswordScreen(mode: PasswordMode.set)));
    }
    else if (widget.mode == PasswordMode.confirmForRemove) {
      await prefs.remove('appPassword');
      await prefs.setBool('hasPassword', false);
      _showAlertSuccess('رمز با موفقیت حذف شد');
    }
    else if (widget.mode == PasswordMode.lockScreen) {
      Navigator.pop(context, true);
    }
  }

  void _showAlertSuccess(String msg) {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50, left: 16, right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)]),
            child: Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: 'Peyda', fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry?.remove();
      Navigator.pop(context);
    });
  }

  void _showAlertError(String msg) {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50, left: 16, right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)]),
            child: Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: 'Peyda', fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry?.remove());
  }

  @override
  Widget build(BuildContext context) {
    // تعیین رنگ و آیکون بر اساس وضعیت
    Color statusColor = AppColors.primary;
    IconData statusIcon = Icons.lock_outline;

    if (_passStatus == PassStatus.correct) {
      statusColor = Colors.green;
      statusIcon = Icons.lock_open_outlined; // قفل باز سبز
    } else if (_passStatus == PassStatus.wrong) {
      statusColor = AppColors.danger;
      statusIcon = Icons.lock_outline; // قفل بسته قرمز
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: widget.mode == PasswordMode.lockScreen 
          ? const SizedBox.shrink() 
          : IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        title: Text(_title, style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Peyda', fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          const Spacer(),
          _isLoading 
            ? const CircularProgressIndicator(color: AppColors.primary)
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(statusIcon, key: ValueKey<IconData>(statusIcon), size: 60, color: statusColor),
              ),
          const SizedBox(height: 24),
          Text(
            widget.mode == PasswordMode.set && _firstPass.isEmpty ? 'رمز عبور جدید خود را وارد کنید' : 'رمز عبور را تایید کنید',
            style: const TextStyle(fontFamily: 'Peyda', color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          _buildDots(statusColor),
          const Spacer(),
          Directionality(
            textDirection: TextDirection.ltr,
            child: _buildKeyboard(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ارسال رنگ وضعیت به مربع‌ها
  Widget _buildDots(Color activeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        bool isActive = index < _enteredPass.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 20, height: 20,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: isActive ? activeColor : Colors.grey, width: 2),
          ),
        );
      }),
    );
  }

  Widget _buildKeyboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(children: [ _buildKey('1'), _buildKey('2'), _buildKey('3') ]),
          Row(children: [ _buildKey('4'), _buildKey('5'), _buildKey('6') ]),
          Row(children: [ _buildKey('7'), _buildKey('8'), _buildKey('9') ]),
          Row(children: [ _buildDeleteText(), _buildKey('0'), _buildDeleteIcon() ]),
        ],
      ),
    );
  }

  Widget _buildKey(String num) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onKeyTap(num),
        child: Container(
          margin: const EdgeInsets.all(6), height: 50,
          decoration: BoxDecoration(color: AppColors.mattedGrey, borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(num, style: const TextStyle(fontSize: 22, fontFamily: 'Peyda', fontWeight: FontWeight.w700))),
        ),
      ),
    );
  }

  Widget _buildDeleteIcon() {
    return Expanded(
      child: GestureDetector(
        onTap: _onDeleteTap,
        child: Container(
          margin: const EdgeInsets.all(6), height: 50,
          decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Center(child: Icon(Icons.backspace_outlined, color: AppColors.danger, size: 20)),
        ),
      ),
    );
  }

  Widget _buildDeleteText() {
    return Expanded(
      child: GestureDetector(
        onTap: _onDeleteTap,
        child: Container(
          margin: const EdgeInsets.all(6), height: 50,
          decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Center(child: Text('Clear', style: TextStyle(color: AppColors.danger, fontFamily: 'Peyda', fontSize: 12, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}