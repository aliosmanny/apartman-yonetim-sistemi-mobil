import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/controllers/auth_cubit.dart';
import '../../../auth/presentation/controllers/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Profilim'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ── Üst Kısım (Avatar & İsim) ────────────────
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  padding: const EdgeInsets.only(bottom: 48, top: 24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Dekoratif daire
                      Positioned(
                        top: -30,
                        right: -30,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(13),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          // Avatar with ring
                          Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withAlpha(128), width: 3),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  (user?.firstName != null && user!.firstName.isNotEmpty)
                                      ? user.firstName.substring(0, 1).toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.fullName ?? 'Bilinmeyen Kullanıcı',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(38),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user?.role.displayName ?? 'Sakin',
                              style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Bilgiler ve Ayarlar ─────────────────────
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kişisel Bilgiler', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 12),
                        _buildInfoTile(Icons.phone_rounded, 'Telefon', user?.phone ?? '-'),
                        _buildInfoTile(Icons.email_rounded, 'E-Posta', user?.email ?? '-'),
                        if (user?.companyName != null)
                          _buildInfoTile(Icons.business_rounded, 'Şirket/Bina', user!.companyName!),

                        const SizedBox(height: 32),
                        const Text('Ayarlar', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 12),

                        _buildActionTile(
                          context,
                          icon: Icons.lock_rounded,
                          color: AppColors.primary,
                          title: 'Şifre Değiştir',
                          onTap: () => context.push('/resident/profile/change-password'),
                        ),
                        _buildActionTile(
                          context,
                          icon: Icons.notifications_rounded,
                          color: AppColors.warning,
                          title: 'Bildirim Tercihleri',
                          onTap: () => context.push('/resident/profile/notifications'),
                        ),


                        const SizedBox(height: 40),

                        // ── Çıkış Yap Butonu ─────────────────
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showLogoutDialog(context);
                            },
                            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                            label: const Text(
                              'Çıkış Yap',
                              style: TextStyle(color: AppColors.error, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: AppColors.error),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color color = AppColors.primary}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.logout_rounded, color: AppColors.error),
        ),
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 44),
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}