// Tampilan untuk menampilkan detail lengkap dari satu film
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/movie_model.dart';
import '../../constants/api_constants.dart';
import '../../constants/app_colors.dart';
import '../../utils/preferences_helper.dart'; // Import untuk toggle favorit
import 'package:intl/intl.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;
  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Future<Movie?>? _movieDetailFuture;
  Future<List<Review>>? _reviewsFuture;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _movieDetailFuture = ApiService().getMovieDetail(widget.movieId).then((
        movie,
      ) {
        if (movie != null) {
          _isFavorite = movie.isFavorite; // Simpan status favorit awal
        }
        return movie;
      });
      _reviewsFuture = ApiService().getMovieReviews(widget.movieId);
    });
  }

  void _toggleFavorite() async {
    final isAdding = await PreferencesHelper.toggleFavorite(widget.movieId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAdding
                ? 'Film ditambahkan ke favorit.'
                : 'Film dihapus dari favorit.',
          ),
          backgroundColor: AppColors.secondary,
          duration: const Duration(seconds: 1),
        ),
      );
      setState(() {
        _isFavorite = isAdding;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Film',
          style: TextStyle(color: AppColors.textLight),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.textLight),
        actions: [
          IconButton(
            // Tombol Favorit di AppBar
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : AppColors.textLight,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: FutureBuilder<Movie?>(
        future: _movieDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error memuat detail film: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Detail film tidak ditemukan.'));
          }

          final Movie movie = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Poster (Header)
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: movie.posterPath.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(
                              '${ApiConstants.baseImageUrl}${movie.posterPath}',
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: AppColors.primary,
                  ),
                  child: movie.posterPath.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.movie,
                            size: 80,
                            color: AppColors.textLight,
                          ),
                        )
                      : null,
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Film
                      Text(
                        movie.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Rating & Tanggal Rilis
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 5),
                          Text(
                            '${movie.voteAverage.toStringAsFixed(1)} / 10',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Rilis: ${movie.releaseDate}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 30),

                      // Sinopsis (Overview)
                      const Text(
                        'Sinopsis:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.overview.isNotEmpty
                            ? movie.overview
                            : 'Sinopsis tidak tersedia.',
                        style: const TextStyle(fontSize: 16, height: 1.5),
                        textAlign: TextAlign.justify,
                      ),
                      const Divider(height: 30),

                      // Bagian Pemain (Cast)
                      if (movie.cast.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pemain Utama:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height:
                                  180, // Ketinggian untuk list pemain horizontal
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: movie.cast.length > 10
                                    ? 10
                                    : movie.cast.length, // Batasi 10 pemain
                                itemBuilder: (context, index) {
                                  final cast = movie.cast[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: CastCard(cast: cast),
                                  );
                                },
                              ),
                            ),
                            const Divider(height: 30),
                          ],
                        ),

                      if (movie.cast.isEmpty)
                        const Divider(
                          height: 30,
                        ), // Pemisah jika tidak ada pemain
                      // Bagian Review
                      MovieReviewsSection(reviewsFuture: _reviewsFuture!),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Widget untuk menampilkan kartu pemain (Cast Card)
class CastCard extends StatelessWidget {
  final Cast cast;
  const CastCard({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          // Foto Pemain
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: ClipOval(
              child: cast.profilePath != null
                  ? Image.network(
                      '${ApiConstants.baseImageUrl}${cast.profilePath}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primary,
                      ), // Fallback jika gambar gagal
                    )
                  : const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primary,
                    ), // Fallback jika path null
            ),
          ),
          const SizedBox(height: 5),
          // Nama Pemain
          Text(
            cast.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          // Nama Karakter
          Text(
            cast.character,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// Widget untuk menampilkan daftar Review
class MovieReviewsSection extends StatelessWidget {
  final Future<List<Review>> reviewsFuture;
  const MovieReviewsSection({super.key, required this.reviewsFuture});

  String _formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return isoDate;
    }
  }

  void _showFullReview(BuildContext context, Review review) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ulasan oleh ${review.author}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                if (review.rating != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 5),
                        Text(
                          'Rating: ${review.rating!.toStringAsFixed(1)} / 10',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                Text(review.content, textAlign: TextAlign.justify),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ulasan Pengguna:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),

        FutureBuilder<List<Review>>(
          future: reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Gagal memuat ulasan: ${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text(
                'Belum ada ulasan untuk film ini.',
                style: TextStyle(color: Colors.grey),
              );
            }

            final List<Review> reviews = snapshot.data!;

            return ListView.builder(
              physics:
                  const NeverScrollableScrollPhysics(), // Agar tidak bentrok dengan SingleChildScrollView utama
              shrinkWrap: true,
              itemCount: reviews.length > 5
                  ? 5
                  : reviews.length, // Batasi 5 ulasan teratas
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              review.author,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            if (review.rating != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: AppColors.textDark,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      review.rating!.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: AppColors.textDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Tanggal: ${_formatDate(review.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const Divider(),
                        Text(
                          review.content,
                          maxLines: 4, // Batasi 4 baris untuk ringkasan
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (review.content.length >
                            200) // Jika kontennya panjang, tambahkan tombol "Baca Selengkapnya"
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: InkWell(
                              onTap: () {
                                _showFullReview(context, review);
                              },
                              child: const Text(
                                'Baca Selengkapnya...',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
