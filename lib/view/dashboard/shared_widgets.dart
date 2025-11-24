import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../constants/api_constants.dart';
import '../../constants/app_colors.dart';
import '../../utils/preferences_helper.dart';
import 'movie_detail_screen.dart';

// Definisi ulang MovieCard untuk mendukung state favorit dan callback
class MovieCard extends StatefulWidget {
  final Movie movie;
  // Callback opsional untuk memicu refresh pada parent widget (khususnya FavoriteScreen)
  final VoidCallback? onFavoriteToggle;

  const MovieCard({super.key, required this.movie, this.onFavoriteToggle});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  // Menggunakan state lokal untuk ikon favorit
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.movie.isFavorite;
  }

  void _toggleFavorite() async {
    final isAdding = await PreferencesHelper.toggleFavorite(widget.movie.id);

    // Memberi feedback kepada pengguna
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAdding
                ? '${widget.movie.title} ditambahkan ke favorit.'
                : '${widget.movie.title} dihapus dari favorit.',
          ),
          backgroundColor: AppColors.secondary,
          duration: const Duration(seconds: 1),
        ),
      );

      setState(() {
        _isFavorite = isAdding;
      });

      // Memanggil callback untuk memberitahu parent (jika ada) untuk refresh
      if (widget.onFavoriteToggle != null) {
        widget.onFavoriteToggle!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigasi ke detail dan tunggu hasil pop-nya (jika status favorit berubah)
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) =>
                    MovieDetailScreen(movieId: widget.movie.id),
              ),
            )
            .then((_) {
              // Refresh state favorit setelah kembali dari detail screen
              PreferencesHelper.getFavoriteMovieIds().then((ids) {
                if (mounted) {
                  setState(() {
                    _isFavorite = ids.contains(widget.movie.id);
                  });
                  // Jika ini dari FavoriteScreen, panggil callback untuk refresh list
                  if (widget.onFavoriteToggle != null) {
                    widget.onFavoriteToggle!();
                  }
                }
              });
            });
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: AppColors.textLight,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar Poster Film
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: widget.movie.posterPath.isNotEmpty
                        ? Image.network(
                            '${ApiConstants.baseImageUrl}${widget.movie.posterPath}',
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: AppColors.secondary,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 40,
                                    color: Colors.red,
                                  ),
                                ),
                          )
                        : const Center(child: Text('No Image Available')),
                  ),
                  // Tombol Favorit di pojok kanan atas
                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : AppColors.textLight,
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.7),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ),
                ],
              ),
            ),

            // Detail Teks Film
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          widget.movie.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '(${widget.movie.releaseDate.split('-')[0]})',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Re-export MovieCategorySection
class MovieCategorySection extends StatelessWidget {
  final String title;
  final Future<List<Movie>> future;

  const MovieCategorySection({
    super.key,
    required this.title,
    required this.future,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),

        SizedBox(
          height: 320, // Ketinggian untuk list horizontal
          child: FutureBuilder<List<Movie>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Gagal memuat kategori $title: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('Tidak ada film di kategori $title.'),
                );
              }

              final List<Movie> movies = snapshot.data!;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 16 : 0,
                      right: 10,
                    ),
                    // Menggunakan MovieCard yang baru
                    child: MovieCard(movie: movie),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
