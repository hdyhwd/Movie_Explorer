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
      if (genreId == null || genreId == 0) {
        // Jika "Semua Genre" dipilih (ID null atau 0), tampilkan film populer
        _moviesFuture = ApiService().getPopularMovies();
      } else {
        // Tampilkan film berdasarkan genre yang dipilih
        _moviesFuture = ApiService().getMoviesByGenre(genreId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Widget Dropdown Filter Genre
        FutureBuilder<List<Genre>>(
          future: _genresFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: Text('Memuat Genre...')),
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Gagal memuat genre: ${snapshot.error}'),
              );
            }

            // Tambahkan opsi 'Semua Film' di awal list
            final List<Genre> genres = [_selectedGenre, ...snapshot.data!];

            // Hapus duplikasi genre ID 0 (jika ada) dan siapkan list final
            final uniqueGenres = genres
                .where((g) => g.id != 0)
                .toSet()
                .toList();
            final finalGenres = [_selectedGenre, ...uniqueGenres];

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: DropdownButtonFormField<Genre>(
                decoration: InputDecoration(
                  labelText: 'Filter Berdasarkan Genre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(
                    Icons.category,
                    color: AppColors.primary,
                  ),
                ),
                // Pastikan nilai yang dipilih ada di items
                value: finalGenres.firstWhere(
                  (g) => g.id == _selectedGenre.id,
                  orElse: () => _selectedGenre,
                ),
                items: finalGenres.map((genre) {
                  return DropdownMenuItem<Genre>(
                    value: genre,
                    child: Text(genre.name),
                  );
                }).toList(),
                onChanged: (Genre? newValue) {
                  if (newValue != null) {
                    _filterMovies(newValue.id);
                    setState(() {
                      _selectedGenre = newValue;
                    });
                  }
                },
              ),
            );
          },
        ),

        // Daftar Film (Grid View)
        Expanded(
          child: FutureBuilder<List<Movie>>(
            future: _moviesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Gagal memuat film: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'Tidak ada film ditemukan untuk ${_selectedGenre.name}.',
                  ),
                );
              }

              final List<Movie> movies = snapshot.data!;

              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
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
