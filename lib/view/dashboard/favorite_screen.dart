import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/movie_model.dart';
import '../../constants/app_colors.dart';
import 'shared_widgets.dart'; // Menggunakan MovieCard dari shared_widgets

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  // Key digunakan untuk memicu refresh pada FutureBuilder saat pull-to-refresh
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  Future<List<Movie>>? _favoriteMoviesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Fungsi untuk memuat ulang daftar favorit
  Future<void> _loadFavorites() async {
    setState(() {
      _favoriteMoviesFuture = ApiService().getFavoriteMoviesDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: _loadFavorites,
      color: AppColors.secondary,
      child: FutureBuilder<List<Movie>>(
        future: _favoriteMoviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat film favorit: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Anda belum menambahkan film favorit.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Ketuk ikon hati di detail film untuk menambahkannya!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final List<Movie> favoriteMovies = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: favoriteMovies.length,
            itemBuilder: (context, index) {
              final movie = favoriteMovies[index];
              return MovieCard(
                movie: movie,
                // Callback ini memicu pemuatan ulang list favorit ketika sebuah film dihapus dari favorit
                onFavoriteToggle: _loadFavorites,
              );
            },
          );
        },
      ),
    );
  }
}
