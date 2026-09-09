import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class ManagerServicesPage extends StatelessWidget {
  const ManagerServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Operasyon & Hizmetler'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          _buildServiceCard(
            context,
            icon: Icons.badge_outlined,
            iconColor: AppColors.primary,
            title: 'Personeller',
            subtitle: 'Personel ve görev yönetimi',
            onTap: () => context.pushNamed('managerStaff'),
          ),
          const SizedBox(height: 12),
          _buildServiceCard(
            context,
            icon: Icons.build_outlined,
            iconColor: AppColors.secondary,
            title: 'Bakım Talepleri',
            subtitle: 'Arıza ve hizmet talepleri',
            onTap: () => context.push('/manager/maintenance'),
          ),
          const SizedBox(height: 12),
          _buildServiceCard(
            context,
            icon: Icons.campaign_outlined,
            iconColor: AppColors.warning,
            title: 'Duyurular',
            subtitle: 'Duyuruları yönetin ve yeni duyuru yayınlayın',
            onTap: () => context.push('/manager/announcements'),
          ),
          const SizedBox(height: 12),
          _buildServiceCard(
            context,
            icon: Icons.folder_outlined,
            iconColor: AppColors.textPrimary,
            title: 'Dokümanlar',
            subtitle: 'Gelir gider tabloları, kararlar',
            onTap: () => context.pushNamed('managerDocuments'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}


