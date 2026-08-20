import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../controllers/notification_cubit.dart';
import '../controllers/notification_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<NotificationCubit>()..fetchNotifications(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Bildirimler'),
          centerTitle: true,
          actions: [
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoaded && state.unreadCount > 0) {
                  return IconButton(
                    icon: const Icon(Icons.done_all_rounded),
                    tooltip: 'Tümünü Okundu İşaretle',
                    onPressed: () {
                      context.read<NotificationCubit>().markAllAsRead();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            } else if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return _EmptyNotifications();
              }
              
              return RefreshIndicator(
                onRefresh: () => context.read<NotificationCubit>().fetchNotifications(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notification = state.notifications[index];
                    return _NotificationCard(
                      title: notification.title,
                      message: notification.message,
                      time: _formatDate(notification.createdAt),
                      isUnread: !notification.isRead,
                      icon: _getIconForTitle(notification.title),
                      iconColor: _getColorForTitle(notification.title),
                      onTap: () {
                        if (!notification.isRead) {
                          context.read<NotificationCubit>().markAsRead(notification.id);
                        }
                      },
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _getIconForTitle(String title) {
    if (title.toLowerCase().contains('bakım') || title.toLowerCase().contains('arıza') || title.toLowerCase().contains('iş')) {
      return Icons.build_rounded;
    }
    if (title.toLowerCase().contains('duyuru')) {
      return Icons.campaign_rounded;
    }
    if (title.toLowerCase().contains('ödeme') || title.toLowerCase().contains('tahsilat')) {
      return Icons.payments_rounded;
    }
    return Icons.notifications_rounded;
  }

  Color _getColorForTitle(String title) {
    if (title.toLowerCase().contains('bakım') || title.toLowerCase().contains('arıza') || title.toLowerCase().contains('iş')) {
      return AppColors.primary;
    }
    if (title.toLowerCase().contains('duyuru')) {
      return AppColors.warning;
    }
    if (title.toLowerCase().contains('ödeme') || title.toLowerCase().contains('tahsilat')) {
      return AppColors.success;
    }
    return AppColors.secondary;
  }
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textTertiary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Bildirim Yok', style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Şu an için yeni bir bildiriminiz bulunmuyor.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final bool isUnread;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.title,
    required this.message,
    required this.time,
    required this.isUnread,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnread ? AppColors.primary.withOpacity(0.05) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread ? AppColors.primary.withOpacity(0.3) : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: (isUnread ? AppColors.primary : Colors.black).withOpacity(isUnread ? 0.06 : 0.02),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
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
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8, top: 4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      time,
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
