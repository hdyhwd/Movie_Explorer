📘 Movie Explorer — README

1. Penjelasan Aplikasi

Movie Explorer adalah aplikasi mobile berbasis Flutter yang menampilkan data film dari API The Movie Database (TMDb). Aplikasi ini dibuat untuk mempraktekkan penggunaan API publik, manajemen state sederhana, parsing JSON, dan pengelolaan UI asinkron.

Pengguna dapat:

Melihat daftar film populer dan trending

Melihat detail film (overview, cast, review, trailer)

Mencari film berdasarkan judul

Memfilter film berdasarkan genre

Menambahkan film ke daftar favorit

Aplikasi menampilkan tiga kondisi UI penting: loading, sukses, dan error.

2. Daftar Endpoint API (TMDb)

Aplikasi menggunakan beberapa endpoint publik dari TMDb. Berikut daftar lengkapnya:

Kategori

Endpoint

Fungsi

Populer

/discover/movie?sort_by=popularity.desc

Menampilkan film populer

Trending

/trending/movie/week

Menampilkan film trending minggu ini

Genre

/genre/movie/list

Mengambil daftar genre

Filter Genre

/discover/movie?with_genres={id}

Menampilkan film berdasarkan genre

Pencarian

/search/movie?query={query}

Mencari film berdasarkan judul

Detail Film

/movie/{id}

Informasi detail film

Cast

/movie/{id}/credits

Menampilkan pemeran

Review

/movie/{id}/reviews

Menampilkan ulasan pengguna

Trailer

/movie/{id}/videos

Trailer film (YouTube)

Rilis

/movie/{id}/release_dates

Informasi tanggal rilis

Semua request dilakukan menggunakan Dio dan hasil JSON dipetakan ke model Dart melalui factory constructor.

3. Cara Instalasi

Ikuti langkah berikut untuk menjalankan project:

3.1 Clone Repository

git clone <url-repo>
cd movie_explorer

3.2 Install Dependency Flutter

flutter pub get

3.3 Tambahkan API Key TMDb

Letakkan di file service (api_service.dart) atau gunakan .env jika disiapkan.

3.4 Jalankan Aplikasi

flutter run

3.5 Syarat Tambahan

Pastikan koneksi internet aktif

Gunakan Flutter versi terbaru agar kompatibel

4. Struktur Folder (Ringkas)

lib/
 ├─ models/
 │   └─ movie_model.dart
 ├─ services/
 │   └─ api_service.dart
 ├─ screens/
 │   ├─ dashboard_screen.dart
 │   ├─ all_movies_screen.dart
 │   ├─ movie_detail_screen.dart
 │   └─ favorite_screen.dart
 └─ widgets/
     └─ movie_card.dart

5. Teknologi yang Digunakan

Flutter

Dart

Dio (HTTP client)

TMDb API

Shared Preferences (penyimpanan favorit)

6. Screenshot Aplikasi

Tambahkan beberapa gambar untuk menunjukkan hasil implementasi:

Tampilan Dashboard

Halaman Semua Film + Pencarian

Detail Film (overview, cast, review, trailer)

Halaman Favorit

Contoh Loading State

Contoh Error State

7. Lisensi

Project ini dibuat untuk keperluan tugas/ujian dan tidak digunakan untuk tujuan komersial.

