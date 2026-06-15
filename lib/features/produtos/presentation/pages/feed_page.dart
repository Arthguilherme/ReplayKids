import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c50,
      appBar: AppBar(
        backgroundColor: AppColors.c50,
        elevation: 0,
        title: const Text(
          'ReplayKids',
          style: TextStyle(
            color: AppColors.c900,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.c700),
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.c500, size: 64),
            SizedBox(height: 16),
            Text(
              'Login realizado com sucesso!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.c800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Feed de produtos em breve.',
              style: TextStyle(color: AppColors.neutral500),
            ),
          ],
        ),
      ),
    );
  }
}