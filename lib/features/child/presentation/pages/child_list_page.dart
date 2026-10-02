import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../cubit/child_cubit.dart';
import '../cubit/child_state.dart';
import '../widgets/child_profile_form.dart';
import 'child_detail_page.dart';

class ChildListPage extends StatelessWidget {
  const ChildListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChildCubit>()..loadChildren(),
      child: Scaffold(
        backgroundColor: AppColors.bgGradientStart,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Profil Anak',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        body: BlocConsumer<ChildCubit, ChildState>(
          listener: (context, state) {},
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryDark),
              ),
              loaded: (children) => RefreshIndicator(
                    color: const Color(0xFF1B5E20),
                    onRefresh: () => context.read<ChildCubit>().loadChildren(),
                    child: children.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            children: [
                              const SizedBox(height: 40),
                              Center(
                                child: Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(24)),
                                  child: const Icon(Icons.child_care, size: 44, color: Color(0xFF1B5E20)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada profil anak',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tambahkan data si kecil untuk pantau tumbuh kembang dan dapatkan rekomendasi gizi harian.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF6B7280), height: 1.4),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showAddChildDialog(context),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: Text('Tambah Profil Anak', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B5E20),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: Text('Tarik ke bawah untuk memuat ulang', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF9CA3AF))),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: children.length,
                            itemBuilder: (context, index) {
                              final child = children[index];
                              return _ChildCard(
                                child: child,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ChildDetailPage(child: child)),
                                ).then((_) {
                                  if (context.mounted) context.read<ChildCubit>().loadChildren();
                                }),
                                onEdit: () => _showEditChildDialog(context, child),
                                onDelete: () => _showDeleteConfirm(context, child.id),
                              );
                            },
                          ),
                  ),
              childDetail: (_) => const SizedBox.shrink(),
              failure: (message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text('Gagal memuat profil anak', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(message, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF6B7280))),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<ChildCubit>().loadChildren(),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (fabCtx) => FloatingActionButton(
            backgroundColor: const Color(0xFF1B5E20),
            onPressed: () => _showAddChildDialog(fabCtx),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _showAddChildDialog(BuildContext context) {
    final cubit = context.read<ChildCubit>();
    showDialog(
      context: context,
      builder: (dialogCtx) => ChildProfileForm(
        onSubmit: (name, gender, birthDate) {
          cubit.createChild(name: name, gender: gender, birthDate: birthDate);
          Navigator.pop(dialogCtx);
        },
      ),
    );
  }

  void _showEditChildDialog(BuildContext context, dynamic child) {
    final cubit = context.read<ChildCubit>();
    showDialog(
      context: context,
      builder: (dialogCtx) => ChildProfileForm(
        initialChild: child,
        onSubmit: (name, gender, birthDate) {
          cubit.updateChild(id: child.id, name: name, gender: gender, birthDate: birthDate);
          Navigator.pop(dialogCtx);
        },
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, int childId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Profil?'),
        content: const Text('Profil anak dan semua data terkait akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ChildCubit>().deleteChild(childId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

}

String _formatAge(dynamic child) {
  final m = child.ageInMonths as int;
  if (m < 24) return '$m bulan';
  if (m % 12 == 0) return '${m ~/ 12} tahun';
  return '${m ~/ 12} th ${m % 12} bln';
}

class _ChildCard extends StatelessWidget {
  final dynamic child;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ChildCard({
    required this.child,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    child.gender == 'male' ? Icons.boy : Icons.girl,
                    color: AppColors.primaryDark,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatAge(child),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Edit'),
                      onTap: onEdit,
                    ),
                    PopupMenuItem(
                      child: const Text('Hapus'),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
