import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../announcements/domain/models/announcement.dart';
import '../../../announcements/domain/repositories/announcement_repository.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../../auth/presentation/controllers/auth_cubit.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../../maintenance/domain/models/maintenance_request.dart';
import '../../../maintenance/domain/repositories/maintenance_repository.dart';
import '../../domain/models/notification.dart';
import '../controllers/notification_cubit.dart';
import '../controllers/notification_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  Future<void> _navigateToTarget(BuildContext context, NotificationModel notification) async {
    final authState = context.read<AuthCubit>().state;
    final role = authState is AuthAuthenticated ? authState.user.role : null;
    final isManager = role?.isManager ?? false;
    final isResident = role?.isResident ?? false;
    final isStaff = role == UserRole.staff;

    final link = (notification.link ?? '').toLowerCase();
    final title = notification.title.toLowerCase();
    final message = notification.message.toLowerCase();
    final text = '$link $title $message';

    if (text.contains('bakım') || 
        text.contains('arıza') || 
        text.contains('talep') || 
        text.contains('maintenance') || 
        text.contains('iş') || 
        text.contains('görev')) {
      
      // Talebi bulup doğrudan detay sayfasına yönlendirmeyi dene
      try {
        final requests = await sl<MaintenanceRepository>().getRequests();
        final idMatch = RegExp(r'(\d+)').firstMatch(notification.link ?? '');
        MaintenanceRequest? matched;
        
        if (idMatch != null) {
          final idStr = idMatch.group(1);
          matched = requests.cast<MaintenanceRequest?>().firstWhere(
            (r) => r?.id.toString() == idStr,
            orElse: () => null,
          );
        }
        
        if (matched == null) {
          for (final r in requests) {
            final reqTitle = r.title.toLowerCase();
            if (reqTitle.isNotEmpty && (message.contains(reqTitle) || title.contains(reqTitle) || reqTitle.contains(title))) {
              matched = r;
              break;
            }
          }
        }

        if (matched != null && context.mounted) {
          if (isManager) {
            context.push('/manager/maintenance/${matched.id}', extra: matched);
            return;
          } else if (isStaff) {
            context.push('/staff/assigned/detail', extra: matched);
            return;
          }
        }
      } catch (_) {}

      if (context.mounted) {
        if (isManager) {
          context.push('/manager/maintenance');
        } else if (isResident) {
          context.push('/resident/operations');
        } else if (isStaff) {
          context.go('/staff');
        }
      }
      return;
    }

    if (text.contains('duyuru') || text.contains('announcement')) {
      try {
        final announcements = await sl<AnnouncementRepository>().getAnnouncements();
        final idMatch = RegExp(r'(\d+)').firstMatch(notification.link ?? '');
        Announcement? matched;
        
        if (idMatch != null) {
          final idStr = int.tryParse(idMatch.group(1) ?? '');
          if (idStr != null) {
            matched = announcements.cast<Announcement?>().firstWhere(
              (a) => a?.id == idStr,
              orElse: () => null,
            );
          }
        }
        
        if (matched == null) {
          for (final a in announcements) {
            final annTitle = a.title.toLowerCase();
            if (annTitle.isNotEmpty && (message.contains(annTitle) || title.contains(annTitle) || annTitle.contains(title))) {
              matched = a;
              break;
            }
          }
        }

        if (matched != null && context.mounted) {
          _showAnnouncementDialog(context, matched);
          return;
        }
      } catch (_) {}

      if (context.mounted) {
        if (isManager) {
          context.push('/manager/announcements');
        } else if (isResident) {
          context.push('/resident/operations');
        }
      }
      return;
    }

    if (text.contains('ödeme') || 
        text.contains('aidat') || 
        text.contains('borç') || 
        text.contains('tahsilat') || 
        text.contains('gider') || 
        text.contains('gelir') || 
        text.contains('kasa') || 
        text.contains('finance') || 
        text.contains('payment') || 
        text.contains('debt') || 
        text.contains('due')) {
      if (isManager) {
        context.push('/manager/finance');
      } else if (isResident) {
        context.push('/resident/finance');
      }
      return;
    }

    if (text.contains('doküman') || text.contains('belge') || text.contains('document') || text.contains('dosya')) {
      if (isManager) {
        context.push('/manager/more/documents');
      } else if (isResident) {
        context.push('/resident/documents');
      }
      return;
    }

    if (text.contains('sakin') || text.contains('kiracı') || text.contains('malik') || text.contains('üye') || text.contains('user')) {
      if (isManager) {
        context.push('/manager/users');
      } else if (isResident) {
        context.push('/resident/properties');
      }
      return;
    }

    if (text.contains('bina') || text.contains('blok') || text.contains('daire') || text.contains('apartman') || text.contains('property')) {
      if (isManager) {
        context.push('/manager/properties');
      } else if (isResident) {
        context.push('/resident/properties');
      }
      return;
    }

    if (text.contains('personel') || text.contains('staff')) {
      if (isManager) {
        context.push('/manager/more/staff');
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Shell'deki paylaşımlı NotificationCubit'i kullan, yeni instance OLUŞTURMA
    return Scaffold(
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
                      _navigateToTarget(context, notification);
                    },
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


  void _showAnnouncementDialog(BuildContext context, Announcement announcement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.campaign_rounded, color: AppColors.warning, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            announcement.title,
                            style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            announcement.apartmentName ?? 'Genel Duyuru',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Text(
                  announcement.content,
                  style: AppTextStyles.bodyLarge.copyWith(height: 1.5),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          announcement.createdByName ?? 'Yönetim',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(announcement.publishDate ?? announcement.createdAt),
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Kapat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
