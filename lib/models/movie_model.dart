// Model untuk menampung data dari setiap film dan pemain (Cast) yang diterima dari API TMDb.

class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final double voteAverage;
  final List<Cast> cast;

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
    this.isFavorite = false, // Default false
  });

  // Factory constructor untuk membuat instance Movie dari JSON (Map)
  factory Movie.fromJson(Map<String, dynamic> json, {bool isFavorite = false}) {
    return Movie(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String,
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? 'N/A',
      voteAverage: (json['vote_average'] as num).toDouble(),
      cast: const [],
      isFavorite: isFavorite, // Set status favorit
    );
  }

  // Factory constructor untuk detail film (termasuk cast jika ada)
  factory Movie.fromDetailJson(
    Map<String, dynamic> json,
    List<Cast> castList, {
    bool isFavorite = false,
  }) {
    return Movie(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String,
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? 'N/A',
      voteAverage: (json['vote_average'] as num).toDouble(),
      cast: castList,
      isFavorite: isFavorite, // Set status favorit
    );
  }
}

// Model untuk Data Pemain (Cast)
class Cast {
  final int id;
  final String name;
  final String character;
  final String? profilePath; // path bisa null

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
}

// Model untuk Review Film
class Review {
  final String author;
  final String content;
  final String createdAt;
  final double? rating; // Rating bisa null

  Review({
    required this.author,
    required this.content,
    required this.createdAt,
    this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final authorDetails = json['author_details'] as Map<String, dynamic>?;

    // TMDb API menyimpan rating di dalam author_details
    final ratingValue = (authorDetails?['rating'] as num?)?.toDouble();

    return Review(
      author: json['author'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] as String,
      rating: ratingValue,
    );
  }
}
