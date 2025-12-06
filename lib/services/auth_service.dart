// // Layanan yang menangani logika otentikasi (simulasi)
// import '../utils/preferences_helper.dart';

// class AuthService {
//   // --- SIMULASI LOGIN/REGISTER ---
//   // TMDb API login aslinya memerlukan 3 langkah (Request Token, Validate Token, Session ID).
//   // Untuk flow aplikasi ini, kita simulasikan berhasil jika input tidak kosong.

//   Future<bool> login(String username, String password) async {
//     // Simulasi: Cek apakah input valid
//     if (username.isNotEmpty && password.isNotEmpty && password.length >= 4) {
//       await PreferencesHelper.setLoggedIn(true);
//       return true; // Login sukses
//     }
//     return false; // Login gagal
//   }

//   Future<bool> register(String username, String email, String password) async {
//     // Simulasi: TMDb tidak punya API Register, tapi kita simulasikan proses di sini
//     if (username.isNotEmpty && email.isNotEmpty && password.length >= 6) {
//       // Dalam kasus nyata, ini akan mengirim data ke server backend Anda
//       return true; // Register sukses (pengguna dapat melanjutkan ke Login)
//     }
//     return false; // Register gagal
//   }

//   Future<void> logout() async {
//     // Menghapus status login dari penyimpanan
//     await PreferencesHelper.setLoggedIn(false);
//   }

//   Future<bool> checkLoginStatus() async {
//     // Memeriksa status login saat aplikasi dimulai
//     return PreferencesHelper.isLoggedIn();
//   }
// }
