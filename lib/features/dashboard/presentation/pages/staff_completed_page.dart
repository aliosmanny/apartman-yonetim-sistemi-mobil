import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../maintenance/domain/models/maintenance_request.dart';
import '../../../maintenance/presentation/controllers/maintenance_cubit.dart';
import '../../../maintenance/presentation/controllers/maintenance_state.dart';

class StaffCompletedPage extends StatefulWidget {
  const StaffCompletedPage({super.key});

  @override
  State<StaffCompletedPage> createState() => _StaffCompletedPageState();
}

class _StaffCompletedPageState extends State<StaffCompletedPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MaintenanceCubit>().fetchRequests();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tamamlanan İşler'),
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
              // Tamamlanmış veya iptal edilmiş işler
              final completedTasks = state.requests.where((r) {
                final s = r.status.toLowerCase();
                return s == 'completed' || s == 'resolved' || s == 'cancelled' || s == 'rejected' || s == 'c' || s == 'x';
              }).toList();

              if (completedTasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, size: 64, color: AppColors.textTertiary.withAlpha(128)),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz tamamlanmış işiniz yok',
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
                  itemCount: completedTasks.length,
                  itemBuilder: (context, index) {
                    final task = completedTasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _StaffCompletedCard(task: task),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
    );
  }
}

class _StaffCompletedCard extends StatelessWidget {
  final MaintenanceRequest task;

  const _StaffCompletedCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final isCancelled = task.status == 'cancelled' || task.status == 'rejected' || task.status == 'x';
    final statusColor = isCancelled ? AppColors.maintenanceCancelled : AppColors.maintenanceCompleted;
    final dateStr = DateFormat('dd MMM yyyy HH:mm').format(task.createdAt);
    final resolvedStr = task.resolvedAt != null
        ? DateFormat('dd MMM yyyy HH:mm').format(task.resolvedAt!)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: isCancelled
            ? AppColors.errorLight.withAlpha(51)
            : AppColors.successLight.withAlpha(77),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withAlpha(51)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
            Expanded(
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
                            color: statusColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isCancelled ? Icons.cancel_rounded : Icons.check_circle_rounded,
                            color: statusColor,
                          ),
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
                                      color: statusColor.withAlpha(26),
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
                                          isCancelled ? 'İptal Edildi' : 'Tamamlandı',
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: statusColor,
                                            fontWeight: FontWeight.w700,
                                          ),
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
                              resolvedStr != null ? 'Çözüm: $resolvedStr' : 'Oluşturulma: $dateStr',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}