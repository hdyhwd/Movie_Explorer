import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../constants/app_colors.dart';
import '../auth/login_screen.dart';
import 'all_movies_screen.dart';
import 'favorite_screen.dart'; // NEW: Import Favorite Screen
import 'shared_widgets.dart'; // NEW: Import Shared Widgets

// Mengubah DashboardScreen menjadi HomeScreen (container dengan Bottom Navigation Bar)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Index tab yang aktif

  void _logout(BuildContext context) async {
    await AuthService().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  final List<Widget> _widgetOptions = <Widget>[
    // Tab 0: Beranda (Dashboard lama)
    const DashboardContent(),
    // Tab 1: Semua Film dengan Filter Genre
    const AllMoviesScreen(),
    // NEW: Tab 2: Favorit
    const FavoriteScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Movie Explorer',
          style: TextStyle(color: AppColors.textLight),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textLight),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Semua Film',
          ),
          BottomNavigationBarItem(
            // NEW: Item Favorit
            icon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: Colors.grey,
        backgroundColor: AppColors.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Konten Dashboard yang asli (Diubah namanya)
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategori 1: Film Populer
          MovieCategorySection(
            title: 'Paling Populer',
            future: ApiService().getPopularMovies(),
          ),
          const SizedBox(height: 20),

          // Kategori 2: Film Trending Minggu Ini
          MovieCategorySection(
            title: 'Trending Minggu Ini',
            future: ApiService().getTrendingMovies(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
