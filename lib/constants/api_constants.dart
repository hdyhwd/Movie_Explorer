class ApiConstants {
  // API Key (v3 auth) - Digunakan sebagai query parameter untuk request publik
  static const String apiKey = '6f20bc190e0d43c3f0717dde5bab1ac9';

  // API Read Access Token (v4 auth) - Bisa digunakan di header Authorization
  static const String accessTokenV4 =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI2ZjIwYmMxOTBlMGQ0M2MzZjA3MTdkZGU1YmFiMWFjOSIsIm5iZiI6MTc2Mzk5NTYwNS45MzEsInN1YiI6IjY5MjQ2ZmQ1YmIzMGY3MGFlMDc2OTJkMyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.L5IyjEmNpHmxloY774uoC4iR3nQ-743pwgt6dV23CZ4';

  // Base URL untuk semua request API
  static const String baseUrl = 'https://api.themoviedb.org/3';

  // Base URL untuk mendapatkan gambar film (ukuran w500)
  static const String baseImageUrl = 'https://image.tmdb.org/t/p/w500';
}
