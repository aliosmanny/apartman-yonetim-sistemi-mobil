import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../maintenance/domain/models/maintenance_request.dart';
import '../../../maintenance/presentation/controllers/maintenance_cubit.dart';
import '../../../maintenance/presentation/controllers/maintenance_state.dart';

class StaffAssignedPage extends StatelessWidget {
  const StaffAssignedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MaintenanceCubit>()..fetchRequests(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Bana Atanan İşler'),
          centerTitle: true,
        ),
        body: BlocBuilder<MaintenanceCubit, MaintenanceState>(
          builder: (context, state) {
            if (state is MaintenanceLoading || state is MaintenanceInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MaintenanceError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(state.message, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<MaintenanceCubit>().fetchRequests(),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            }

            if (state is MaintenanceLoaded) {
              // Devam eden veya yeni atananlar (Tamamlanmamış ve iptal edilmemiş işler)
              final assignedTasks = state.requests.where((r) {
                final s = r.status.toLowerCase();
                return s != 'completed' && s != 'resolved' && s != 'cancelled' && s != 'rejected' && s != 'c' && s != 'x';
              }).toList();

              if (assignedTasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_turned_in_rounded, size: 64, color: AppColors.textTertiary.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'Şu an bekleyen işiniz yok',
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
                  itemCount: assignedTasks.length,
                  itemBuilder: (context, index) {
                    final task = assignedTasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _StaffAssignedCard(task: task),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _StaffAssignedCard extends StatelessWidget {
  final MaintenanceRequest task;

  const _StaffAssignedCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final bool inProgress = task.status == 'in_progress' || task.status == 'i' || task.status == 'assigned' || task.status == 'a';
    final Color statusColor = inProgress ? AppColors.maintenanceInProgress : AppColors.maintenancePending;

    final dateStr = DateFormat('dd MMM yyyy HH:mm').format(task.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // GoRouter parametresi
          context.pushNamed('staffTaskDetail', extra: task);
        },
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
                                task.title,
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
                                    inProgress ? 'Devam Ediyor' : 'Yeni İş',
                                    style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.apartment_rounded, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            task.unitDisplay ?? task.apartmentName ?? 'Genel Ortak Alan',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
              if (task.adminNotes != null && task.adminNotes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warning.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_rounded, size: 16, color: AppColors.warning.withOpacity(0.9)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Yönetici Notu: ${task.adminNotes}',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}