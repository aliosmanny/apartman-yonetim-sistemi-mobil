import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/controllers/auth_cubit.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../../finance/presentation/controllers/finance_cubit.dart';
import '../../../announcements/domain/models/announcement.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../controllers/dashboard_cubit.dart';
import '../../../notifications/presentation/controllers/notification_cubit.dart';
import 'package:intl/intl.dart';

class ResidentDashboardPage extends StatelessWidget {
  const ResidentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<FinanceCubit>()..fetchDebts()),
        BlocProvider(create: (context) => sl<DashboardCubit>()..fetchResidentDashboard()),
        BlocProvider(create: (context) => sl<NotificationCubit>()..fetchNotifications()),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 150,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: const Color(0xFF0D9488),
                  flexibleSpace: FlexibleSpaceBar(
                    background: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0D9488), Color(0xFF0891B2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -30,
                              right: -30,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Merhaba, ${user?.firstName ?? ''}! 👋',
                                              style: AppTextStyles.headlineMedium.copyWith(
                                                color: AppColors.textOnPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              user?.role.displayName ?? '',
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.textOnPrimary.withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const NotificationBell(routePath: '/resident/notifications'),
                                      const SizedBox(width: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          onPressed: () => context.read<AuthCubit>().logout(),
                                          icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                                          tooltip: 'Çıkış Yap',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Borç Kartı ────────────────────
                      _DebtCard(),
                      const SizedBox(height: 20),

                      // ── Hızlı İşlemler ────────────────
                      Text('Hızlı İşlemler', style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 12),
                      _ResidentQuickActions(),
                      const SizedBox(height: 20),

                      // ── Son Duyurular ─────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Text('Son Duyurular', style: AppTextStyles.headlineSmall),
                          ),
                          TextButton(
                            onPressed: () => context.go('/resident/announcements'),
                            child: const Text('Tümü'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _AnnouncementPlaceholder(),
                      const SizedBox(height: 80),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        double totalUnpaid = 0.0;
        bool hasOverdue = false;
        String statusText = 'Yükleniyor...';
        String amountText = '-- ₺';
        Color statusColor = Colors.white.withOpacity(0.15);

        if (state is ResidentDashboardLoaded) {
          totalUnpaid = state.data.totalUnpaid;
          hasOverdue = state.data.overdueCount > 0;
          
          final formatCurrency = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
          amountText = formatCurrency.format(totalUnpaid);

          if (totalUnpaid == 0) {
            statusText = 'Borç Yok';
            statusColor = AppColors.debtPaid.withOpacity(0.6);
          } else if (hasOverdue) {
            statusText = 'Gecikmiş';
            statusColor = AppColors.debtOverdue.withOpacity(0.85);
          } else {
            statusText = 'Ödenmedi';
            statusColor = Colors.white.withOpacity(0.2);
          }
        } else if (state is DashboardError) {
          statusText = 'Hata';
          amountText = '0 ₺';
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Toplam Güncel Borç',
                    style: AppTextStyles.labelMedium.copyWith(color: Colors.white.withOpacity(0.8)),
                  ),
                  const Spacer(),
                  if (state is DashboardLoading)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                amountText,
                style: AppTextStyles.amountLarge.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Tüm ödenmemiş aidat ve giderleriniz',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/resident/debts');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Detayları Gör / Öde', style: AppTextStyles.buttonMedium.copyWith(fontSize: 15)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResidentQuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (icon: Icons.build_rounded, label: 'Talep\nOluştur', color: AppColors.warning, route: '/resident/maintenance/create', isPush: true),
      (icon: Icons.campaign_rounded, label: 'Duyurular', color: AppColors.primary, route: '/resident/announcements', isPush: false),
      (icon: Icons.folder_rounded, label: 'Belgeler', color: AppColors.secondary, route: '/resident/documents', isPush: true),
      (icon: Icons.person_rounded, label: 'Profilim', color: AppColors.success, route: '/resident/profile', isPush: false),
    ];

    return Row(
      children: actions
          .map((a) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () {
              if (a.isPush) {
                context.push(a.route);
              } else {
                context.go(a.route);
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: a.color.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: a.color.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(a.icon, color: a.color, size: 24),
                  const SizedBox(height: 6),
                  Text(
                    a.label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: a.color,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ))
          .toList(),
    );
  }
}

class _AnnouncementPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DashboardError) {
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
        } else if (state is ResidentDashboardLoaded) {
          if (state.data.recentAnnouncements.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Henüz duyuru yok', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 4),
                        Text('Yönetici duyuru paylaşınca burada görünecek.', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          final latest = state.data.recentAnnouncements.first;
          // Duyuru başlığında 'acil' geçiyorsa kırmızı yap (API'de isImportant alanı yok)
          final isImportant = latest.title.toLowerCase().contains('acil');

          return InkWell(
            onTap: () => context.go('/resident/announcements'),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isImportant ? AppColors.error.withOpacity(0.5) : AppColors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isImportant ? AppColors.error : Colors.black).withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isImportant ? AppColors.error.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isImportant ? Icons.warning_amber_rounded : Icons.campaign_rounded,
                      color: isImportant ? AppColors.error : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          latest.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: isImportant ? AppColors.error : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          latest.content ?? 'Detaylar için tıklayın...',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}