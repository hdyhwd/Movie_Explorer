import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/movie_model.dart';
import '../../constants/app_colors.dart';
import 'shared_widgets.dart'; // Import MovieCard dan Shared Widgets

class AllMoviesScreen extends StatefulWidget {
  const AllMoviesScreen({super.key});

  @override
  State<AllMoviesScreen> createState() => _AllMoviesScreenState();
}

class _AllMoviesScreenState extends State<AllMoviesScreen> {
  Future<List<Genre>>? _genresFuture;
  int? _selectedGenreId;

  // Inisialisasi Genre "Semua Film" sebagai default
  Genre _selectedGenre = Genre(id: 0, name: 'Semua Film');

  Future<List<Movie>>? _moviesFuture;

  // Controller untuk search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _genresFuture = ApiService().getGenres();

    // Inisialisasi awal _moviesFuture (Semua Film = Populer)
    _moviesFuture = ApiService().getPopularMovies();
  }

  void _filterMovies(int? genreId) {
    setState(() {
      _selectedGenreId = genreId;
      _searchController.clear(); // Clear search saat ganti genre
      _searchQuery = '';

      if (genreId == null || genreId == 0) {
        // Jika "Semua Genre" dipilih (ID null atau 0), tampilkan film populer
        _moviesFuture = ApiService().getPopularMovies();
      } else {
        // Tampilkan film berdasarkan genre yang dipilih
        _moviesFuture = ApiService().getMoviesByGenre(genreId);
      }
    });
  }

  void _searchMovies(String query) {
    if (query.trim().isEmpty) {
      // Jika search kosong, kembali ke filter genre yang aktif
      _filterMovies(_selectedGenreId);
      setState(() {
        _searchQuery = '';
      });
    } else {
      // Jika ada search query, panggil API search
      setState(() {
        _searchQuery = query.toLowerCase();
        _moviesFuture = ApiService().searchMovies(query);
      });
    }
  }

  List<Movie> _getDisplayMovies(List<Movie> movies) {
    // Tidak perlu filter lokal lagi karena sudah pakai API search
    return movies;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Semua Film 🎬',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Temukan film favorit Anda',
                style: TextStyle(fontSize: 16, color: AppColors.textGray),
              ),
            ],
          ),
        ),

        // Search Bar + Dropdown Genre dalam 1 baris
        Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Row(
            children: [
              // Search Bar (Kiri - Lebar)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.surfaceColor,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 14,
                    ),
                    onChanged: _searchMovies,
                    decoration: InputDecoration(
                      hintText: 'Cari film...',
                      hintStyle: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textLight,
                          size: 18,
                        ),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: AppColors.textGray,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _searchMovies('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Dropdown Genre (Kanan - Kecil)
              FutureBuilder<List<Genre>>(
                future: _genresFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: 60,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.surfaceColor,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Container(
                      width: 60,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 22,
                      ),
                    );
                  }

                  // Tambahkan opsi 'Semua Film' di awal list
                  final List<Genre> genres = [
                    _selectedGenre,
                    ...snapshot.data!,
                  ];

                  // Hapus duplikasi genre ID 0 (jika ada) dan siapkan list final
                  final uniqueGenres = genres
                      .where((g) => g.id != 0)
                      .toSet()
                      .toList();
                  final finalGenres = [_selectedGenre, ...uniqueGenres];

                  return Container(
                    width: 60,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.surfaceColor,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: PopupMenuButton<Genre>(
                      color: AppColors.cardBackground,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.filter_list_rounded,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                      ),
                      tooltip: 'Filter Genre',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      offset: const Offset(0, 10),
                      itemBuilder: (BuildContext context) {
                        return finalGenres.map((genre) {
                          final isSelected = genre.id == _selectedGenre.id;
                          return PopupMenuItem<Genre>(
                            value: genre,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  if (isSelected)
                                    Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.2,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_rounded,
                                        color: AppColors.primary,
                                        size: 14,
                                      ),
                                    )
                                  else
                                    const SizedBox(width: 28),
                                  Expanded(
                                    child: Text(
                                      genre.name,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textLight,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList();
                      },
                      onSelected: (Genre selectedGenre) {
                        _filterMovies(selectedGenre.id);
                        setState(() {
                          _selectedGenre = selectedGenre;
                        });
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Daftar Film (Grid View)
        Expanded(
          child: FutureBuilder<List<Movie>>(
            future: _moviesFuture,
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
                      const SizedBox(height: 16),
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
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
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
                          size: 54,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Gagal memuat film',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.movie_outlined,
                          color: AppColors.textGray,
                          size: 54,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada film ditemukan untuk ${_selectedGenre.name}.',
                          textAlign: TextAlign.center,
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

              // Gunakan movies langsung dari API (sudah ter-filter)
              final List<Movie> displayMovies = _getDisplayMovies(movies);

              // Jika hasil search/filter kosong
              if (displayMovies.isEmpty) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off_rounded
                              : Icons.movie_outlined,
                          color: AppColors.textGray,
                          size: 54,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Film tidak ditemukan'
                              : 'Tidak ada film',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Coba kata kunci lain untuk pencarian Anda'
                              : 'untuk ${_selectedGenre.name}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(14),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: displayMovies.length,
                itemBuilder: (context, index) {
                  final movie = displayMovies[index];
                  // Menggunakan MovieCard dari shared_widgets
                  return MovieCard(movie: movie);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
