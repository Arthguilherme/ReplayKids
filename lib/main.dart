import 'package:flutter/material.dart';
import 'core/injector/injector.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:replaykids/core/notifications/push_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Supabase.initialize(
    url: 'https://obptbvkmfgohansfvcap.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9icHRidmttZmdvaGFuc2Z2Y2FwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc0OTQ1NTIsImV4cCI6MjEwMzA3MDU1Mn0.Si0tN3or-p3CtJEb1XDSMe8hQ2_4fOlSXeekmx2mAJw',
  );

  setupInjector();
  await injector.get<PushService>().iniciarListeners(); 
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