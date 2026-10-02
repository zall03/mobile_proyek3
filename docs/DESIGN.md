# Dapur Cerdas — Blueprint Desain

Dokumen ini adalah sumber kebenaran arsitektur aplikasi Dapur Cerdas. Seluruh fitur baru harus
konsisten dengan keputusan di sini. Ubah dokumen ini saat arsitektur berubah, bukan sebaliknya.

## 1. Ringkasan Produk

Aplikasi mobile berbasis AI untuk mengelola stok bahan makanan rumah tangga dan menghasilkan
rekomendasi resep bergizi berdasarkan bahan yang tersedia. Target utama adalah orang tua (bunda)
yang ingin memantau asupan gizi anak (tema pencegahan stunting).

### Nilai utama
- Stok makanan tercatat (jenis, jumlah, kategori, tanggal kedaluwarsa).
- Bahan yang hampir kedaluwarsa terdeteksi lebih awal.
- Rekomendasi resep dari bahan yang tersedia (manual lalu AI).
- Estimasi kandungan nutrisi resep dibandingkan dengan target gizi anak (AKG).

## 2. Persona

Primer: **Bunda** — pembeli dan pengelola stok rumah tangga, fokus pada gizi anak.
Sekunder: ayah / pengasuh yang ikut memasak.

## 3. Kebutuhan Fungsional

| Modul | Kebutuhan inti |
|---|---|
| Autentikasi | Login, register dengan verifikasi OTP email, Google Sign-In, logout |
| Stok | Tambah/edit/hapus bahan, kuantitas + unit, kategori, tanggal kedaluwarsa, daftar stok |
| Dashboard | Ringkasan stok, bahan hampir kedaluwarsa, aksi cepat |
| Resep | Daftar resep; rekomendasi dari stok; detail + langkah memasak |
| Cooking log | "Saya sudah memasak" -> catat log + kurangi stok secara otomatis |
| Nutrisi | Estimasi gizi resep + perbandingan dengan target AKG anak |
| Pengingat | Bahan hampir kedaluwarsa (in-app list; push FCM menyusul) |
| Profil anak | Usia, berat, tinggi, target nutrisi (Fase 2); riwayat tumbuh (Fase 3) |

### Batas cakupan (non-goals)
- Pairing multi-perangkat antar anggota keluarga: di luar MVP.
- Manajemen resep komunitas / berbagi resep: di luar MVP.

## 4. Alur Utama (User Flow)

```
Splash -> Welcome -> Login/Register(OTP/Google) -> Home

Home          : ringkasan stok + bahan kritikal (<=3 hari expired) + aksi cepat
Input stok    : "+ Stok" -> cari bahan (ingredients_master) -> qty+unit+tgl expired -> simpan
Rekomendasi   : "Rekomendasi Resep" -> backend pakai stok aktif -> (Fase1) resep manual
                -> (Fase2) AI -> daftar resep + peringkat nutrisi
Detail resep  : bahan + ukuran, langkah, estimasi gizi vs AKG
Masak         : "Saya sudah memasak" -> cooking_log + stok berkurang otomatis
Pengingat     : daftar bahan dengan expiry_date <= N hari
```

## 5. Arsitektur

```
┌────────────────────────────────── Flutter ───────────────────────────────────┐
│  presentation (pages/cubit) -> domain (usecase/entity) -> data (repo/http)  │
│  fitur per-modul: auth, stock, recipe, nutrition, child, home                │
└────────────────────────────────────┬─────────────────────────────────────────┘
                                     │ HTTPS JSON + token (Sanctum)
┌───────────────────────────── Laravel API ────────────────────────────────────┐
│  routes/api -> Controller (validasi) -> Service (logika bisnis)              │
│                    -> Repository/Eloquent -> MySQL (dapur_cerdas)            │
│  [AiService] dipanggil SERVER-SIDE only (Gemini), hasil JSON ter-schema      │
└───────────────────────────────────────────────────────────────────────────────┘
```

### Keputusan teknis & alasannya
1. **Laravel + MySQL, bukan Firestore/Supabase.**
   Perhitungan nutrisi adalah operasi kuantitatif (relasi bahan <-> resep <-> stok) yang
   paling alami di database relasional dengan transaksi.
2. **Clean architecture dua sisi.** Sudah dimulai di Flutter (data/domain/presentation) dan
   diteruskan: Laravel memakai *service layer* agar controller tipis dan logika dapat diuji.
3. **AI di server-side hanya.** API key Gemini/OpenAI tidak pernah masuk ke kode Flutter.
   Model: `AiService` (interface) -> `GeminiAiService`. Memakai HTTP client bawaan Laravel
   ke `generativelanguage.googleapis.com`, tanpa dependensi SDK pihak ketiga.
4. **Nutrisi dihitung di Laravel, bukan dari AI.** AI hanya memberi struktur resep; angka
   gizi dihitung proporsional dari `ingredients_master` (per 100 g) dikali `quantity_needed`.
   Konsisten dan tidak bisa salah oleh output LLM.
5. **Auth dengan Laravel Sanctum (token), bukan JWT custom.** Cukup untuk API mobile,
   tanpa overhead pengelolaan refresh token.

## 6. Skema Database

### Tabel existing (sudah diaplikasikan)

- `users` (+ kolom OTP: `otp_code`, `otp_expires_at`, `email_verified_at`)
- `ingredient_categories` — `id`, `name` (unik): Sayur, Protein, Karbohidrat, Buah, Bumbu, Dairy
- `ingredients_master` — master bahan, nutrisi per 100 g:
  `category_id`, `name`, `default_unit`, `calories_per_100g`, `protein_g`, `fat_g`,
  `carbs_g`, `iron_mg`, `zinc_mg`, `vitamin_a_mcg`, `vitamin_c_mg`; index(name)
- `user_stocks` — `user_id`, `ingredient_id`, `quantity`, `unit`, `expiry_date`;
  index(`user_id`, `expiry_date`) untuk query hampir kedaluwarsa
- `recipes` — `name`, `description`, `instructions`, `cook_time_minutes`,
  `source` (manual|ai_generated), `created_by`
- `recipe_ingredients` — `recipe_id`, `ingredient_id`, `quantity_needed`, `unit`;
  unik(recipe_id, ingredient_id)
- `cooking_logs` — `user_id`, `recipe_id`, `servings`, `cooked_at`

### Tabel baru (migration Fase 2)

- `children` — `user_id` FK cascade, `name`, `gender`, `birth_date`
  (usia dihitung dari birth_date, tidak disimpan sebagai angka)
- `growth_records` — `child_id` FK cascade, `recorded_at`, `weight_kg`, `height_cm`
  (dasar analisis perkembangan Fase 3)
- `nutrition_targets` — `child_id` FK cascade, `calories`, `protein_g`, `iron_mg`,
  `zinc_mg`, `vitamin_a_mcg`, `vitamin_c_mg` (target AKG anak)
- `recipe_favorites` — `user_id` FK cascade, `recipe_id` FK cascade; unik(user_id, recipe_id)

### Aturan domain
- Satu baris `user_stocks` per kombinasi (user, ingredient): ada bahan -> *upsert* naikkan
  `quantity`, bukan duplikasi baris.
- Penghapusan resep: cascade ke `recipe_ingredients`. Bahan/referensi dilarang dihapus bila
  masih dipakai (restrict).

## 7. Integrasi AI (Fase 2)

- Interface `AiService` dengan method `recommendRecipes(array $ingredientNames): array`.
- Implementasi `GeminiAiService`: kirim daftar nama bahan tersedia + profil anak, minta
  output JSON deterministik dengan struktur tetap:
  ```json
  [
    {
      "name": "string",
      "description": "string",
      "cook_time_minutes": 25,
      "instructions": "string",
      "ingredients": [
        {"name": "Bayam", "quantity_needed": 100, "unit": "gram"}
      ]
    }
  ]
  ```
- Hasil AI disimpan ke tabel `recipes` (source=`ai_generated`) bila disetujui pengguna.
- `NutritionService` menghitung `calories/protein/iron/zinc/vitamin` dari mapping nama ->
  `ingredients_master`. Nama tidak dikenal -> diabaikan + dicatat untuk review.

## 8. Notifikasi & Pengingat

- Fase 1-2: list **in-app** — query `user_stocks` dengan `expiry_date` dalam rentang
  (misal <= 3 hari) atau sudah lewat; ditampilkan di dashboard.
- Push (FCM) dijadwalkan belakangan, tidak menghalangi MVP.

## 9. Roadmap

### Phase 0 — Foundation (status: selesai sebagian)
- Auth lengkap (register+OTP, login, Google, logout) — selesai.
- Sisa: data awal lengkap (bahan + resep manual) via seeder.

### Phase 1 — Prototype
1. Backend: model + service + controller bahan (list/show/search) dan stok (CRUD).
2. Seeder lengkap: kategori, ~150 bahan, ~15 resep manual.
3. Flutter: fitur `stock` (list/tambah/edit/hapus) terhubung API.
4. Flutter: dashboard riil (jumlah stok, bahan kritikal) menggantikan dummy.
5. Backend: list resep yang bisa dibuat dari stok (tanpa AI).
6. Flutter: detail resep + "Saya sudah memasak" -> cooking_log + pengurangan stok otomatis.

### Phase 2 — AI & Nutrisi
7. `AiService` + `GeminiAiService` -> rekomendasi resep dari stok, JSON ter-schema.
8. `NutritionService` -> estimasi gizi + perbandingan target AKG.
9. Flutter: modul `child` (profil + target gizi) dan tampilan status kecukupan.
10. Migration tabel baru: `children`, `nutrition_targets`.

### Phase 3 — Vision & Personalisasi
11. AI vision pengenalan bahan dari kamera/upload.
12. Personalisasi menu dari riwayat + target gizi.
13. Analisis perkembangan anak (`growth_records` vs kurva WHO).

## 10. Standar & Konvensi

- **REST**: JSON, envelope `{ "success": bool, "message": string, "data": ... }`.
  Error 422 = validasi, 401 = auth, 403 = akses/verifikasi, 404 = tidak ditemukan.
- **Flutter**: Cubit + get_it + dio + dartz. Jangan meletakkan logika bisnis di widget.
- **Konvensi penulisan**: ikuti pola yang sudah ada (lihat `AuthController`).
- **Tanpa fitur mati**: elemen UI tanpa perilaku nyata tidak dikirim; beri label "Segera"
  bila fitur ditunda.