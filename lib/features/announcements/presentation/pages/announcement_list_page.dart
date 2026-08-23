import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../domain/models/announcement.dart';
import '../controllers/announcement_cubit.dart';
import '../controllers/announcement_state.dart';

class AnnouncementListPage extends StatelessWidget {
  final bool showAppBar;
  const AnnouncementListPage({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AnnouncementCubit>()..fetchAnnouncements(status: 'published'),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: showAppBar ? AppBar(
          title: const Text('Duyurular'),
          centerTitle: true,
        ) : null,
        body: BlocBuilder<AnnouncementCubit, AnnouncementState>(
          builder: (context, state) {
            if (state is AnnouncementLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AnnouncementError) {
              return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
            } else if (state is AnnouncementLoaded) {
              final announcements = state.announcements;
              if (announcements.isEmpty) {
                return const Center(child: Text('Henüz duyuru bulunmamaktadır.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: announcements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _AnnouncementCard(announcement: announcements[index]);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const _AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    // Resident için her duyuru standart kabul edilir veya hepsi önemli gösterilir.
    // Şimdilik hepsi standart.
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
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.campaign_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                announcement.title,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(announcement.publishDate ?? announcement.createdAt),
                                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      announcement.content,
                      style: AppTextStyles.bodyMedium,
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
