import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../maintenance/domain/models/maintenance_request.dart';

class StaffAssignedPage extends StatefulWidget {
  const StaffAssignedPage({super.key});

  @override
  State<StaffAssignedPage> createState() => _StaffAssignedPageState();
}

class _StaffAssignedPageState extends State<StaffAssignedPage> {
  late final List<MaintenanceRequest> _mockTasks;

  @override
  void initState() {
    super.initState();
    _mockTasks = [
      MaintenanceRequest(
        id: 't1',
        title: 'Asansör Çalışmıyor',
        description: 'A Blok asansörü 3. katta takılı kaldı, kapıları kapanmıyor.',
        status: 'in_progress',
        category: 'elevator',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        adminNotes: 'Acil müdahale gerekli.',
      ),
      MaintenanceRequest(
        id: 't2',
        title: 'Ortak Alan Ampul Değişimi',
        description: 'B Blok girişindeki ampuller patlamış.',
        status: 'pending',
        category: 'electrical',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bana Atanan İşler'),
        centerTitle: true,
      ),
      body: _mockTasks.isEmpty
          ? Center(
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
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _mockTasks.length,
        itemBuilder: (context, index) {
          final task = _mockTasks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _StaffAssignedCard(task: task),
          );
        },
      ),
    );
  }
}

class _StaffAssignedCard extends StatelessWidget {
  final MaintenanceRequest task;

  const _StaffAssignedCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final bool inProgress = task.status == 'in_progress';
    final Color statusColor = inProgress ? AppColors.maintenanceInProgress : AppColors.maintenancePending;

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
                  Row(
                    children: [
                      const Icon(Icons.apartment_rounded, size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text('A Blok D:12', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text('Bugün, 14:30', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ],
              ),
              if (task.adminNotes != null) ...[
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