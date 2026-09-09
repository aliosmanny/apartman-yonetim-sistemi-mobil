import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Bildirim tercihleri yerel olarak (SharedPreferences) saklanır.
/// Backend'de /users/notification-preferences/ endpoint'i olmadığından
/// sadece cihaz üzerinde kalıcı hale getirilir.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _pushAnnouncements = true;
  bool _pushDebts = true;
  bool _pushMaintenance = true;
  bool _emailNewsletter = false;
  bool _smsAlerts = true;

  bool _isLoading = true;
  bool _isSaving = false;

  static const _kPushAnnouncements = 'notif_push_announcements';
  static const _kPushDebts = 'notif_push_debts';
  static const _kPushMaintenance = 'notif_push_maintenance';
  static const _kEmailNewsletter = 'notif_email_newsletter';
  static const _kSmsAlerts = 'notif_sms_alerts';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _pushAnnouncements = prefs.getBool(_kPushAnnouncements) ?? true;
          _pushDebts = prefs.getBool(_kPushDebts) ?? true;
          _pushMaintenance = prefs.getBool(_kPushMaintenance) ?? true;
          _emailNewsletter = prefs.getBool(_kEmailNewsletter) ?? false;
          _smsAlerts = prefs.getBool(_kSmsAlerts) ?? true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kPushAnnouncements, _pushAnnouncements);
      await prefs.setBool(_kPushDebts, _pushDebts);
      await prefs.setBool(_kPushMaintenance, _pushMaintenance);
      await prefs.setBool(_kEmailNewsletter, _emailNewsletter);
      await prefs.setBool(_kSmsAlerts, _smsAlerts);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bildirim tercihleriniz başarıyla kaydedildi!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kaydedilirken hata oluştu: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bildirim Tercihleri'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Uygulama İçi Bildirimler',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildSettingsGroup(
                  children: [
                    _buildSwitchTile(
                      title: 'Yeni Duyurular',
                      subtitle: 'Yönetici yeni bir duyuru yayınladığında',
                      value: _pushAnnouncements,
                      onChanged: (val) =>
                          setState(() => _pushAnnouncements = val),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      title: 'Borç ve Aidat Hatırlatmaları',
                      subtitle:
                          'Yeni bir borç eklendiğinde veya son ödeme tarihi yaklaştığında',
                      value: _pushDebts,
                      onChanged: (val) => setState(() => _pushDebts = val),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      title: 'Talep Durum Güncellemeleri',
                      subtitle:
                          'Oluşturduğunuz taleplerin durumu değiştiğinde (örn: Çözüldü)',
                      value: _pushMaintenance,
                      onChanged: (val) =>
                          setState(() => _pushMaintenance = val),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Diğer İletişim Kanalları',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildSettingsGroup(
                  children: [
                    _buildSwitchTile(
                      title: 'E-Posta Bülteni',
                      subtitle: 'Aylık apartman özeti ve önemli e-postalar',
                      value: _emailNewsletter,
                      onChanged: (val) =>
                          setState(() => _emailNewsletter = val),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      title: 'SMS Uyarıları',
                      subtitle:
                          'Sadece çok acil durumlarda (Su kesintisi vb.) kısa mesaj',
                      value: _smsAlerts,
                      onChanged: (val) => setState(() => _smsAlerts = val),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _savePreferences,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Ayarları Kaydet',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSettingsGroup({required List<Widget> children}) {
    return Container(
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
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title,
          style:
              AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(subtitle,
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textSecondary)),
      ),
      activeColor: AppColors.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
