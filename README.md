# Komputasi-Mobile

Project ini dikembangkan menggunakan pendekatan **MVC (Model - View - Controller)** agar struktur kode lebih terorganisir, mudah dibaca, dan mudah dikembangkan secara kolaboratif.

## Struktur Folder

```plaintext
lib/
├── controllers/          # Logika dan state management (Controller)
│   ├── laporan_controller.dart
│   ├── auth_controller.dart
│   └── ...
│
├── models/               # Representasi data dan business logic (Model)
│   ├── laporan.dart      # Class model untuk laporan
│   ├── user.dart         # Class model untuk user
│   └── ...
│
├── services/             # Logika interaksi dengan Supabase (data layer)
│   ├── supabase_service.dart
│   ├── auth_api.dart
│   └── ...
│
├── views/                # Antarmuka pengguna (UI) aplikasi (View)
│   ├── auth/
│   │   ├── login_page.dart
│   │   └── register_page.dart
│   ├── laporan/
│   │   ├── laporan_form_page.dart
│   │   ├── laporan_detail_page.dart
│   │   └── laporan_list_page.dart
│   └── shared/           # Widgets yang bisa dipakai ulang (Shared View)
│       └── custom_button.dart
│
└── main.dart



## Penjelasan Pendekatan

- **Model:** Berisi representasi data dan business logic aplikasi.
- **View:** Berisi komponen UI yang ditampilkan ke pengguna.
- **Controller:** Berfungsi sebagai penghubung antara View dan Model, menangani state dan logika aplikasi.
- **Service:** Layer tambahan untuk menangani komunikasi dengan backend (Supabase) dan API lainnya.
- **Shared View:** Komponen atau widget UI yang digunakan ulang di berbagai bagian aplikasi.

Struktur ini dibuat untuk mendukung pengembangan aplikasi yang skalabel, modular, dan mudah dikelola oleh banyak developer.
