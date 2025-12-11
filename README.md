# 🎬 Movie Explorer

A Flutter application that fetches real-time movie data from The Movie Database (TMDb) API. This project was developed as part of a mobile programming final project and demonstrates API integration, JSON parsing, simple state management, and asynchronous UI handling.

---

## ✨ Penjelasan Aplikasi

Movie Explorer adalah aplikasi mobile berbasis Flutter yang berfungsi untuk mengambil dan menampilkan data film dari API The Movie Database (TMDb) secara real-time. Aplikasi ini dibuat untuk memenuhi kebutuhan tugas akhir pemrograman mobile. Proyek ini mempraktikkan penggunaan API publik, parsing JSON, state management sederhana, dan penanganan UI berbasis asynchronous.

### 🚀 Fitur Utama

Pengguna dapat:
* Melihat daftar film Populer dan Trending saat ini.
* Menelusuri detail film lengkap (overview, cast, review, trailer).
* Mencari film berdasarkan judul.
* Memfilter film berdasarkan genre.
* Menyimpan film ke daftar Favorit (menggunakan Shared Preferences).

Aplikasi ini secara khusus menampilkan tiga kondisi UI penting: loading, sukses, dan error.

---

## 🔑 Endpoint API (TMDb)

Aplikasi ini memanfaatkan beberapa endpoint kunci dari TMDb API.

| Kategori | Endpoint Relatif | Fungsi |
| :--- | :--- | :--- |
| Populer | /discover/movie?sort_by=popularity.desc | Menampilkan film populer. |
| Trending | /trending/movie/week | Menampilkan film trending minggu ini. |
| Genre | /genre/movie/list | Mengambil daftar genre. |
| Filter Genre | /discover/movie?with_genres={id} | Menampilkan film berdasarkan genre. |
| Pencarian | /search/movie?query={query} | Mencari film berdasarkan judul. |
| Detail Film | /movie/{id} | Informasi detail film. |
| Cast | /movie/{id}/credits | Menampilkan pemeran. |
| Review | /movie/{id}/reviews | Menampilkan ulasan pengguna. |
| Trailer | /movie/{id}/videos | Trailer film (YouTube). |
| Rilis | /movie/{id}/release_dates | Informasi tanggal rilis. |

Semua request dilakukan menggunakan Dio dan hasil JSON dipetakan ke model Dart melalui factory constructor.

---

## 🛠️ Getting Started

Ikuti langkah-langkah berikut untuk menjalankan proyek:

### 1. Clone Repository
git clone <url-repo-anda>
cd movie_explorer

### 2. Install Dependency Flutter
flutter pub get

### 3. Tambahkan API Key TMDb
Letakkan kunci API TMDb Anda di file service (misalnya api_service.dart) atau gunakan .env jika disiapkan.

### 4. Jalankan Aplikasi
flutter run

### ⚠️ Syarat Tambahan
* Pastikan koneksi internet aktif.
* Gunakan Flutter versi terbaru agar kompatibel.

---

## 📂 Project Structure

Struktur proyek ditampilkan dalam format yang sesuai standar:

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

---

## 💻 Technologies Used

* Flutter
* Dart
* Dio (HTTP client)
* TMDb API
* Shared Preferences (penyimpanan favorit)

---

## 📸 Screenshots

Tambahkan screenshot ke folder screenshots/ di repository Anda untuk mendokumentasikan hasil implementasi:

* Tampilan Dashboard
* <img width="394" height="834" alt="Screenshot 2025-12-11 181038" src="https://github.com/user-attachments/assets/1d18f050-be86-4daf-9589-69580f4c9340" />
* Halaman Semua Film + Pencarian
* <img width="394" height="834" alt="Screenshot 2025-12-11 181123" src="https://github.com/user-attachments/assets/d9b8f3df-a7eb-451d-aca6-595a2517adf3" />
<img width="394" height="834" alt="Screenshot 2025-12-11 181141" src="https://github.com/user-attachments/assets/9386d8e5-1ea6-4951-9f2c-d283fe74523d" />
* Detail Film
* <img width="394" height="834" alt="Screenshot 2025-12-11 181240" src="https://github.com/user-attachments/assets/0783dca6-1158-43eb-bb82-e547b4d601de" />
<img width="394" height="834" alt="Screenshot 2025-12-11 181255" src="https://github.com/user-attachments/assets/7eb032ec-4ff2-4eb4-938e-c65ccdfd72dc" />
* Halaman Favorit
<img width="394" height="834" alt="Screenshot 2025-12-11 181450" src="https://github.com/user-attachments/assets/b598c24c-2c7f-48ed-a1ba-0ebf69473b75" />
* Contoh Loading State
* <img width="373" height="789" alt="Screenshot 2025-12-11 112338" src="https://github.com/user-attachments/assets/184a70e9-b8dc-49c3-a1d2-51a142308eed" />
* Contoh Error State
<img width="373" height="789" alt="Screenshot 2025-12-11 113821" src="https://github.com/user-attachments/assets/ca62a17f-ed3f-483b-8705-4774ffb109ef" />
---

## 📜 License

Project ini dibuat untuk keperluan tugas/ujian mata kuliah Pemrograman Mobile dan tidak digunakan untuk tujuan komersial.
