// Model untuk menampung data dari setiap film dan pemain (Cast) yang diterima dari API TMDb.

class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final double voteAverage;
  final List<Cast> cast;
  final List<int> genreIds; // ✅ TAMBAHAN: List genre IDs dari API
  final List<Genre>? genres; // ✅ TAMBAHAN: List genre lengkap (untuk detail)

  // Flag untuk menandai apakah film ini favorit pengguna
  bool isFavorite;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
    this.cast = const [],
    this.genreIds = const [], // ✅ TAMBAHAN: Default empty
    this.genres, // ✅ TAMBAHAN: Optional
    this.isFavorite = false,
  });

  // Factory constructor untuk membuat instance Movie dari JSON (Map)
  factory Movie.fromJson(Map<String, dynamic> json, {bool isFavorite = false}) {
    // ✅ TAMBAHAN: Parse genre_ids dari API
    final List<int> genreIdsList = [];
    if (json['genre_ids'] != null) {
      final genreIdsRaw = json['genre_ids'] as List;
      for (var id in genreIdsRaw) {
        genreIdsList.add(id as int);
      }
    }

    return Movie(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Unknown Title',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      releaseDate: json['release_date'] as String? ?? 'N/A',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      cast: const [],
      genreIds: genreIdsList, // ✅ TAMBAHAN: Set genre IDs
      genres: null,
      isFavorite: isFavorite,
    );
  }

  // Factory constructor untuk detail film (termasuk cast dan genres lengkap)
  factory Movie.fromDetailJson(
    Map<String, dynamic> json,
    List<Cast> castList, {
    bool isFavorite = false,
  }) {
    // ✅ TAMBAHAN: Parse genres lengkap dari detail API
    List<Genre>? genresList;
    List<int> genreIdsList = [];

    if (json['genres'] != null) {
      final genresRaw = json['genres'] as List;
      genresList = genresRaw
          .map((g) => Genre.fromJson(g as Map<String, dynamic>))
          .toList();
      // Ambil juga IDs dari genres lengkap
      genreIdsList = genresList.map((g) => g.id).toList();
    }

    return Movie(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Unknown Title',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      releaseDate: json['release_date'] as String? ?? 'N/A',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      cast: castList,
      genreIds: genreIdsList, // ✅ TAMBAHAN: Set genre IDs
      genres: genresList, // ✅ TAMBAHAN: Set genres lengkap
      isFavorite: isFavorite,
    );
  }

  // ✅ TAMBAHAN: Helper method untuk mendapatkan nama genre
  List<String> getGenreNames(Map<int, String> genreMap) {
    final List<String> result = [];

    // Prioritas: gunakan genres lengkap jika ada (dari detail)
    if (genres != null && genres!.isNotEmpty) {
      for (var genre in genres!) {
        result.add(genre.name);
        if (result.length >= 2) break; // Maksimal 2 genre
      }
      return result;
    }

    // Fallback: gunakan genreIds dengan mapping (dari list)
    for (var id in genreIds) {
      if (genreMap.containsKey(id)) {
        result.add(genreMap[id]!);
        if (result.length >= 2) break; // Maksimal 2 genre
      }
    }

    return result;
  }
}

// Model untuk Data Pemain (Cast)
class Cast {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  Cast({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'] as int,
      name: json['name'] as String,
      character: json['character'] as String,
      profilePath: json['profile_path'] as String?,
    );
  }
}

// Model untuk Data Genre
class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'] as int, name: json['name'] as String);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Genre && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Model untuk Review Film
class Review {
  final String author;
  final String content;
  final String createdAt;
  final double? rating;

  Review({
    required this.author,
    required this.content,
    required this.createdAt,
    this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final authorDetails = json['author_details'] as Map<String, dynamic>?;
    final ratingValue = (authorDetails?['rating'] as num?)?.toDouble();

    return Review(
      author: json['author'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] as String,
      rating: ratingValue,
    );
  }
}

// ✅ BARU: Model untuk Video/Trailer
class MovieVideo {
  final String id;
  final String key; // YouTube video key
  final String name;
  final String site; // YouTube, Vimeo, etc
  final String type; // Trailer, Teaser, Clip, etc
  final bool official;
  final String publishedAt;

  MovieVideo({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.official,
    required this.publishedAt,
  });

  factory MovieVideo.fromJson(Map<String, dynamic> json) {
    return MovieVideo(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      site: json['site'] as String,
      type: json['type'] as String,
      official: json['official'] as bool? ?? false,
      publishedAt: json['published_at'] as String,
    );
  }

  // Helper untuk mendapatkan YouTube URL
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';

  // Helper untuk cek apakah YouTube
  bool get isYouTube => site.toLowerCase() == 'youtube';

  // Helper untuk cek apakah trailer
  bool get isTrailer => type.toLowerCase() == 'trailer';
}

// ✅ TAMBAHAN: Helper class untuk Genre Mapping (TMDb Standard Genre IDs)
class GenreHelper {
  static final Map<int, String> genreMap = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Sci-Fi',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };

  // Helper untuk mendapatkan nama genre dari ID
  static String getGenreName(int id) {
    return genreMap[id] ?? 'Unknown';
  }

  // Helper untuk mendapatkan beberapa nama genre dari list IDs
  static List<String> getGenreNames(List<int> ids, {int maxCount = 2}) {
    final List<String> names = [];
    for (var id in ids) {
      if (genreMap.containsKey(id)) {
        names.add(genreMap[id]!);
        if (names.length >= maxCount) break;
      }
    }
    return names;
  }
}
