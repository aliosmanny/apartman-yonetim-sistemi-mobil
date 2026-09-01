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
  final bool showAppBar;
  final List<MaintenanceRequest>? filteredRequests;
  const MaintenanceListPage(
      {super.key, this.showAppBar = true, this.filteredRequests});

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
              title: const Text('Talepler ve Arızalar'),
              centerTitle: false,
            )
          : null,
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
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<MaintenanceCubit>().fetchRequests(),
                    child: const Text('Tekrar Dene'),
                  )
                ],
              ),
            );
          }

          if (state is MaintenanceLoaded) {
            final requests = filteredRequests ?? state.requests;
            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sentiment_satisfied_alt_rounded,
                        size: 64, color: AppColors.textTertiary),
                    const SizedBox(height: 16),
                    Text('Hiç talebiniz bulunmuyor.',
                        style: AppTextStyles.headlineMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<MaintenanceCubit>().fetchRequests(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
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
        builder: (fabContext) {
          return FloatingActionButton(
            onPressed: () async {
              // Güvenli context kullanımı ve sayfa yönlendirmesi
              await GoRouter.of(fabContext)
                  .push('/resident/maintenance/create');
              if (fabContext.mounted) {
                fabContext.read<MaintenanceCubit>().fetchRequests();
              }
            },
            backgroundColor: AppColors.primary,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );

    if (filteredRequests != null) {
      return scaffold;
    }
    return BlocProvider(
      create: (context) => sl<MaintenanceCubit>()..fetchRequests(),
      child: scaffold,
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
        statusColor = AppColors.maintenanceCompleted;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'in_progress':
        statusColor = AppColors.maintenanceInProgress;
        statusIcon = Icons.engineering_rounded;
        break;
      case 'rejected':
        statusColor = AppColors.maintenanceCancelled;
        statusIcon = Icons.cancel_rounded;
        break;
      default: // pending
        statusColor = AppColors.maintenancePending;
        statusIcon = Icons.pending_actions_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.06),
            blurRadius: 16,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.title, style: AppTextStyles.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Kategori: ${request.safeCategoryDisplay}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        request.safeStatusDisplay,
                        style: AppTextStyles.labelSmall.copyWith(
                            color: statusColor, fontWeight: FontWeight.w700),
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
            Text(request.description, style: AppTextStyles.bodyMedium),
            if (request.adminNotes != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.admin_panel_settings_rounded,
                            size: 14, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text('Yönetici Notu:',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.warning)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.adminNotes!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Oluşturulma: ${_formatDate(request.createdAt)}',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textTertiary),
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
