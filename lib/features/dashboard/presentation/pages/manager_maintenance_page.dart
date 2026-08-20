import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../maintenance/domain/models/maintenance_request.dart';
import '../../../maintenance/presentation/controllers/maintenance_cubit.dart';
import '../../../maintenance/presentation/controllers/maintenance_state.dart';

class ManagerMaintenancePage extends StatefulWidget {
  const ManagerMaintenancePage({super.key});

  @override
  State<ManagerMaintenancePage> createState() => _ManagerMaintenancePageState();
}

class _ManagerMaintenancePageState extends State<ManagerMaintenancePage> {
  int _currentIndex = 0; // 0: Açık, 1: İşlemde, 2: Çözüldü

  List<MaintenanceRequest> _getFilteredRequests(List<MaintenanceRequest> requests) {
    if (_currentIndex == 0) {
      return requests.where((r) => r.status == 'pending' || r.status == 'Beklemede' || r.status == 'p').toList();
    }
    if (_currentIndex == 1) {
      return requests.where((r) => r.status == 'in_progress' || r.status == 'assigned' || r.status == 'i' || r.status == 'a' || r.status == 'Devam Ediyor').toList();
    }
    return requests.where((r) => r.status == 'completed' || r.status == 'cancelled' || r.status == 'resolved' || r.status == 'rejected' || r.status == 'Tamamlandı' || r.status == 'İptal Edildi' || r.status == 'c').toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MaintenanceCubit>()..fetchRequests(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Talepler ve Arızalar'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildSegment('Açık', 0)),
                    Expanded(child: _buildSegment('İşlemde', 1)),
                    Expanded(child: _buildSegment('Çözülen', 2)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<MaintenanceCubit, MaintenanceState>(
                builder: (context, state) {
                  if (state is MaintenanceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MaintenanceError) {
                    return Center(
                      child: Text(state.message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                    );
                  } else if (state is MaintenanceLoaded) {
                    final filtered = _getFilteredRequests(state.requests);
                    
                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline_rounded, size: 64, color: AppColors.textTertiary.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text(
                              'Bu kategoride talep bulunmuyor',
                              style: AppTextStyles.titleMedium.copyWith(color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => context.read<MaintenanceCubit>().fetchRequests(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final request = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ManagerMaintenanceCard(
                              request: request,
                              onStatusChanged: (newStatus) {
                                context.read<MaintenanceCubit>().updateRequestStatus(request.id, newStatus);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegment(String label, int index) {
    final bool selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _ManagerMaintenanceCard extends StatelessWidget {
  final MaintenanceRequest request;
  final ValueChanged<String> onStatusChanged;

  const _ManagerMaintenanceCard({
    required this.request,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = AppColors.primary;
    if (request.status == 'in_progress' || request.status == 'assigned' || request.status == 'i' || request.status == 'a') statusColor = const Color(0xFFD97706);
    if (request.status == 'resolved' || request.status == 'completed' || request.status == 'c') statusColor = AppColors.success;
    if (request.status == 'rejected' || request.status == 'cancelled' || request.status == 'x') statusColor = AppColors.error;

    return GestureDetector(
      onTap: () {
        // Detay sayfasına gönder
        context.push('/manager/maintenance/${request.id}', extra: request);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.build_circle_outlined, color: AppColors.primary),
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
                                request.title,
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
                                    request.safeStatusDisplay,
                                    style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.description,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text('${request.creatorName ?? ''} (${request.unitDisplay ?? ''})', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(_formatDate(request.createdAt), style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ],
              ),
            ),
            if (request.status == 'pending' || request.status == 'Beklemede' || request.status == 'p') ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showAssignStaffModal(context),
                        child: const Text('Personele Ata'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onStatusChanged('in_progress');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Talep "İşlemde" olarak işaretlendi.')),
                          );
                        },
                        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
                        child: const Text('İşleme Al'),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _showAssignStaffModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Personele Ata', style: AppTextStyles.titleLarge),
                ),
                const SizedBox(height: 8),
                _StaffTile(
                  name: 'Hasan Usta',
                  role: 'Tesisat / Genel Bakım',
                  onAssign: () => onStatusChanged('assigned'),
                ),
                _StaffTile(
                  name: 'Ali Veli',
                  role: 'Elektrik Uzmanı',
                  onAssign: () => onStatusChanged('assigned'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StaffTile extends StatelessWidget {
  final String name;
  final String role;
  final VoidCallback onAssign;

  const _StaffTile({required this.name, required this.role, required this.onAssign});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.12),
        child: Text(
          name.substring(0, 1),
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(name, style: AppTextStyles.titleMedium),
      subtitle: Text(role, style: AppTextStyles.bodySmall),
      onTap: () {
        Navigator.pop(context);
        onAssign();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Talep $name'ye atandı ve işleme alındı.")),
        );
      },
    );
  }
}
