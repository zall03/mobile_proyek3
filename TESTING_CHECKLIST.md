# Manual Testing Checklist - Dapur Cerdas MVP

## Auth Flow
- [ ] Register dengan email baru → OTP email diterima → Verify OTP → Dashboard
- [ ] Login dengan akun existing → berhasil masuk → Dashboard
- [ ] Google Sign-In → berhasil login
- [ ] Logout → kembali ke Welcome page
- [ ] Password validation: < 8 karakter → error

## Stock Management
- [ ] Dashboard → "Kelola Stok" → list stok tampil
- [ ] Tambah stok → search bahan (coba "telur", "bayam") → pick bahan → isi qty+unit+expired → simpan
- [ ] List stok → tampil dengan kategori + qty + status (Aman/Segera Habis/Kedaluwarsa)
- [ ] Filter status: Semua → Segera Habis → Kedaluwarsa (berubah benar)
- [ ] Edit stok → ubah qty → simpan → list update
- [ ] Hapus stok → konfirmasi → hapus → list update

## Dashboard
- [ ] Greeting personal: "Halo, [nama]!" tampil
- [ ] Badge status anak: "Fase MPASI Padat Bergizi" + "Update Terkini" tampil
- [ ] Kartu peringatan: "2 Bahan Perlu Diolah Segera" tampil dengan list bahan (jika ada)
- [ ] Banner AI: "Racik Resep dengan AI" → click → ke ResepPage
- [ ] Grid inventory: 4 kategori tampil
- [ ] Notifikasi bell: badge count = expiring + expired items
- [ ] Stat cards: total stok + perhatian count sesuai data

## Recipe
- [ ] Dashboard → "Mulai Racik Seketika" → ResepPage
- [ ] Daftar resep: 15 resep tampil (dari seeder)
- [ ] Kartu resep: waktu masak + jumlah bahan tampil
- [ ] Tap resep → detail halaman: bahan list + cara memasak tampil
- [ ] "Masak Sekarang" button → dialog "Berapa porsi?" tampil → input servings → "Catat" → snackbar "Resep berhasil dicatat"

## Reminders
- [ ] Dashboard notification bell → click → RemindersPage
- [ ] Daftar bahan expiring (≤3 hari): tampil dengan countdown "Sisa X hari"
- [ ] Daftar bahan expired: tampil merah "Sudah Kedaluwarsa"
- [ ] Tombol "Olah Jadi Resep" (untuk non-expired) → ke ResepPage

## Child Profile (Phase 2A)
- [ ] Dashboard → "Si Kecil" menu (jika ada nav) atau cari akses ke ChildListPage
- [ ] Tambah profil anak: form dengan nama/gender/birth_date → simpan → list update
- [ ] Edit profil anak: ubah data → simpan → list update
- [ ] Hapus profil: konfirmasi → hapus
- [ ] Usia tampil benar: "X tahun" (hitung dari birth_date)

## Navigation & UI
- [ ] Bottom nav (jika implemented): 5 menu navigasi (Beranda, Stok, Tanya AI, Nutrisi, Si Kecil)
- [ ] Floating AI button: "Tanya AI" prominent di tengah bawah (jika implemented)
- [ ] AppBar logo + notification bell + profile avatar tampil
- [ ] Logout button → keluar → Welcome page
- [ ] All buttons responsive, tap easily (no overflow)
- [ ] Dark mode (jika ada toggle): contrast WCAG AA

## API Integration
- [ ] Backend server berjalan (127.0.0.1:8000)
- [ ] Login: token disimpan ke secure storage
- [ ] List stok: data dari `/stocks` endpoint
- [ ] Tambah/edit/hapus stok: API call berhasil
- [ ] List resep: data dari `/recipes` endpoint (15 item)
- [ ] Cooking log: API call ke `/cooking-logs` + stok berkurang
- [ ] Profile anak: CRUD ke `/children` endpoint

## Performance & Stability
- [ ] No console errors (flutter analyze clean)
- [ ] Load times < 2 detik per screen
- [ ] Search debounce 350ms bekerja (delay ketika ketik bahan)
- [ ] Form validation berjalan (required fields, date picker, etc)
- [ ] Dialog dismiss: tap luar dialog → tutup
- [ ] Empty states: daftar kosong → friendly message

## Offline & Error Handling
- [ ] Login gagal (wrong password) → error message tampil
- [ ] Network error (server down) → "Gagal memuat data" + "Coba lagi" button
- [ ] Validation error (kosong nama) → error inline pada field
- [ ] Timeout > 10 detik → retry button

## Browser Compatibility (Web)
- [ ] Chrome: semua screen berfungsi
- [ ] Safari: semua screen berfungsi
- [ ] Firefox: semua screen berfungsi
- [ ] Responsive: mobile 375px, tablet 768px, desktop 1920px

## Accessibility (Quick Check)
- [ ] All interactive elements keyboard navigable (Tab)
- [ ] Focus indicators visible
- [ ] Text contrast sufficient (WCAG AA minimum)
- [ ] Form labels clear

---

## Testing Priority
1. **High Priority** (MVP must-have): Auth, Stock CRUD, Dashboard, Recipe detail, Cooking log
2. **Medium Priority** (should-have): Child profile, Reminders, Inventory grid
3. **Low Priority** (nice-to-have): Accessibility deep dive, Performance optimization, Offline support

## Sign-off Criteria
- [ ] All High Priority items pass
- [ ] No critical bugs (crashes, data loss)
- [ ] API integration verified end-to-end
- [ ] Manual smoke test completed
