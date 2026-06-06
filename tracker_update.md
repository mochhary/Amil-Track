# 🚀 AMIL TRACK - MASTER ROADMAP & TRACKER (PRODUCTION LEVEL)

## 🤖 INSTRUKSI WAJIB UNTUK AI (BACA SEBELUM MEMULAI)

Sebagai AI Assistant (Senior Flutter Developer), Anda **DIWAJIBKAN** mematuhi aturan ketat berikut selama sesi coding:

1. **KERJAKAN SATU PER SATU:** Jangan pernah memberikan solusi untuk dua kotak centang `[ ]` sekaligus. Fokuslah pada satu sub-task, bedah secara mendalam dan berikan kodenya secara utuh, lalu tunggu _feedback_ atau konfirmasi "Lanjut" dari _user_.
2. **KODE UTUH & BERSTANDAR TINGGI:** Berikan kode lengkap beserta seluruh komponen _imports_ yang dibutuhkan. Hindari memotong kode menggunakan komentar seperti `// ... kode lainnya ...` agar tidak menimbulkan _bug_ atau kebingungan.
3. **PREMIUM UI/UX & HANDLING:** Pastikan setiap komponen visual mengimplementasikan desain modern (efek glassmorphism, sudut melengkung halus, gradasi warna estetik) serta dilengkapi dengan _error handling_ (`try-catch`) dan _null safety_.
4. **KONFIRMASI STATUS:** Setiap kali menyelesaikan tugas, tanyakan kepada _user_: _"Apakah kodenya berjalan lancar tanpa error merah? Jika ya, silakan centang [x] di tracker Anda dan kita lanjut ke tahap berikutnya."_

---

## ✅ FASE 1: Backend & Database Cloud (SELESAI)

_Fokus: Fondasi infrastruktur serverless menggunakan Supabase._

- [x] Inisialisasi Supabase Project (`Amil Track DB`).
- [x] Membuat tabel `settings` untuk menyimpan harga acuan zakat.
- [x] Membuat tabel `zakat_transactions` untuk menyimpan riwayat setoran.
- [x] Mengaktifkan Row Level Security (RLS) dengan _policy_ development.
- [x] Menyimpan _Publishable Key_ & _Project URL_ ke dalam _environment_.
- [x] Mengaktifkan _Google Sign-In Provider_ di dashboard Supabase menggunakan dummy ID.

## ✅ FASE 2: Inisialisasi Flutter & UI Dasar (SELESAI)

_Fokus: Setup awal framework dan pemisahan arsitektur._

- [x] Generate project dengan `flutter create amil_track`.
- [x] Menerapkan _Design Tokens_ (Skema Warna & Tipografi di `theme.dart`).
- [x] Memasang core _dependencies_ di `pubspec.yaml` (`supabase_flutter`, `google_sign_in`, `url_launcher`, `intl`).
- [x] Membangun arsitektur folder standar (`core/`, `screens/`, `services/`, `widgets/`).
- [x] Menyelesaikan integrasi otentikasi dasar (Auth Gate).

---

## ⏳ FASE 3: UI/UX Revamp & Premium Micro-Interactions (SELESAI)

_Fokus: Merombak visual kaku menjadi aplikasi premium yang modern, kekinian, interaktif, dan berkelas tinggi (Gaya iOS/Android Modern)._

- [x] **Dependencies Tambahan UI:** Memasang package `flutter_animate` (untuk animasi berantai) dan `tutorial_coach_mark` (untuk panduan/hint interaktif).
- [x] **Komponen Fondasi Glassmorphism:** Membuat reusable widget `GlassContainer`, `GlassAppBar`, dan `GlassModal` memanfaatkan `BackdropFilter` bawaan Flutter untuk efek kaca buram (_frosted glass_).
- [x] **Animasi Transisi Layar:** Mengonfigurasi efek _fade-in_, _slide-up_, dan _staggered animations_ saat aplikasi dibuka, masuk ke layar _Onboarding_, maupun saat berpindah ke _Dashboard_.
- [x] **Custom Premium Modals & Cards:** Mengganti seluruh `AlertDialog` standar dengan pop-up kustom berbasis efek kaca, sudut melengkung ekstrem (radius 24+), ikon animasi di tengah, serta tata letak tombol aksi yang interaktif.
- [x] **Walkthrough Hint Terpandu:** Mengimplementasikan _Step-by-step Tutorial_ otomatis saat user yang baru pertama kali mendaftar/masuk berhasil mendarat di halaman beranda (menyorot tombol tambah zakat, menu profil, dll).
- [x] **Alur Hapus Akun Berstandar Industri:** Merancang _Bottom Sheet_ konfirmasi bertingkat berwarna merah peringatan yang mewajibkan user mengetik kata kunci konfirmasi atau mencentang persetujuan sebelum memanggil fungsi _soft-delete_.

## ⏳ FASE 4: Skema Kategori Zakat & Arsitektur Offline-First (SELESAI)

_Fokus: Mengubah arsitektur agar sesuai standar akuntabilitas BAZNAS dan menjamin aplikasi tetap bekerja penuh di daerah tanpa internet._

- [x] **Dependencies Tambahan Data:** Memasang package `sqflite` (database lokal ponsel) dan `connectivity_plus` (detektor jaringan).
- [x] **Migrasi Skema Cloud:** Memperbarui tabel `zakat_transactions` di cloud Supabase dengan menambahkan kolom `kategori_zakat` (Fitrah, Maal, Profesi, Infaq) dan detail penunjang lainnya.
- [x] **Setup Database SQLite Lokal:** Merancang skema tabel `local_transactions` di dalam memori internal HP yang memuat kolom tambahan `sync_status` (pending/synced).
- [x] **Background Sync Engine:** Membangun fungsi sinkronisasi otomatis yang berjalan di latar belakang untuk mengunggah seluruh data berstatus _pending_ dari SQLite ke cloud Supabase begitu perangkat mendeteksi sinyal internet kembali stabil.

## ⏳ FASE 5: Kalkulator Zakat Otomatis (Standar BAZNAS) (SELESAI)

_Fokus: Memindahkan seluruh beban perhitungan matematika hukum zakat yang rumit dari otak amil ke dalam sistem algoritma pintar._

- [x] **Core Logic Calculator:** Membuat file kelas terisolasi `zakat_calculator.dart` di dalam folder `core/` atau `services/`.
- [x] **Algoritma Zakat Fitrah:** Mengunci rumus perhitungan berbasis makanan pokok (`Jumlah Jiwa x Besaran Nilai Kg x Harga Beras Lokal Acuan`).
- [x] **Algoritma Zakat Profesi (Penghasilan):** Menyusun logika pengecekan Nisab otomatis berdasarkan nilai konversi 85 gram emas per tahun (atau bulanan) beserta persentase kewajiban pengeluaran sebesar 2.5%.
- [x] **Algoritma Zakat Maal (Harta Simpanan):** Menyusun logika validasi syarat Haul (minimal mengendap 1 tahun) pada aset harta/tabungan dan perhitungan tarif wajib zakat 2.5%.

## ⏳ FASE 6: Dynamic UI Slicing & Integrasi Kalkulator

_Fokus: Menyatukan keindahan visual premium (Fase 3) dengan kecerdasan algoritma perhitungan (Fase 5)._

- [x] **Dashboard Grid Menu:** Mengubah total halaman beranda menjadi bentuk _Grid Menu_ interaktif berbasis ikon modern kustom untuk setiap kategori zakat, lengkap dengan ringkasan visual total perolehan di sisi atas.
- [x] **Smart Form Transaction:** Membuat formulir input dinamis yang komponen kolomnya berubah secara otomatis menyesuaikan jenis menu zakat yang diklik oleh amil (misalnya: memilih Zakat Profesi otomatis hanya menampilkan input kolom "Gaji Bulanan" & "Bonus").
- [x] **Real-time Input Feedback:** Menampilkan _floating badge_ indah secara _live_ saat amil sedang mengetik angka di form, memberikan teks hijau berkilau _"Wajib Zakat: Rp X"_ jika mencapai nisab, atau teks merah lembut _"Belum Mencapai Nisab, Sarankan Sedekah"_ jika di bawah batas limit.

## ⏳ FASE 7: Sistem Pelaporan & Ekspor PDF Resmi

_Fokus: Memenuhi kebutuhan administratif penyerahan laporan pertanggungjawaban fisik bagi DKM Masjid maupun BAZNAS daerah._

- [x] **Dependencies Tambahan Dokumen:** Memasang package `pdf` dan `printing` ke dalam proyek.
- [x] **Native PDF Layout Design:** Merancang struktur tata letak dokumen cetak secara estetis (menyertakan logo resmi Amil Track, header nama masjid, garis pembatas formal, dan tabel data transaksi tabular yang rapi).
- [x] **Fitur Filter & Kategori Cetak:** Membangun antarmuka penyaringan data berdasarkan rentang tanggal kalender atau klasifikasi rumpun kategori zakat sebelum berkas PDF diekspor.
- [x] **Share & Print Integration:** Menyediakan modul _preview_ instan, fitur cetak langsung via jaringan (Printer Bluetooth/WiFi), serta tombol bagikan (_share_) dokumen ke platform lain.

## ⏳ FASE 8: Automasi Struk Kwitansi WhatsApp

_Fokus: Menghadirkan pengalaman pelayanan yang instan dan profesional bagi pembayar zakat melalui bukti terima digital._

- [x] **Rich Text Template Builder:** Menyusun fungsi _string generator_ yang merangkai pesan kwitansi secara elegan dan rapi menggunakan penataan spasi, format mata uang Rupiah, penanggalan yang sahih, serta penggunaan emoji yang ramah.
- [x] **Deep Linking Launcher:** Mengintegrasikan skema pengiriman URL aman `wa.me/628xxx?text=...` memanfaatkan package `url_launcher` agar langsung membuka aplikasi WhatsApp tujuan dengan pesan struk yang otomatis terisi rapi tinggal tekan kirim.
- [x] **Robust Error Handling:** Menyediakan mekanisme deteksi kegagalan sistem, seperti memunculkan pesan peringatan kustom (_SnackBar/Modal_) jika format nomor HP muzakki tidak valid atau aplikasi WhatsApp tidak terpasang di ponsel amil.

## ⏳ FASE 9: Final Polish & Persiapan Rilis Publik

_Fokus: Standardisasi dan optimalisasi performa menyeluruh agar aplikasi lulus sensor saat diunggah ulang ke Google Play Store._

- [x] **App Icon & Branding Native:** Mengonfigurasi package `flutter_launcher_icons` untuk memasang aset logo resmi Amil Track secara otomatis di seluruh level sistem operasi (Android & iOS).
- [x] **Native Splash Screen Engine:** Mengonfigurasi package `flutter_native_splash` untuk membuang tampilan layar putih hampa saat aplikasi pertama kali dimuat di ponsel pengguna.
- [x] **Code Analysis & Linting Audit:** Menjalankan perintah analisis ketat `flutter analyze` untuk membersihkan seluruh sisa kode _warning_, _unused imports_, ataupun _deprecated code_.
- [x] **Production Optimization:** Mematikan _debug banner_ pojok kanan atas, menguji kestabilan memori dari kebocoran (_memory leak_), serta melakukan kompilasi rilis akhir menggunakan target _bundle_ yang optimal.

## ⏳ FASE 10: Optimasi Performa & Arsitektur Lanjutan (Tech Debt)

_Fokus: Mengatasi potensi kerapuhan sistem (vulnerabilities) dan meningkatkan efisiensi agar aplikasi siap untuk skala pengguna masif._

- [x] **Perbaikan Kerapuhan Visual (UI Responsiveness):** Mengganti angka _hardcoded_ (magic numbers) pada `_CustomLiquidNotchClipper` dan titik absolut penempatan elemen melayang (seperti FAB) dengan perhitungan matematis dinamis menggunakan `MediaQuery` atau `LayoutBuilder` agar UI tetap presisi di berbagai ukuran dan rasio layar (termasuk tablet).
- [x] **Optimasi Efisiensi Query Database:** Melakukan refactoring pada fungsi `_loadDashboardData` yang saat ini menjalankan 7 query SQLite secara berurutan. Menggabungkan eksekusi menggunakan metode paralel `Future.wait([])` atau menyatukannya ke dalam satu agregasi query SQL kompleks untuk mencegah pelambatan performa (bottleneck) saat jumlah data transaksi mencapai ribuan.
- [x] **Pemantauan Jaringan Efisien (Network Checking):** Mengganti metode `Timer.periodic` dan `InternetAddress.lookup` yang terus-menerus berjalan dan memakan daya baterai dengan _package_ `connectivity_plus`. Pendekatan _event-driven_ ini akan memantau perubahan status koneksi perangkat secara pasif tanpa harus membebani _thread_ aplikasi.
- [x] **Walkthrough ilang:**
- [x] **Initial Cloud Pull (Two-Way Sync):** Membangun fungsi penyedot data awal yang otomatis mengunduh riwayat transaksi dari Supabase ke dalam SQLite lokal saat amil baru pertama kali login di perangkat baru.

---

## ⏳ FASE 11: Arsitektur Reaktif Dasar (Riverpod Integrasi Aman)

_Fokus: Mengganti `setState` dengan Riverpod secara perlahan tanpa mengubah logika otentikasi (AuthService) maupun kredensial yang sudah terbukti berjalan lancar._

- [x] **11.1 Instalasi & Setup ProviderScope:** Memasang _package_ `flutter_riverpod` dan membungkus `MyApp` di `main.dart` tanpa menyentuh inisialisasi Supabase yang sudah ada di `core/constants.dart`.
- [x] **11.2 Global Auth Provider:** Membuat `auth_provider.dart` murni untuk memantau status sesi pengguna saat ini, tanpa mengubah fungsi `signInWithOAuth` di `AuthService`.
- [x] **11.3 Migrasi AuthGate:** Mengubah `AuthGate` di `main.dart` dari `StatefulWidget`/konvensional menjadi `ConsumerWidget` yang reaktif mendengarkan `auth_provider.dart`.

## ⏳ FASE 12: Pemotongan UI (Slicing) & Riverpod Lanjutan

_Fokus: Membedah file UI yang terlalu bengkak (seperti `home_screen.dart`) menjadi komponen kecil yang menggunakan Riverpod untuk mengambil datanya masing-masing._

- [x] **12.1 Ekstraksi Logika Dashboard:** Membuat `dashboard_provider.dart` untuk memindahkan fungsi-fungsi berat (seperti mengambil total uang/beras dari SQLite) keluar dari UI.
- [x] **12.2 Slicing Home Screen (Bagian Atas):** Memecah bagian _header_ dan _hero card_ (Kalkulator Zakat) menjadi _widget_ terpisah di dalam folder `widgets/`.
- [x] **12.3 Slicing Home Screen (Bagian Bawah):** Memecah _Grid Menu_ dan _Recent Activity_ menjadi komponen mandiri agar `home_screen.dart` menjadi sangat ringkas dan mudah dibaca.
- [x] **12.4 Slicing Home Screen (Tab Profile):**
- [x] **12.5 Slicing Transaction List:**
- [x] **12.6 Slicing Transaction Form:**
- [x] **12.7 Refactoring Enterprise (Part 1):** Membuat `dialog_utils.dart` dan merombak `dashboard_provider.dart` untuk _caching_ Riverpod.
- [x] **12.8 Integrasi Riverpod di Beranda:** Mengubah `HomeScreen` menjadi `ConsumerStatefulWidget` dan menggunakan `localDashboardProvider` untuk memuat data tanpa `setState`.
- [x] **12.9 Implementasi Pusat Utilitas:** Memperbarui `action_grid.dart` dan `profile_tab_content.dart` agar menggunakan fungsi dari `DialogUtils` secara terpusat.
- [x] **12.10 Refactor List Provider:** Ekstraksi filter & pencarian ke `TransactionListProvider`.
- [x] **12.11 Refactor Form Provider:** Ekstraksi kalkulator zakat ke `ZakatCalculatorProvider`.
- [x] **12.12 Keamanan Database (Security):** Obfuscation & abstraction layer untuk schema SQL.
- [ ] **12.13 Lingkungan Aman:** Implementasi `.env` & `flutter_dotenv` untuk menyembunyikan API/URL.
- [ ] **12.14 Logika WA Dinamis:** Validasi nomor telepon Muzakki & kondisional tombol kirim struk.
- [ ] **12.15 Optimasi Performa:** Implementasi `const` & `final` secara menyeluruh & perbaikan _memory leaks_.

## ⏳ FASE 13: Isolasi Data Pengguna (Multi-Tenancy Skala Enterprise)

_Fokus: Memastikan privasi dan keamanan data; Amil A tidak boleh bisa melihat, mengedit, atau menyinkronkan data transaksi milik Amil B._

- [ ] **13.1 Modifikasi Skema SQLite Lokal:** Melakukan migrasi database di `sqlite_service.dart` untuk menambahkan kolom krusial `user_id` pada setiap baris transaksi yang dicatat.
- [ ] **13.2 Filter Query & Restrukturisasi Auto-Sync:** Mengubah logika agregasi _dashboard_ dan otak sinkronisasi (`sync_service.dart`) agar selalu mengunci data pada `WHERE user_id = current_user_id`.

## ⏳ FASE 14: Keamanan Tingkat Lanjut & Native Login (Fase Ekspansi)

_Fokus: Menerapkan keamanan tingkat rilis (Production) HANYA SETELAH seluruh UI dan State Management berjalan sempurna 100%._

- [ ] **14.1 Isolasi API Key (.env):** Memasang package `flutter_dotenv` untuk menyembunyikan URL Supabase dan memindahkannya dari `constants.dart` dengan aman.
- [ ] **14.2 Migrasi ke Native Google Sign-In:** Mengganti metode _browser_ Supabase menjadi _pop-up_ asli bawaan Android menggunakan Web Client ID (Dilakukan perlahan sambil memantau log _error_ native).

## 📝 FASE 15: Catatan Analisis Lanjutan (Deferred Backlog)

_Fokus: Menyimpan catatan teknis hasil audit mendalam sebagai langkah berikutnya, namun belum menjadi target eksekusi fase aktif saat ini._

- [ ] **15.1 Sinkronisasi Filter Tanggal List:** Menghubungkan `dateRange` pada UI riwayat transaksi ke logika `filteredTransactionsProvider` agar penyaringan tanggal benar-benar aktif di data.
- [ ] **15.2 Konsistensi Alur WhatsApp Struk:** Menyelaraskan parameter nama/nomor pada `TransactionItemCard` dan `TransactionListScreen`, serta fallback kolom nomor (`nomor_whatsapp` / `phone`) agar validasi tombol kirim struk akurat.
- [ ] **15.3 Persistensi Edit Profil ke Cloud:** Memastikan perubahan nama profil dari tab profil tidak hanya `setState` lokal, tetapi juga tersimpan ke Supabase metadata (`username`) dan otomatis sinkron ke sesi berjalan.
- [ ] **15.4 Migrasi SQLite Tanpa Drop Table:** Refactor strategi `onUpgrade` database agar migrasi skema (mis. tambah kolom) tidak menghapus seluruh data lokal pengguna.
- [ ] **15.5 Perbaikan tampilan Hero modal dan FAB:** Angka pada modal jadi tidak terlihat jelas karena terlalu banyak, harusnya jika banyak seperti itu hero bisa diklik untuk melihat detail uangnya secara jelas. dan juga FAB tampilannya kurang estetik karena terlalu jatuh dalam lekukan hapus saja lekukannya agar tetap estetik
