import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../maintenance/domain/models/maintenance_request.dart';

class ManagerMaintenanceDetailPage extends StatefulWidget {
  final Map<String, dynamic> item; // request, unit, resident

  const ManagerMaintenanceDetailPage({super.key, required this.item});

  @override
  State<ManagerMaintenanceDetailPage> createState() => _ManagerMaintenanceDetailPageState();
}

class _ManagerMaintenanceDetailPageState extends State<ManagerMaintenanceDetailPage> {
  late String _selectedStatus;
  late TextEditingController _notesController;
  String? _selectedStaff;

  @override
  void initState() {
    super.initState();
    final request = widget.item['request'] as MaintenanceRequest;
    _selectedStatus = request.status;
    _notesController = TextEditingController(text: request.adminNotes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.maintenancePending;
      case 'in_progress':
        return AppColors.maintenanceInProgress;
      case 'resolved':
        return AppColors.maintenanceCompleted;
      case 'rejected':
        return AppColors.maintenanceCancelled;
      default:
        return AppColors.textTertiary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'İşleme Alınmadı';
      case 'in_progress':
        return 'İşlemde';
      case 'resolved':
        return 'Çözüldü';
      case 'rejected':
        return 'İptal Edildi';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.item['request'] as MaintenanceRequest;
    final unit = widget.item['unit'] as String;
    final resident = widget.item['resident'] as String;
    final statusColor = _statusColor(_selectedStatus);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Talep Detayı'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Talep Bilgileri ──
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
                        child: Text(request.safeCategoryDisplay, style: AppTextStyles.labelSmall),
                      ),
                      const SizedBox(width: 8),
                      // ── Canlı durum rozeti ──
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _statusLabel(_selectedStatus),
                              style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(_formatDate(request.createdAt), style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(request.title, style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 8),
                  Text(request.description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
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
                        child: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Text(resident, style: AppTextStyles.titleMedium),
                      const Spacer(),
                      Text(unit, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Yönetici İşlemleri ──
            Text('Yönetici İşlemleri', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
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
                  Text('Durum', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.flag_rounded, size: 20, color: statusColor),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'pending', child: Text('İşleme Alınmadı')),
                      DropdownMenuItem(value: 'in_progress', child: Text('İşlemde')),
                      DropdownMenuItem(value: 'resolved', child: Text('Çözüldü')),
                      DropdownMenuItem(value: 'rejected', child: Text('İptal Edildi')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
                  ),
                  const SizedBox(height: 20),

                  Text('Personele Ata', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedStaff,
                    hint: const Text('Personel Seçin'),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.engineering_rounded, size: 20, color: AppColors.textTertiary),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'staff1', child: Text('Hasan Usta (Tesisat)')),
                      DropdownMenuItem(value: 'staff2', child: Text('Ali Veli (Elektrik)')),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedStaff = val);
                    },
                  ),
                  const SizedBox(height: 20),

                  Text('Yönetici Notu', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Sakinlerin görebileceği notlar...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stil artık ElevatedButtonTheme'den geliyor — tekrar tanımlamaya gerek yok
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Değişiklikler kaydedildi')),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Değişiklikleri Kaydet'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}