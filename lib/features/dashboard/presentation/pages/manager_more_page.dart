import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/controllers/auth_cubit.dart';
import '../../../auth/presentation/controllers/auth_state.dart';

class ManagerMorePage extends StatelessWidget {
  const ManagerMorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final userName = user?.fullName ?? 'Yönetici';
    final userEmail = user?.email ?? 'yonetici@apartman.com';
    final userRole = user?.role.displayName ?? 'Sistem Yöneticisi';
    final initial = userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'Y';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Menü'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Profil Özeti ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: AppTextStyles.displayMedium.copyWith(color: AppColors.textOnPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, style: AppTextStyles.titleLarge.copyWith(color: AppColors.textOnPrimary)),
                        const SizedBox(height: 4),
                        Text(userEmail, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textOnPrimary.withOpacity(0.75))),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(userRole, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textOnPrimary)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Yönetim İşlemleri ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Yönetim İşlemleri', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
              ),
            ),
            const SizedBox(height: 8),
            _MenuGroup(
              children: [
                _MenuListItem(
                  icon: Icons.campaign_rounded,
                  iconColor: AppColors.primary,
                  title: 'Duyuru Yayınla',
                  subtitle: 'Tüm sakinlere veya belirli bloklara duyuru gönderin',
                  onTap: () => context.pushNamed('createAnnouncement'),
                ),
                _MenuListItem(
                  icon: Icons.upload_file_rounded,
                  iconColor: AppColors.secondary,
                  title: 'Belge Yükle',
                  subtitle: 'Gelir gider tablosu, toplantı kararları vb. yükleyin',
                  onTap: () => context.pushNamed('managerDocuments'),
                ),
                _MenuListItem(
                  icon: Icons.people_rounded,
                  iconColor: AppColors.warning,
                  title: 'Personel Yönetimi',
                  subtitle: 'Apartman görevlileri ve ustaları yönetin',
                  onTap: () => context.pushNamed('managerStaff'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Hesap ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Hesap', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
              ),
            ),
            const SizedBox(height: 8),
            _MenuGroup(
              children: [
                _MenuListItem(
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.textPrimary,
                  title: 'Profil Bilgileri',
                  onTap: () => context.pushNamed('managerProfile'),
                ),
                _MenuListItem(
                  icon: Icons.settings_outlined,
                  iconColor: AppColors.textPrimary,
                  title: 'Uygulama Ayarları',
                  onTap: () => context.pushNamed('managerSettings'),
                ),
                _MenuListItem(
                  icon: Icons.logout_rounded,
                  iconColor: AppColors.error,
                  title: 'Çıkış Yap',
                  showArrow: false,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
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

/// Menü kartlarını saran, gölgeli ortak container.
class _MenuGroup extends StatelessWidget {
  final List<Widget> children;

  const _MenuGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _MenuListItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showArrow;

  const _MenuListItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: AppTextStyles.titleMedium),
      subtitle: subtitle != null
          ? Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(subtitle!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
      )
          : null,
      trailing: showArrow ? const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary) : null,
    );
  }
}