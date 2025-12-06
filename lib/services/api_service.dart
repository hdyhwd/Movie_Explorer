// Layanan untuk melakukan request ke TMDb API dan mengurai data menjadi model.

import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/movie_model.dart';
import '../utils/preferences_helper.dart'; // Import PreferencesHelper

class ApiService {
  // Inisialisasi Dio dengan Base URL dari constants
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  // ✅ FIXED: Helper untuk menambahkan status favorit TANPA menghilangkan data lain
  Future<List<Movie>> _applyFavoriteStatus(List<Movie> movies) async {
    final favoriteIds = await PreferencesHelper.getFavoriteMovieIds();
    return movies.map((movie) {
      // Update isFavorite saja, jangan buat Movie baru
      movie.isFavorite = favoriteIds.contains(movie.id);
      return movie;
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

        // Debug print
        if (results.isNotEmpty) {
          print('=== POPULAR MOVIES DEBUG ===');
          print('First movie genre_ids: ${results[0]['genre_ids']}');
        }

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
        queryParameters: {'api_key': ApiConstants.apiKey, 'language': 'en-US'},
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
          'with_genres': genreId,
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

  // --- 5. SEARCH MOVIES ---
  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/search/movie',
        queryParameters: {
          'api_key': ApiConstants.apiKey,
          'query': query,
          'language': 'en-US',
          'page': 1,
          'include_adult': false,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'] ?? [];
        final movies = results.map((json) => Movie.fromJson(json)).toList();

        // Tambahkan status favorit
        return await _applyFavoriteStatus(movies);
      }

      throw Exception(
        'Gagal mencari film. Status Code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      String errorMessage = 'Koneksi gagal atau API bermasalah (Search).';
      if (e.response?.statusCode != null) {
        errorMessage =
            'API Error ${e.response!.statusCode}: ${e.response!.statusMessage ?? e.message} (Search)';
      }
      print('Dio Error searching movies: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('Error searching movies (General): $e');
      throw Exception('Terjadi kesalahan umum saat mencari film.');
    }
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

  // --- 7.5. GET MOVIE VIDEOS (TRAILERS) --- ✅ BARU
  Future<List<MovieVideo>> getMovieVideos(int movieId) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId/videos',
        queryParameters: {'api_key': ApiConstants.apiKey, 'language': 'en-US'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> videosJson = response.data['results'] ?? [];
        final videos = videosJson
            .map((json) => MovieVideo.fromJson(json))
            .toList();

        // Filter hanya YouTube videos dan sort by official & trailer first
        final youtubeVideos = videos.where((v) => v.isYouTube).toList();
        youtubeVideos.sort((a, b) {
          // Official trailer first
          if (a.official && !b.official) return -1;
          if (!a.official && b.official) return 1;
          // Then trailer type
          if (a.isTrailer && !b.isTrailer) return -1;
          if (!a.isTrailer && b.isTrailer) return 1;
          return 0;
        });

        return youtubeVideos;
      }
      return [];
    } on DioException catch (e) {
      print('Dio Error fetching movie videos: ${e.message}');
      return [];
    } catch (e) {
      print('Error fetching movie videos: $e');
      return [];
    }
  }

  // --- 8. GET MOVIE DETAIL (DIKOMBINASI DENGAN CREDITS) ---
  Future<Movie?> getMovieDetail(int movieId) async {
    try {
      final isFavorite = await PreferencesHelper.getFavoriteMovieIds().then(
        (ids) => ids.contains(movieId),
      );

      final responses = await Future.wait([
        _dio.get(
          '/movie/$movieId',
          queryParameters: {
            'api_key': ApiConstants.apiKey,
            'language': 'en-US',
          },
        ),
        getMovieCredits(movieId),
      ]);

      final detailResponse = responses[0] as Response;
      final castList = responses[1] as List<Cast>;

      if (detailResponse.statusCode == 200) {
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

  // --- 10. GET PRIMARY RELEASE DATE (Menggunakan endpoint /release_dates) ---
  // Fungsi baru ini mengambil data rilis detail dan mencari TANGGAL rilis teater pertama (YYYY-MM-DD).
  Future<String> getMoviePrimaryReleaseDate(int movieId) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId/release_dates',
        queryParameters: {'api_key': ApiConstants.apiKey},
      );

      // Kita tidak memerlukan model MovieReleaseDates yang kompleks di sini,
      // cukup parsing JSON untuk menemukan tanggal tercepat.
      final results = (response.data['results'] as List<dynamic>?) ?? [];

      DateTime? earliestTheaterDateTime;
      String primaryReleaseDateString = 'TBA';

      for (var result in results) {
        final dates = (result['release_dates'] as List<dynamic>?) ?? [];

        for (var dateItem in dates) {
          final releaseDateStringWithTime = dateItem['release_date'] as String?;
          final type = dateItem['type'] as int?; // 3 = Theatrical

          if (releaseDateStringWithTime != null &&
              releaseDateStringWithTime.isNotEmpty &&
              type == 3) {
            final currentDateTime = DateTime.tryParse(
              releaseDateStringWithTime,
            );

            if (currentDateTime != null) {
              // Cek apakah ini rilis teater yang paling awal
              if (earliestTheaterDateTime == null ||
                  currentDateTime.isBefore(earliestTheaterDateTime)) {
                earliestTheaterDateTime = currentDateTime;

                // Ambil string tanggal rilis (YYYY-MM-DD) dan potong bagian waktu (T00:00:00.000Z)
                primaryReleaseDateString = releaseDateStringWithTime.split(
                  'T',
                )[0];
              }
            }
          }
        }
      }

      // Jika tidak ditemukan rilis teater (type: 3), fallback ke tanggal rilis yang paling awal ditemukan (type apapun)
      if (primaryReleaseDateString == 'TBA' &&
          earliestTheaterDateTime != null) {
        primaryReleaseDateString = earliestTheaterDateTime
            .toIso8601String()
            .split('T')[0];
      }

      return primaryReleaseDateString; // Mengembalikan string YYYY-MM-DD
    } on DioException catch (e) {
      print('Error fetching movie release dates: ${e.message}');
      return 'N/A';
    } catch (e) {
      print('An unexpected error occurred: $e');
      return 'N/A';
    }
  }
}
