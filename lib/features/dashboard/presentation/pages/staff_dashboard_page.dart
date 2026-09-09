import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/presentation/controllers/auth_cubit.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../controllers/dashboard_cubit.dart';
import '../../../maintenance/data/datasources/maintenance_remote_data_source.dart';
import '../../../maintenance/presentation/controllers/maintenance_cubit.dart';

class StaffDashboardPage extends StatelessWidget {
  const StaffDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 150,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: const Color(0xFFB45309),
                  flexibleSpace: FlexibleSpaceBar(
                    background: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.staffGradient,
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -40,
                              right: -40,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withAlpha(13),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -20,
                              left: -20,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withAlpha(10),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(46),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withAlpha(89),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            (user?.firstName != null && user!.firstName.isNotEmpty)
                                                ? user.firstName.substring(0, 1).toUpperCase()
                                                : 'P',
                                            style: AppTextStyles.headlineSmall.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Merhaba, ${user?.firstName ?? 'Personel'}!',
                                              style: AppTextStyles.headlineMedium.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'İş Takip Ekranı',
                                              style: AppTextStyles.bodyMedium.copyWith(
                                                color: Colors.white.withAlpha(204),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(38),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: IconButton(
                                          onPressed: () => context.read<AuthCubit>().logout(),
                                          icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                                          tooltip: 'Çıkış Yap',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── İstatistik Kartları ─────────────
                      BlocBuilder<DashboardCubit, DashboardState>(
                        builder: (context, state) {
                          if (state is DashboardLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is DashboardError) {
                            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                          } else if (state is StaffDashboardLoaded) {
                            final data = state.data;
                            return Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    label: 'Bekleyen',
                                    value: data.pendingCount.toString(),
                                    color: AppColors.primary,
                                    icon: Icons.assignment_rounded,
                                    onTap: () => context.go('/staff/assigned'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    label: 'Devam Eden',
                                    value: data.inProgressCount.toString(),
                                    color: AppColors.maintenanceInProgress,
                                    icon: Icons.autorenew_rounded,
                                    onTap: () => context.go('/staff/assigned'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    label: 'Tamamlanan',
                                    value: data.completedCount.toString(),
                                    color: AppColors.maintenanceCompleted,
                                    icon: Icons.check_circle_rounded,
                                    onTap: () => context.go('/staff/completed'),
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 24),

                      // ── Atanan Talepler ───────────────
                      Row(
                        children: [
                          Expanded(
                            child: Text('Bugünkü İşlerim', style: AppTextStyles.headlineSmall),
                          ),
                          TextButton(
                            onPressed: () => context.go('/staff/assigned'),
                            child: const Text('Tümü'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<DashboardCubit, DashboardState>(
                        builder: (context, state) {
                          if (state is StaffDashboardLoaded) {
                            if (state.data.recentRequests.isEmpty) {
                              return _EmptyTaskCard();
                            }
                            return Column(
                              children: state.data.recentRequests.map((task) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _StaffTaskCard(
                                    id: task.id.toString(),
                                    title: task.title,
                                    unit: task.unit ?? 'Ortak Alan',
                                    status: task.status,
                                    statusDisplay: task.statusDisplay,
                                    timeAgo: task.createdAt.split('T').first,
                                  ),
                                );
                              }).toList(),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 80),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(value, style: AppTextStyles.headlineMedium.copyWith(color: color)),
                  const SizedBox(height: 2),
                  Text(label, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTaskCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_turned_in_rounded, size: 48, color: AppColors.maintenanceCompleted.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text('Atanmış iş yok', style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Yönetici bir talep atadığında burada görünecek.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _StaffTaskCard extends StatelessWidget {
  final String id;
  final String title;
  final String unit;
  final String status;
  final String statusDisplay;
  final String timeAgo;

  const _StaffTaskCard({
    required this.id,
    required this.title,
    required this.unit,
    required this.status,
    required this.statusDisplay,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final inProgress = status == 'in_progress' || status == 'i';
    final isPending = status == 'pending' || status == 'p' || status == 'assigned' || status == 'a';
    
    Color statusColor = AppColors.maintenancePending;
    if (inProgress) statusColor = AppColors.maintenanceInProgress;
    if (!isPending && !inProgress) statusColor = AppColors.maintenanceCompleted;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditBottomSheet(context),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.build_circle_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: AppTextStyles.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      statusDisplay,
                                      style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.apartment_rounded, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(unit, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    Row(
                       children: [
                        const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(timeAgo, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditBottomSheet(BuildContext context) {
    final maintenanceCubit = context.read<MaintenanceCubit>();
    final dashboardCubit = context.read<DashboardCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StaffTaskEditSheet(
        taskId: id,
        title: title,
        unit: unit,
        status: status,
        statusDisplay: statusDisplay,
        onUpdated: () {
          // Dashboard ve talepleri yenile
          dashboardCubit.fetchStaffDashboard();
          maintenanceCubit.fetchRequests();
        },
      ),
    );
  }
}

// ── Düzenleme Bottom Sheet ────────────────────────────────────
class _StaffTaskEditSheet extends StatefulWidget {
  final String taskId;
  final String title;
  final String unit;
  final String status;
  final String statusDisplay;
  final VoidCallback onUpdated;

  const _StaffTaskEditSheet({
    required this.taskId,
    required this.title,
    required this.unit,
    required this.status,
    required this.statusDisplay,
    required this.onUpdated,
  });

  @override
  State<_StaffTaskEditSheet> createState() => _StaffTaskEditSheetState();
}

class _StaffTaskEditSheetState extends State<_StaffTaskEditSheet> {
  final _noteController = TextEditingController();
  late String _selectedStatus;
  XFile? _selectedPhoto;
  bool _isLoading = false;

  final _statusOptions = const [
    {'value': 'in_progress', 'label': 'İşlem Devam Ediyor'},
    {'value': 'completed', 'label': 'Tamamlandı'},
    {'value': 'assigned', 'label': 'Personel Atandı'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.status;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (photo != null) setState(() => _selectedPhoto = photo);
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final ds = sl<MaintenanceRemoteDataSource>();

      // 1. Durum güncelle
      if (_selectedStatus != widget.status) {
        await ds.updateMaintenanceStatus(
          widget.taskId,
          _selectedStatus,
          note: _noteController.text.isNotEmpty ? _noteController.text : null,
        );
      }

      // 2. Not ve fotoğraf güncelle
      if (_noteController.text.isNotEmpty || _selectedPhoto != null) {
        await ds.updateStaffNote(
          widget.taskId,
          staffNote: _noteController.text.isNotEmpty ? _noteController.text : null,
          staffPhoto: _selectedPhoto,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Talep güncellendi'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Talebi Düzenle', style: AppTextStyles.headlineSmall),
                ],
              ),
            ),
            const Divider(height: 24),
            // Form
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Read-only bilgiler
                  _InfoRow(label: 'Daire', value: widget.unit),
                  _InfoRow(label: 'Talep Başlığı', value: widget.title),
                  _InfoRow(label: 'Mevcut Durum', value: widget.statusDisplay),
                  const SizedBox(height: 16),

                  // Durum güncelle
                  Text('Durum Güncelle', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _statusOptions.any((o) => o['value'] == _selectedStatus) ? _selectedStatus : null,
                        isExpanded: true,
                        hint: const Text('Durum seçin'),
                        items: _statusOptions.map((o) => DropdownMenuItem(
                          value: o['value'],
                          child: Text(o['label']!),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedStatus = v ?? _selectedStatus),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Personel Notu
                  Text('Personel Notu / Cevabı', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Notunuzu buraya yazın...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Personel Fotoğrafı
                  Text('Personel Fotoğrafı', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: _selectedPhoto != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(_selectedPhoto!.path, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_rounded, size: 32, color: Colors.grey.shade400),
                                const SizedBox(height: 4),
                                Text('Dosya Seç', style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade500)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Kaydet Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Kaydet ve Düzenlemeyi Bitir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}