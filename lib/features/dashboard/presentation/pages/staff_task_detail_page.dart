import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../maintenance/domain/models/maintenance_request.dart';

class StaffTaskDetailPage extends StatelessWidget {
  final MaintenanceRequest task;

  const StaffTaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('İş Detayı'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── İş Bilgileri ──
            Container(
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(task.safeCategoryDisplay, style: AppTextStyles.labelSmall),
                      ),
                      const Spacer(),
                      Text('Bugün, 14:30', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(task.title, style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 8),
                  Text(task.description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.apartment_rounded, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Text('A Blok D:12', style: AppTextStyles.titleMedium),
                      const Spacer(),
                      Text('Ahmet Yılmaz', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (task.adminNotes != null) ...[
              Text('Yönetici Notu', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_rounded, color: AppColors.warning.withOpacity(0.9)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        task.adminNotes!,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Tamamlama İşlemleri ──
            Text('Tamamlama İşlemleri', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fotoğraf Ekle', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fotoğraf seçici açılıyor...')),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_a_photo_rounded, size: 22, color: AppColors.primary),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tamamlanan işin fotoğrafını yükleyin',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Personel Notu', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  const TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Yapılan işlemleri kısaca açıklayın...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('İş başarıyla tamamlandı olarak işaretlendi!')),
                );
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check_circle_rounded),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maintenanceCompleted,
                foregroundColor: Colors.white,
              ),
              label: const Text('İşi Tamamla'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}