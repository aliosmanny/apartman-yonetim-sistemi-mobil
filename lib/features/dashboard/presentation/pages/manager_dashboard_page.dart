import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/controllers/auth_cubit.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/dashboard_cubit.dart';
import '../../../notifications/presentation/controllers/notification_cubit.dart';
import '../../../../core/di/injection.dart';
import 'package:intl/intl.dart'; // Para birimi formatlama için eklendi
import '../../../properties/presentation/controllers/properties_cubit.dart';
import '../../../finance/presentation/controllers/finance_cubit.dart';
import '../../../users/presentation/controllers/user_cubit.dart';

class ManagerDashboardPage extends StatefulWidget {
  const ManagerDashboardPage({super.key});

  @override
  State<ManagerDashboardPage> createState() => _ManagerDashboardPageState();
}

class _ManagerDashboardPageState extends State<ManagerDashboardPage> {
  @override
  void initState() {
    super.initState();
    // İlk sekme ziyaretlerindeki 1 saniyelik yükleme ekranlarını sıfırlamak için verileri arka planda önceden yükle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<PropertiesCubit>().fetchAll();
      sl<FinanceCubit>().fetchManagerFinance();
      sl<UserCubit>().fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Para birimi formatter (Örn: 124.500 ₺)
    final formatCurrency = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardCubit>(
          create: (context) => sl<DashboardCubit>()..fetchManagerDashboard(),
        ),
        BlocProvider<NotificationCubit>(
          create: (context) => sl<NotificationCubit>()..fetchNotifications(),
        ),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final user = authState is AuthAuthenticated ? authState.user : null;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: CustomScrollView(
              slivers: [
              SliverAppBar(
                expandedHeight: 170,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: Stack(
                        children: [
                          // Dekoratif arka plan daireleri
                          Positioned(
                            top: -40,
                            right: -40,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withAlpha(13),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -20,
                            left: -20,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withAlpha(10),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
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
                                            'İyi çalışmalar, ${user?.firstName ?? 'Yönetici'}!',
                                            style: AppTextStyles.headlineMedium.copyWith(
                                              color: AppColors.textOnPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Yönetim Paneli Özeti',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.textOnPrimary.withAlpha(179),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const NotificationBell(routePath: '/manager/notifications'),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(46),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withAlpha(89),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          (user?.firstName != null && user!.firstName.isNotEmpty)
                                              ? user.firstName.substring(0, 1).toUpperCase()
                                              : 'Y',
                                          style: AppTextStyles.headlineSmall.copyWith(
                                            color: AppColors.textOnPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
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

                    // ── Finansal Özet Kartları ─────────────────
                    BlocBuilder<DashboardCubit, DashboardState>(
                      builder: (context, state) {
                        if (state is DashboardLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is DashboardError) {
                          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                        } else if (state is ManagerDashboardLoaded) {
                          final data = state.data;
                          return Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Kasa Bakiyesi',
                                  amount: formatCurrency.format(data.netBalance),
                                  icon: Icons.account_balance_wallet_rounded,
                                  color: AppColors.debtPaid,
                                  trend: '+%5', // Gerçek veride yok, mockup kaldı
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Gecikmiş Alacak',
                                  amount: formatCurrency.format(data.totalUnpaidAmount),
                                  icon: Icons.money_off_rounded,
                                  color: AppColors.debtOverdue,
                                  trend: '${data.overdueCount} Daire',
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 28),

                    // ── Hızlı Eylemler ────────────────────────
                    Text('Hızlı Eylemler', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildActionBtn(context, Icons.campaign_rounded, 'Duyuru\nYayınla', AppColors.primary, '/manager/announcements'),
                          _buildActionBtn(context, Icons.receipt_long_rounded, 'Gider\nEkle', AppColors.warning, '/manager/finance'),
                          _buildActionBtn(context, Icons.person_add_rounded, 'Sakin\nEkle', AppColors.secondary, '/manager/users'),
                          _buildActionBtn(context, Icons.engineering_rounded, 'İş\nAta', AppColors.success, '/manager/maintenance'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Bekleyen Talepler Özeti ───────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text('Son Talepler', style: AppTextStyles.headlineSmall),
                        ),
                        TextButton(
                          onPressed: () => context.go('/manager/maintenance'),
                          child: const Text('Tümü'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<DashboardCubit, DashboardState>(
                      builder: (context, state) {
                        if (state is ManagerDashboardLoaded) {
                          if (state.data.recentMaintenance.isEmpty) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Bekleyen talep yok.'),
                            ));
                          }
                          return Column(
                            children: state.data.recentMaintenance.take(3).map((req) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: _buildPendingRequestCard(
                                  title: req.title,
                                  unit: req.unit ?? 'Ortak Alan',
                                  timeAgo: req.createdAt.split('T').first, // Basit tarih
                                  status: req.status,
                                ),
                              );
                            }).toList(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
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

  Widget _buildStatCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst renkli accent bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withAlpha(26),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        trend,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(amount, style: AppTextStyles.amountMedium.copyWith(fontSize: 17)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context, IconData icon, String label, Color color, String route) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withAlpha(200)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(77),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequestCard({
    required String title,
    required String unit,
    required String timeAgo,
    required String status,
  }) {
    // Statüye göre renk belirleme
    Color statusColor;
    if (status == 'pending' || status == 'p') {
      statusColor = AppColors.maintenancePending;
    } else if (status == 'assigned' || status == 'a' || status == 'in_progress' || status == 'i') {
      statusColor = AppColors.primary;
    } else {
      statusColor = AppColors.maintenanceCompleted;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.build_rounded, color: statusColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(unit, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                              const Spacer(),
                              Text(timeAgo, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(title, style: AppTextStyles.titleMedium),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
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