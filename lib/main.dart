// Titik masuk utama aplikasi, menangani tema dan penentuan rute awal (Login/Dashboard).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/app_colors.dart';
import 'view/auth/login_screen.dart';
import 'view/dashboard/dashboard_screen.dart'; // Import HomeScreen yang baru
import 'services/auth_service.dart';

void main() {
  // Wajib dipanggil sebelum menggunakan SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MovieExplorerApp());
}

class MovieExplorerApp extends StatelessWidget {
  const MovieExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengatur warna status bar untuk aplikasi
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'Movie Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppColors.secondary,
          primary: AppColors.primary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
