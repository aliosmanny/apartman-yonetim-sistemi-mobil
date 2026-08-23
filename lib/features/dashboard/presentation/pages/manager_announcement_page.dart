import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../announcements/domain/models/announcement.dart';
import '../../../announcements/presentation/controllers/announcement_cubit.dart';
import '../../../announcements/presentation/controllers/announcement_state.dart';

class ManagerAnnouncementPage extends StatelessWidget {
  const ManagerAnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AnnouncementCubit>()..fetchAnnouncements(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Duyurular'),
          centerTitle: true,
        ),
        body: BlocBuilder<AnnouncementCubit, AnnouncementState>(
          builder: (context, state) {
            if (state is AnnouncementLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AnnouncementError) {
              return Center(
                child: Text('Hata: ${state.message}', style: const TextStyle(color: AppColors.error)),
              );
            } else if (state is AnnouncementLoaded) {
              final announcements = state.announcements;
              if (announcements.isEmpty) {
                return const Center(child: Text('Henüz duyuru yayınlanmamış.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: announcements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final ann = announcements[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ann.title,
                                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ann.apartmentName ?? 'Genel',
                                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (ann.status == 'published' || ann.status == 'Yayında')
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.textTertiary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                ann.statusDisplay ?? ann.status,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: (ann.status == 'published' || ann.status == 'Yayında')
                                      ? AppColors.success
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          ann.content,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 16, color: AppColors.textTertiary),
                                const SizedBox(width: 4),
                                Text(
                                  ann.createdByName ?? 'Bilinmiyor',
                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textTertiary),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(ann.publishDate ?? ann.createdAt),
                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  context.push('/manager/announcements/edit', extra: {
                                    'announcement': ann,
                                    'cubit': context.read<AnnouncementCubit>()
                                  });
                                },
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Düzenle'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Silme Onayı'),
                                      content: const Text('Bu duyuruyu silmek istediğinize emin misiniz?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Sil', style: TextStyle(color: AppColors.error)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true && context.mounted) {
                                    context.read<AnnouncementCubit>().deleteAnnouncement(ann.id);
                                  }
                                },
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                label: const Text('Sil', style: TextStyle(color: AppColors.error)),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              onPressed: () {
                context.push('/manager/announcements/create', extra: context.read<AnnouncementCubit>());
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Duyuru Ekle', style: TextStyle(color: Colors.white)),
            );
          }
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
