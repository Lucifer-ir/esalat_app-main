// lib/screens/terms_screen.dart
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class TermsScreen extends StatelessWidget {
  final String title;
  final String content;

  const TermsScreen({Key? key, required this.title, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontFamily: 'Peyda',
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            content,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 2.0,
              fontFamily: 'Peyda',
            ),
          ),
        ),
      ),
    );
  }
}