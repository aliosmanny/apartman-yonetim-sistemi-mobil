import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../domain/models/maintenance_request.dart';
import '../controllers/maintenance_cubit.dart';
import '../controllers/maintenance_state.dart';

class MaintenanceListPage extends StatelessWidget {
  const MaintenanceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MaintenanceCubit>()..fetchRequests(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Talepler ve Arızalar'),
          centerTitle: false,
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
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(state.message, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<MaintenanceCubit>().fetchRequests(),
                      child: const Text('Tekrar Dene'),
                    )
                  ],
                ),
              );
            }

            if (state is MaintenanceLoaded) {
              final requests = state.requests;
              if (requests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sentiment_satisfied_alt, size: 64, color: AppColors.textTertiary),
                      const SizedBox(height: 16),
                      Text('Hiç talebiniz bulunmuyor.',
                          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => context.read<MaintenanceCubit>().fetchRequests(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    return _RequestCard(request: req);
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () async {
                final cubit = context.read<MaintenanceCubit>();
                // Yeni talep sayfasına git ve dönüşü bekle
                await context.push('/resident/maintenance/create');
                // Döndüğünde listeyi yenile
                cubit.fetchRequests();
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final MaintenanceRequest request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (request.status) {
      case 'resolved':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'in_progress':
        statusColor = AppColors.warning;
        statusIcon = Icons.engineering;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
      default: // pending
        statusColor = AppColors.textSecondary;
        statusIcon = Icons.pending_actions;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.title,
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kategori: ${request.categoryDisplayName}',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        request.statusDisplayName,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Text(
              request.description,
              style: AppTextStyles.bodyMedium,
            ),
            if (request.adminNotes != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.admin_panel_settings, size: 14, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text('Yönetici Notu:',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.adminNotes!,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Oluşturulma: ${_formatDate(request.createdAt)}',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
