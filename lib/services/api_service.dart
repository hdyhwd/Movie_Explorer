// Layanan untuk melakukan request ke TMDb API dan mengurai data menjadi model.

import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/movie_model.dart';
import '../utils/preferences_helper.dart'; // Import PreferencesHelper

class ApiService {
  // Inisialisasi Dio dengan Base URL dari constants
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  // Helper untuk menambahkan status favorit ke list film yang diterima dari API
  Future<List<Movie>> _applyFavoriteStatus(List<Movie> movies) async {
    final favoriteIds = await PreferencesHelper.getFavoriteMovieIds();
    return movies.map((movie) {
      // Membuat salinan Movie dengan status favorit yang diperbarui
      return Movie(
        id: movie.id,
        title: movie.title,
        overview: movie.overview,
        posterPath: movie.posterPath,
        releaseDate: movie.releaseDate,
        voteAverage: movie.voteAverage,
        cast: movie.cast,
        isFavorite: favoriteIds.contains(movie.id),
      );
    }).toList();
  }

  // --- 1. GET POPULAR MOVIES ---
  Future<List<Movie>> getPopularMovies() async {
    try {
      final response = await _dio.get(
        '/discover/movie',
        queryParameters: {
          'api_key': ApiConstants.apiKey,
          'sort_by': 'popularity.desc',
          'include_adult': false,
          'include_video': false,
          'language': 'en-US',
          'page': 1,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        final movies = results.map((json) => Movie.fromJson(json)).toList();

        // Tambahkan status favorit
        return await _applyFavoriteStatus(movies);
      }

      throw Exception(
        'Gagal mendapatkan data film. Status Code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      String errorMessage = 'Koneksi gagal atau API bermasalah.';
      if (e.response?.statusCode != null) {
        errorMessage =
            'API Error ${e.response!.statusCode}: ${e.response!.statusMessage ?? e.message}';
      }
      print('Dio Error fetching popular movies: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('Error fetching popular movies (General): $e');
      throw Exception('Terjadi kesalahan umum saat memproses data.');
    }
  }

  // --- 2. GET TRENDING MOVIES (Menggunakan /week) ---
  Future<List<Movie>> getTrendingMovies() async {
    try {
      final response = await _dio.get(
        '/trending/movie/week',
        queryParameters: {
          'api_key': ApiConstants.apiKey, // Menggunakan V3 Key
          'language': 'en-US',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        final movies = results.map((json) => Movie.fromJson(json)).toList();

        // Tambahkan status favorit
        return await _applyFavoriteStatus(movies);
      }

      throw Exception(
        'Gagal mendapatkan data trending. Status Code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      String errorMessage = 'Koneksi gagal atau API bermasalah (Trending).';
      if (e.response?.statusCode != null) {
        errorMessage =
            'API Error ${e.response!.statusCode}: ${e.response!.statusMessage ?? e.message} (Trending)';
      }
      print('Dio Error fetching trending movies: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('Error fetching trending movies (General): $e');
      throw Exception('Terjadi kesalahan umum saat memproses data trending.');
    }
  }

  // --- 3. GET LIST GENRES ---
  Future<List<Genre>> getGenres() async {
    try {
      final response = await _dio.get(
        '/genre/movie/list',
        queryParameters: {'api_key': ApiConstants.apiKey, 'language': 'en-US'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> genreJson = response.data['genres'] ?? [];
        return genreJson.map((json) => Genre.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Dio Error fetching genres: ${e.message}');
      return [];
    } catch (e) {
      print('Error fetching genres: $e');
      return [];
    }
  }

  // --- 4. GET MOVIES BY GENRE ID ---
  Future<List<Movie>> getMoviesByGenre(int genreId) async {
    try {
      final response = await _dio.get(
        '/discover/movie',
        queryParameters: {
          'api_key': ApiConstants.apiKey,
          'with_genres': genreId, // Filter berdasarkan ID Genre
          'sort_by': 'popularity.desc',
          'language': 'en-US',
          'page': 1,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        final movies = results.map((json) => Movie.fromJson(json)).toList();

        // Tambahkan status favorit
        return await _applyFavoriteStatus(movies);
      }

      throw Exception(
        'Gagal mendapatkan film berdasarkan genre. Status Code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      String errorMessage = 'Koneksi gagal atau API bermasalah (Genre Filter).';
      if (e.response?.statusCode != null) {
        errorMessage =
            'API Error ${e.response!.statusCode}: ${e.response!.statusMessage ?? e.message} (Genre Filter)';
      }
      print('Dio Error fetching movies by genre: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('Error fetching movies by genre (General): $e');
      throw Exception('Terjadi kesalahan umum saat memproses data genre.');
    }
  }

  // --- 5. SEARCH MOVIES (Fitur ini di-skip) ---
  Future<List<Movie>> searchMovies(String query) async {
    // Fungsi ini dikosongkan karena fitur pencarian di-skip
    return [];
  }

  // --- 6. GET MOVIE CREDITS (PEMAIN) ---
  Future<List<Cast>> getMovieCredits(int movieId) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId/credits',
        queryParameters: {'api_key': ApiConstants.apiKey},
      );

      if (response.statusCode == 200) {
        final List<dynamic> castJson = response.data['cast'] ?? [];
        return castJson.map((json) => Cast.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Dio Error fetching movie credits: ${e.message}');
      return [];
    } catch (e) {
      print('Error fetching movie credits: $e');
      return [];
    }
  }

  // --- 7. GET MOVIE REVIEWS ---
  Future<List<Review>> getMovieReviews(int movieId) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId/reviews',
        queryParameters: {
          'api_key': ApiConstants.apiKey,
          'language': 'en-US',
          'page': 1,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> reviewsJson = response.data['results'] ?? [];
        return reviewsJson.map((json) => Review.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Dio Error fetching movie reviews: ${e.message}');
      return [];
    } catch (e) {
      print('Error fetching movie reviews: $e');
      return [];
    }
  }

  // --- 8. GET MOVIE DETAIL (DIKOMBINASI DENGAN CREDITS) ---
  Future<Movie?> getMovieDetail(int movieId) async {
    try {
      // Dapatkan status favorit sebelum request
      final isFavorite = await PreferencesHelper.getFavoriteMovieIds().then(
        (ids) => ids.contains(movieId),
      );

      // Lakukan request detail film dan credits secara paralel
      final responses = await Future.wait([
        _dio.get(
          '/movie/$movieId',
          queryParameters: {
            'api_key': ApiConstants.apiKey,
            'language': 'en-US',
          },
        ),
        getMovieCredits(movieId), // Panggil fungsi credits
      ]);

      final detailResponse = responses[0] as Response;
      final castList = responses[1] as List<Cast>;

      if (detailResponse.statusCode == 200) {
        // Gabungkan data detail film, daftar pemain, dan status favorit
        return Movie.fromDetailJson(
          detailResponse.data,
          castList,
          isFavorite: isFavorite,
        );
      }
      return null;
    } catch (e) {
      print('Error fetching movie detail and credits: $e');
      throw Exception('Gagal memuat detail film lengkap.');
    }
  }

  // --- 9. GET FAVORITE MOVIES DETAIL ---
  Future<List<Movie>> getFavoriteMoviesDetail() async {
    final favoriteIds = await PreferencesHelper.getFavoriteMovieIds();
    if (favoriteIds.isEmpty) return [];

    // Mengambil detail untuk setiap ID film favorit
    final futures = favoriteIds
        .map(
          (id) => _dio.get(
            '/movie/$id',
            queryParameters: {
              'api_key': ApiConstants.apiKey,
              'language': 'en-US',
            },
          ),
        )
        .toList();

    try {
      final responses = await Future.wait(futures);
      final List<Movie> favoriteMovies = [];

      for (var response in responses) {
        if (response.statusCode == 200) {
          // Buat objek Movie dan set isFavorite ke true
          favoriteMovies.add(Movie.fromJson(response.data, isFavorite: true));
        }
      }
      return favoriteMovies;
    } on DioException catch (e) {
      print('Dio Error fetching favorite movie details: ${e.message}');
      throw Exception('Gagal memuat detail film favorit.');
    } catch (e) {
      print('Error fetching favorite movie details (General): $e');
      throw Exception('Terjadi kesalahan umum saat memuat film favorit.');
    }
  }
}
