import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../maintenance/domain/models/maintenance_request.dart';

class StaffCompletedPage extends StatefulWidget {
  const StaffCompletedPage({super.key});

  @override
  State<StaffCompletedPage> createState() => _StaffCompletedPageState();
}

class _StaffCompletedPageState extends State<StaffCompletedPage> {
  late final List<MaintenanceRequest> _mockTasks;

  @override
  void initState() {
    super.initState();
    _mockTasks = [
      MaintenanceRequest(
        id: 't3',
        title: 'Boru Patlaması',
        description: 'B Blok zemin kat ana su borusu sızıntısı.',
        status: 'resolved',
        category: 'plumbing',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        resolvedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      MaintenanceRequest(
        id: 't4',
        title: 'Merdiven Temizliği',
        description: 'C Blok merdivenlerinin detaylı yıkanması.',
        status: 'resolved',
        category: 'cleaning',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        resolvedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tamamlanan İşler'),
        centerTitle: true,
      ),
      body: _mockTasks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 64, color: AppColors.textTertiary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Henüz tamamlanmış işiniz yok',
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
            child: _StaffCompletedCard(task: task),
          );
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
    const statusColor = AppColors.maintenanceCompleted;

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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: statusColor),
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
                                  decoration: const BoxDecoration(color: statusColor, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Tamamlandı',
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
                    const Icon(Icons.event_available_rounded, size: 16, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(_formatDate(task.resolvedAt ?? task.createdAt), style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}