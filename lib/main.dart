import 'package:flutter/material.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_colors.dart';

void main() {
  runApp(const ReplayKidsApp());
}

class ReplayKidsApp extends StatelessWidget {
  const ReplayKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ReplayKids',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.neutral50,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.c500,
          primary: AppColors.c500,
          secondary: AppColors.c300,
        ),
      ),
    );
  }
}