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
            style: const TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
        width: 160, // Ukuran yang lebih proporsional
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar Poster Film
            Expanded(
              flex: 7, // Proporsi poster lebih besar
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: widget.movie.posterPath.isNotEmpty
                        ? Stack(
                            children: [
                              Image.network(
                                '${ApiConstants.baseImageUrl}${widget.movie.posterPath}',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                          color: AppColors.primary,
                                          strokeWidth: 3,
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: AppColors.surfaceColor,
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image_rounded,
                                          size: 50,
                                          color: AppColors.textGray,
                                        ),
                                      ),
                                    ),
                              ),
                              // Gradient overlay at bottom
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 40, // Gradient lebih tipis
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        AppColors.cardBackground,
                                        AppColors.cardBackground.withOpacity(
                                          0.8,
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            color: AppColors.surfaceColor,
                            child: const Center(
                              child: Text(
                                'No Image',
                                style: TextStyle(color: AppColors.textGray),
                              ),
                            ),
                          ),
                  ),
                  // Rating badge di pojok kiri atas
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.textLight,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Detail Teks Film
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Judul Film
                  Text(
                    widget.movie.title,
                    maxLines: 2, // 2 baris untuk judul panjang
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textLight,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ✅ Genre Tags
                  Builder(
                    builder: (context) {
                      final genreNames = widget.movie.getGenreNames(
                        GenreHelper.genreMap,
                      );

                      // Debug: Print untuk cek data
                      print('Movie: ${widget.movie.title}');
                      print('Genre IDs: ${widget.movie.genreIds}');
                      print('Genre Names: $genreNames');

                      if (genreNames.isEmpty) {
                        return const SizedBox(height: 8);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: genreNames.map((genreName) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.4),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                genreName,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),

                  // Year & Favorite Button Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.movie.releaseDate.split('-')[0],
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Tombol Favorit
                      GestureDetector(
                        onTap: _toggleFavorite,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _isFavorite
                                ? AppColors.error.withOpacity(0.15)
                                : AppColors.surfaceColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _isFavorite
                                  ? AppColors.error
                                  : AppColors.textGray.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _isFavorite
                                ? AppColors.error
                                : AppColors.textGray,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
          padding: const EdgeInsets.only(left: 24.0, top: 8.0, bottom: 12.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 330, // Tinggi ditambah sedikit untuk genre tags
          child: FutureBuilder<List<Movie>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Memuat film...',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Gagal memuat kategori $title',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.movie_outlined,
                          color: AppColors.textGray,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada film di kategori $title',
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final List<Movie> movies = snapshot.data!;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 8 : 0,
                      right: 12,
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
