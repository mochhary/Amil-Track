# 🚀 AMIL TRACK - MASTER ROADMAP & TRACKER (PRODUCTION LEVEL)

## 🤖 INSTRUKSI WAJIB UNTUK AI (BACA SEBELUM MEMULAI)
Sebagai AI Assistant (Senior Flutter Developer), Anda **DIWAJIBKAN** mematuhi aturan ketat berikut selama sesi coding:
1. **KERJAKAN SATU PER SATU:** Jangan pernah memberikan solusi untuk dua kotak centang `[ ]` sekaligus. Fokuslah pada satu sub-task, bedah secara mendalam dan berikan kodenya secara utuh, lalu tunggu *feedback* atau konfirmasi "Lanjut" dari *user*.
2. **KODE UTUH & BERSTANDAR TINGGI:** Berikan kode lengkap beserta seluruh komponen *imports* yang dibutuhkan. Hindari memotong kode menggunakan komentar seperti `// ... kode lainnya ...` agar tidak menimbulkan *bug* atau kebingungan.
3. **PREMIUM UI/UX & HANDLING:** Pastikan setiap komponen visual mengimplementasikan desain modern (efek glassmorphism, sudut melengkung halus, gradasi warna estetik) serta dilengkapi dengan *error handling* (`try-catch`) dan *null safety*.
4. **KONFIRMASI STATUS:** Setiap kali menyelesaikan tugas, tanyakan kepada *user*: *"Apakah kodenya berjalan lancar tanpa error merah? Jika ya, silakan centang [x] di tracker Anda dan kita lanjut ke tahap berikutnya."*

---

## ✅ FASE 1: Backend & Database Cloud (SELESAI)
*Fokus: Fondasi infrastruktur serverless menggunakan Supabase.*
- [x] Inisialisasi Supabase Project (`Amil Track DB`).
- [x] Membuat tabel `settings` untuk menyimpan harga acuan zakat.
- [x] Membuat tabel `zakat_transactions` untuk menyimpan riwayat setoran.
- [x] Mengaktifkan Row Level Security (RLS) dengan *policy* development.
- [x] Menyimpan *Publishable Key* & *Project URL* ke dalam *environment*.
- [x] Mengaktifkan *Google Sign-In Provider* di dashboard Supabase menggunakan dummy ID.

## ✅ FASE 2: Inisialisasi Flutter & UI Dasar (SELESAI)
*Fokus: Setup awal framework dan pemisahan arsitektur.*
- [x] Generate project dengan `flutter create amil_track`.
- [x] Menerapkan *Design Tokens* (Skema Warna & Tipografi di `theme.dart`).
- [x] Memasang core *dependencies* di `pubspec.yaml` (`supabase_flutter`, `google_sign_in`, `url_launcher`, `intl`).
- [x] Membangun arsitektur folder standar (`core/`, `screens/`, `services/`, `widgets/`).
- [x] Menyelesaikan integrasi otentikasi dasar (Auth Gate).

---

## ⏳ FASE 3: UI/UX Revamp & Premium Micro-Interactions
*Fokus: Merombak visual kaku menjadi aplikasi premium yang modern, kekinian, interaktif, dan berkelas tinggi (Gaya iOS/Android Modern).*
- [ ] **Dependencies Tambahan UI:** Memasang package `flutter_animate` (untuk animasi berantai) dan `tutorial_coach_mark` (untuk panduan/hint interaktif).
- [ ] **Komponen Fondasi Glassmorphism:** Membuat reusable widget `GlassContainer`, `GlassAppBar`, dan `GlassModal` memanfaatkan `BackdropFilter` bawaan Flutter untuk efek kaca buram (*frosted glass*).
- [ ] **Animasi Transisi Layar:** Mengonfigurasi efek *fade-in*, *slide-up*, dan *staggered animations* saat aplikasi dibuka, masuk ke layar *Onboarding*, maupun saat berpindah ke *Dashboard*.
- [ ] **Custom Premium Modals & Cards:** Mengganti seluruh `AlertDialog` standar dengan pop-up kustom berbasis efek kaca, sudut melengkung ekstrem (radius 24+), ikon animasi di tengah, serta tata letak tombol aksi yang interaktif.
- [ ] **Walkthrough Hint Terpandu:** Mengimplementasikan *Step-by-step Tutorial* otomatis saat user yang baru pertama kali mendaftar/masuk berhasil mendarat di halaman beranda (menyorot tombol tambah zakat, menu profil, dll).
- [ ] **Alur Hapus Akun Berstandar Industri:** Merancang *Bottom Sheet* konfirmasi bertingkat berwarna merah peringatan yang mewajibkan user mengetik kata kunci konfirmasi atau mencentang persetujuan sebelum memanggil fungsi *soft-delete*.

## ⏳ FASE 4: Skema Kategori Zakat & Arsitektur Offline-First
*Fokus: Mengubah arsitektur agar sesuai standar akuntabilitas BAZNAS dan menjamin aplikasi tetap bekerja penuh di daerah tanpa internet.*
- [ ] **Dependencies Tambahan Data:** Memasang package `sqflite` (database lokal ponsel) dan `connectivity_plus` (detektor jaringan).
- [ ] **Migrasi Skema Cloud:** Memperbarui tabel `zakat_transactions` di cloud Supabase dengan menambahkan kolom `kategori_zakat` (Fitrah, Maal, Profesi, Infaq) dan detail penunjang lainnya.
- [ ] **Setup Database SQLite Lokal:** Merancang skema tabel `local_transactions` di dalam memori internal HP yang memuat kolom tambahan `sync_status` (pending/synced).
- [ ] **Background Sync Engine:** Membangun fungsi sinkronisasi otomatis yang berjalan di latar belakang untuk mengunggah seluruh data berstatus *pending* dari SQLite ke cloud Supabase begitu perangkat mendeteksi sinyal internet kembali stabil.

## ⏳ FASE 5: Kalkulator Zakat Otomatis (Standar BAZNAS)
*Fokus: Memindahkan seluruh beban perhitungan matematika hukum zakat yang rumit dari otak amil ke dalam sistem algoritma pintar.*
- [ ] **Core Logic Calculator:** Membuat file kelas terisolasi `zakat_calculator.dart` di dalam folder `core/` atau `services/`.
- [ ] **Algoritma Zakat Fitrah:** Mengunci rumus perhitungan berbasis makanan pokok (`Jumlah Jiwa x Besaran Nilai Kg x Harga Beras Lokal Acuan`).
- [ ] **Algoritma Zakat Profesi (Penghasilan):** Menyusun logika pengecekan Nisab otomatis berdasarkan nilai konversi 85 gram emas per tahun (atau bulanan) beserta persentase kewajiban pengeluaran sebesar 2.5%.
- [ ] **Algoritma Zakat Maal (Harta Simpanan):** Menyusun logika validasi syarat Haul (minimal mengendap 1 tahun) pada aset harta/tabungan dan perhitungan tarif wajib zakat 2.5%.

## ⏳ FASE 6: Dynamic UI Slicing & Integrasi Kalkulator
*Fokus: Menyatukan keindahan visual premium (Fase 3) dengan kecerdasan algoritma perhitungan (Fase 5).*
- [ ] **Dashboard Grid Menu:** Mengubah total halaman beranda menjadi bentuk *Grid Menu* interaktif berbasis ikon modern kustom untuk setiap kategori zakat, lengkap dengan ringkasan visual total perolehan di sisi atas.
- [ ] **Smart Form Transaction:** Membuat formulir input dinamis yang komponen kolomnya berubah secara otomatis menyesuaikan jenis menu zakat yang diklik oleh amil (misalnya: memilih Zakat Profesi otomatis hanya menampilkan input kolom "Gaji Bulanan" & "Bonus").
- [ ] **Real-time Input Feedback:** Menampilkan *floating badge* indah secara *live* saat amil sedang mengetik angka di form, memberikan teks hijau berkilau *"Wajib Zakat: Rp X"* jika mencapai nisab, atau teks merah lembut *"Belum Mencapai Nisab, Sarankan Sedekah"* jika di bawah batas limit.

## ⏳ FASE 7: Sistem Pelaporan & Ekspor PDF Resmi
*Fokus: Memenuhi kebutuhan administratif penyerahan laporan pertanggungjawaban fisik bagi DKM Masjid maupun BAZNAS daerah.*
- [ ] **Dependencies Tambahan Dokumen:** Memasang package `pdf` dan `printing` ke dalam proyek.
- [ ] **Native PDF Layout Design:** Merancang struktur tata letak dokumen cetak secara estetis (menyertakan logo resmi Amil Track, header nama masjid, garis pembatas formal, dan tabel data transaksi tabular yang rapi).
- [ ] **Fitur Filter & Kategori Cetak:** Membangun antarmuka penyaringan data berdasarkan rentang tanggal kalender atau klasifikasi rumpun kategori zakat sebelum berkas PDF diekspor.
- [ ] **Share & Print Integration:** Menyediakan modul *preview* instan, fitur cetak langsung via jaringan (Printer Bluetooth/WiFi), serta tombol bagikan (*share*) dokumen ke platform lain.

## ⏳ FASE 8: Automasi Struk Kwitansi WhatsApp
*Fokus: Menghadirkan pengalaman pelayanan yang instan dan profesional bagi pembayar zakat melalui bukti terima digital.*
- [ ] **Rich Text Template Builder:** Menyusun fungsi *string generator* yang merangkai pesan kwitansi secara elegan dan rapi menggunakan penataan spasi, format mata uang Rupiah, penanggalan yang sahih, serta penggunaan emoji yang ramah.
- [ ] **Deep Linking Launcher:** Mengintegrasikan skema pengiriman URL aman `wa.me/628xxx?text=...` memanfaatkan package `url_launcher` agar langsung membuka aplikasi WhatsApp tujuan dengan pesan struk yang otomatis terisi rapi tinggal tekan kirim.
- [ ] **Robust Error Handling:** Menyediakan mekanisme deteksi kegagalan sistem, seperti memunculkan pesan peringatan kustom (*SnackBar/Modal*) jika format nomor HP muzakki tidak valid atau aplikasi WhatsApp tidak terpasang di ponsel amil.

## ⏳ FASE 9: Final Polish & Persiapan Rilis Publik
*Fokus: Standardisasi dan optimalisasi performa menyeluruh agar aplikasi lulus sensor saat diunggah ulang ke Google Play Store.*
- [ ] **App Icon & Branding Native:** Mengonfigurasi package `flutter_launcher_icons` untuk memasang aset logo resmi Amil Track secara otomatis di seluruh level sistem operasi (Android & iOS).
- [ ] **Native Splash Screen Engine:** Mengonfigurasi package `flutter_native_splash` untuk membuang tampilan layar putih hampa saat aplikasi pertama kali dimuat di ponsel pengguna.
- [ ] **Code Analysis & Linting Audit:** Menjalankan perintah analisis ketat `flutter analyze` untuk membersihkan seluruh sisa kode *warning*, *unused imports*, ataupun *deprecated code*.
- [ ] **Production Optimization:** Mematikan *debug banner* pojok kanan atas, menguji kestabilan memori dari kebocoran (*memory leak*), serta melakukan kompilasi rilis akhir menggunakan target *bundle* yang optimal.