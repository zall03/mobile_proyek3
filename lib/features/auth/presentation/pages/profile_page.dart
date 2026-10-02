import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../injection_container.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/update_me_usecase.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // tampilkan cache dulu biar instan (artisan serve single-threaded jadi /me antre)
    final cached = await sl<FlutterSecureStorage>().read(key: 'cached_user');
    if (cached != null && mounted) {
      try {
        final j = jsonDecode(cached) as Map<String, dynamic>;
        final cu = User(id: j['id'] as int, name: j['name'] as String, email: j['email'] as String);
        setState(() {
          _user = cu;
          _loading = false;
          _error = null;
        });
      } catch (_) {}
    } else {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    // refresh di background tanpa spinner jika sudah ada cache
    final result = await sl<GetMeUsecase>().call();
    if (!mounted) return;
    result.fold(
      (f) {
        // jika sudah ada cache, jangan timpa jadi error; cukup diam
        if (_user != null) {
          setState(() => _loading = false);
          return;
        }
        setState(() {
          _error = f.message;
          _loading = false;
        });
      },
      (u) => setState(() {
        _user = u;
        _loading = false;
        _error = null;
      }),
    );
  }

  Future<void> _showEditNameDialog() async {
    if (_user == null) return;
    final ctrl = TextEditingController(text: _user!.name);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ubah Nama', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Nama',
            hintText: 'Masukkan nama baru',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final name = ctrl.text.trim();
    if (name.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nama tidak boleh kosong', style: GoogleFonts.plusJakartaSans()), backgroundColor: Colors.red));
      return;
    }
    final result = await sl<UpdateMeUsecase>().call(name: name);
    if (!mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message, style: GoogleFonts.plusJakartaSans()), backgroundColor: Colors.red)),
      (u) {
        setState(() => _user = u);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nama berhasil diperbarui', style: GoogleFonts.plusJakartaSans()), backgroundColor: const Color(0xFF1B5E20)));
      },
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final curCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ganti Kata Sandi', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: curCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Kata sandi saat ini', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10),
              TextField(controller: newCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Kata sandi baru (min 8)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10),
              TextField(controller: confCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Konfirmasi kata sandi baru', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
            child: const Text('Ubah'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final cur = curCtrl.text;
    final ne = newCtrl.text;
    final conf = confCtrl.text;
    if (cur.isEmpty || ne.isEmpty || conf.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Semua field wajib diisi', style: GoogleFonts.plusJakartaSans()), backgroundColor: Colors.red));
      return;
    }
    if (ne.length < 8) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kata sandi baru minimal 8 karakter', style: GoogleFonts.plusJakartaSans()), backgroundColor: Colors.red));
      return;
    }
    if (ne != conf) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Konfirmasi tidak cocok', style: GoogleFonts.plusJakartaSans()), backgroundColor: Colors.red));
      return;
    }
    final result = await sl<ChangePasswordUsecase>().call(currentPassword: cur, newPassword: ne, newPasswordConfirmation: conf);
    if (!mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message, style: GoogleFonts.plusJakartaSans()), backgroundColor: Colors.red)),
      (_) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kata sandi berhasil diubah', style: GoogleFonts.plusJakartaSans()), backgroundColor: const Color(0xFF1B5E20))),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Keluar?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text('Sesi akan diakhiri dan perlu login ulang.', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await sl<AuthRepository>().logout();
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Profil Saya', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w800, color: const Color(0xFF1B5E20), fontSize: 16)),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF6B7280))),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _load,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF3F4F6))),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: const Color(0xFFE8F5E9),
                              child: Text(
                                _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : '?',
                                style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF1B5E20)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(_user!.name, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF111827))),
                            const SizedBox(height: 4),
                            Text(_user!.email, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF6B7280))),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
                              child: Text('Akun Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF166534))),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _InfoTile(icon: Icons.person_outline, label: 'Nama', value: _user!.name),
                      const SizedBox(height: 8),
                      _InfoTile(icon: Icons.email_outlined, label: 'Email', value: _user!.email),
                      const SizedBox(height: 8),
                      _InfoTile(icon: Icons.badge_outlined, label: 'ID Pengguna', value: '#${_user!.id}'),
                      const SizedBox(height: 16),
                      _ActionTile(icon: Icons.edit_outlined, label: 'Ubah Profil', subtitle: 'Ubah nama tampilan', onTap: _showEditNameDialog),
                      const SizedBox(height: 8),
                      _ActionTile(icon: Icons.lock_outline, label: 'Ganti Kata Sandi', subtitle: 'Minimal 8 karakter', onTap: _showChangePasswordDialog),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout, size: 18),
                          label: Text('Keluar', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFFECACA)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Dapur Cerdas v1.0 • Cegah stunting sejak dapur', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF3F4F6))),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: const Color(0xFF6B7280))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF9CA3AF))), Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111827)))])),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF3F4F6))),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF374151)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111827))), Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF9CA3AF)))])),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}