import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class StaffSettingsPage extends StatefulWidget {
  const StaffSettingsPage({super.key});

  @override
  State<StaffSettingsPage> createState() => _StaffSettingsPageState();
}

class _StaffSettingsPageState extends State<StaffSettingsPage> {
  bool _pushNotificationsEnabled = true;
  bool _smsNotificationsEnabled = false;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Türkçe';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Uygulama Ayarları'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Bildirim Ayarları ──
            const Text('Bildirim Ayarları', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('Push Bildirimleri', style: AppTextStyles.bodyMedium),
                    subtitle: const Text('Yeni iş atamalarında anında bildir', style: AppTextStyles.bodySmall),
                    value: _pushNotificationsEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _pushNotificationsEnabled = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    title: const Text('SMS Bildirimleri', style: AppTextStyles.bodyMedium),
                    subtitle: const Text('Önemli veya acil durumlarda', style: AppTextStyles.bodySmall),
                    value: _smsNotificationsEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _smsNotificationsEnabled = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Görünüm Ayarları ──
            const Text('Görünüm', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: SwitchListTile.adaptive(
                title: const Text('Karanlık Tema', style: AppTextStyles.bodyMedium),
                subtitle: const Text('Sistem temasına göre ayarla', style: AppTextStyles.bodySmall),
                value: _darkModeEnabled,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => _darkModeEnabled = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tema desteği yakında eklenecek.')),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // ── Dil Ayarları ──
            const Text('Dil', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                title: const Text('Uygulama Dili', style: AppTextStyles.bodyMedium),
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    items: ['Türkçe', 'English']
                        .map((l) => DropdownMenuItem(value: l, child: Text(l, style: AppTextStyles.bodyMedium)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLanguage = val);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // ── Hakkında ──
            Center(
              child: Column(
                children: [
                  Text('Apartman Yönetim Sistemi - Personel', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textTertiary)),
                  const SizedBox(height: 4),
                  Text('Versiyon 1.0.0', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
