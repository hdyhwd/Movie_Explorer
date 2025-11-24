// Helper untuk mengelola penyimpanan data sederhana (status login, favorit) menggunakan shared_preferences.

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _isLoggedInKey = 'isLoggedIn';
  // Key untuk menyimpan daftar ID film favorit
  static const String _favoriteMoviesKey = 'favoriteMovieIds';

  // Menyimpan status login
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  // Mendapatkan status login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Mendapatkan daftar ID film favorit
  static Future<List<int>> getFavoriteMovieIds() async {
    final prefs = await SharedPreferences.getInstance();
    // SharedPreferences hanya bisa menyimpan String List, jadi kita konversi ke Int
    final stringIds = prefs.getStringList(_favoriteMoviesKey) ?? [];
    return stringIds
        .map((s) => int.tryParse(s) ?? 0)
        .where((id) => id != 0)
        .toList();
  }

  // Menyimpan daftar ID film favorit
  static Future<void> setFavoriteMovieIds(List<int> movieIds) async {
    final prefs = await SharedPreferences.getInstance();
    final stringIds = movieIds.map((id) => id.toString()).toList();
    await prefs.setStringList(_favoriteMoviesKey, stringIds);
  }

  // Toggle (tambah/hapus) status favorit
  static Future<bool> toggleFavorite(int movieId) async {
    final currentIds = await getFavoriteMovieIds();
    bool isAdding;

    if (currentIds.contains(movieId)) {
      // Hapus dari favorit
      currentIds.remove(movieId);
      isAdding = false;
    } else {
      // Tambah ke favorit
      currentIds.add(movieId);
      isAdding = true;
    }

    await setFavoriteMovieIds(currentIds);
    return isAdding;
  }
}
