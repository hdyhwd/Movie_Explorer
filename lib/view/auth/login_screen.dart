// // Tampilan untuk proses login pengguna
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../constants/app_colors.dart';
// import '../../services/auth_service.dart';
// import '../dashboard/dashboard_screen.dart';
// import 'register_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final AuthService _authService = AuthService();
//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   void _login() async {
//     setState(() {
//       _isLoading = true;
//     });

//     final success = await _authService.login(
//       _usernameController.text.trim(),
//       _passwordController.text.trim(),
//     );

//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });

//       if (success) {
//         // Navigasi ke Dashboard dan hapus semua rute sebelumnya
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => const DashboardContent()),
//           (Route<dynamic> route) => false,
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text(
//               'Login Gagal. Cek username dan password (min 4 karakter).',
//               style: TextStyle(color: AppColors.textLight),
//             ),
//             backgroundColor: AppColors.error,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text(
//           'Movie Explorer',
//           style: TextStyle(
//             color: AppColors.textLight,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 1.2,
//           ),
//         ),
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         centerTitle: true,
//         systemOverlayStyle: const SystemUiOverlayStyle(
//           statusBarColor: AppColors.background,
//           statusBarIconBrightness: Brightness.light,
//         ),
//       ),
//       body: Container(
//         decoration: BoxDecoration(gradient: AppColors.darkGradient),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Logo/Icon with gradient background
//                 Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     gradient: AppColors.primaryGradient,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: AppColors.primary.withOpacity(0.3),
//                         blurRadius: 20,
//                         spreadRadius: 5,
//                       ),
//                     ],
//                   ),
//                   child: const Icon(
//                     Icons.movie_filter_rounded,
//                     size: 64,
//                     color: AppColors.textLight,
//                   ),
//                 ),
//                 const SizedBox(height: 32),

//                 // Welcome Text
//                 const Text(
//                   'Selamat Datang',
//                   style: TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textLight,
//                     letterSpacing: 1.5,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Masuk untuk melanjutkan',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: AppColors.textGray,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 const SizedBox(height: 48),

//                 // Username Field
//                 Container(
//                   decoration: BoxDecoration(
//                     color: AppColors.cardBackground,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: AppColors.surfaceColor, width: 1),
//                   ),
//                   child: TextField(
//                     controller: _usernameController,
//                     style: const TextStyle(color: AppColors.textLight),
//                     decoration: InputDecoration(
//                       labelText: 'Username',
//                       labelStyle: TextStyle(color: AppColors.textGray),
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.all(20),
//                       prefixIcon: const Icon(
//                         Icons.person_outline_rounded,
//                         color: AppColors.primary,
//                         size: 24,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Password Field
//                 Container(
//                   decoration: BoxDecoration(
//                     color: AppColors.cardBackground,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: AppColors.surfaceColor, width: 1),
//                   ),
//                   child: TextField(
//                     controller: _passwordController,
//                     obscureText: _obscurePassword,
//                     style: const TextStyle(color: AppColors.textLight),
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       labelStyle: TextStyle(color: AppColors.textGray),
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.all(20),
//                       prefixIcon: const Icon(
//                         Icons.lock_outline_rounded,
//                         color: AppColors.primary,
//                         size: 24,
//                       ),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword
//                               ? Icons.visibility_off_outlined
//                               : Icons.visibility_outlined,
//                           color: AppColors.textGray,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _obscurePassword = !_obscurePassword;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 32),

//                 // Login Button
//                 _isLoading
//                     ? Container(
//                         padding: const EdgeInsets.all(16),
//                         child: const CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             AppColors.primary,
//                           ),
//                         ),
//                       )
//                     : Container(
//                         width: double.infinity,
//                         height: 56,
//                         decoration: BoxDecoration(
//                           gradient: AppColors.primaryGradient,
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: AppColors.primary.withOpacity(0.3),
//                               blurRadius: 12,
//                               offset: const Offset(0, 6),
//                             ),
//                           ],
//                         ),
//                         child: ElevatedButton(
//                           onPressed: _login,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.transparent,
//                             shadowColor: Colors.transparent,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                           ),
//                           child: const Text(
//                             'LOGIN',
//                             style: TextStyle(
//                               fontSize: 18,
//                               color: AppColors.textLight,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 2,
//                             ),
//                           ),
//                         ),
//                       ),

//                 const SizedBox(height: 24),

//                 // Divider
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Divider(
//                         color: AppColors.surfaceColor,
//                         thickness: 1,
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Text(
//                         'atau',
//                         style: TextStyle(
//                           color: AppColors.textGray,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Divider(
//                         color: AppColors.surfaceColor,
//                         thickness: 1,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),

//                 // Register Link
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Belum punya akun? ',
//                       style: TextStyle(color: AppColors.textGray, fontSize: 15),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => const RegisterScreen(),
//                           ),
//                         );
//                       },
//                       style: TextButton.styleFrom(
//                         padding: EdgeInsets.zero,
//                         minimumSize: Size.zero,
//                         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                       ),
//                       child: const Text(
//                         'Daftar Sekarang',
//                         style: TextStyle(
//                           color: AppColors.primary,
//                           fontSize: 15,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }
