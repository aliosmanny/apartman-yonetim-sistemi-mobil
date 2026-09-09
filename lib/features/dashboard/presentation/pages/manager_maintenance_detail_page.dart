import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../maintenance/domain/models/maintenance_request.dart';
import '../../../maintenance/presentation/controllers/maintenance_cubit.dart';
import '../../../staff/presentation/controllers/staff_cubit.dart';
import '../../../staff/domain/models/staff_member.dart';

class ManagerMaintenanceDetailPage extends StatefulWidget {
  final MaintenanceRequest request;

  const ManagerMaintenanceDetailPage({super.key, required this.request});

  @override
  State<ManagerMaintenanceDetailPage> createState() =>
      _ManagerMaintenanceDetailPageState();
}

class _ManagerMaintenanceDetailPageState
    extends State<ManagerMaintenanceDetailPage> {
  late String _selectedStatus;
  late TextEditingController _notesController;
  int? _selectedStaffId;
  late StaffCubit
      _staffCubit; // Aynı instance'ı tut (factory her seferinde yeni yaratır!)

  /// Backend kısa kodlarını uzun forma normalize et
  static String _normalize(String status) {
    switch (status) {
      case 'p':
        return 'pending';
      case 'a':
        return 'assigned';
      case 'i':
        return 'in_progress';
      case 'c':
        return 'completed';
      case 'x':
        return 'cancelled';
      default:
        return status;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedStatus = _normalize(widget.request.status);
    _notesController =
        TextEditingController(text: widget.request.adminNotes ?? '');
    _selectedStaffId = widget.request.assignedTo;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: Text(request.title, style: AppTextStyles.titleMedium),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Durum ───────────────────────────────────
                _buildLabeledDropdown<String>(
                  label: 'Durum*',
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(
                        value: 'pending', child: Text('Beklemede')),
                    DropdownMenuItem(
                        value: 'assigned', child: Text('Personel Atandı')),
                    DropdownMenuItem(
                        value: 'in_progress',
                        child: Text('İşlem Devam Ediyor')),
                    DropdownMenuItem(
                        value: 'completed', child: Text('Tamamlandı')),
                    DropdownMenuItem(
                        value: 'cancelled', child: Text('İptal Edildi')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStatus = val);
                  },
                ),
                const Divider(height: 32),

                // ── Atanan Personel (DB'den) ─────────────────
                BlocBuilder<StaffCubit, StaffState>(
                  builder: (ctx, staffState) {
                    List<StaffMember> staffList = [];
                    if (staffState is StaffLoaded) {
                      staffList = staffState.staffList;
                    }

                    // _selectedStaffId listede yoksa null'a düşür
                    final validIds = staffList.map((s) => s.id).toSet();
                    final safeId = validIds.contains(_selectedStaffId)
                        ? _selectedStaffId
                        : null;

                    return _buildLabeledDropdown<int>(
                      label: 'Atanan Personel',
                      value: safeId,
                      hint: staffState is StaffLoading
                          ? 'Yükleniyor...'
                          : 'Personel Seçin',
                      items: staffList
                          .map((s) => DropdownMenuItem<int>(
                                value: s.id,
                                child: Text(
                                  '${s.userName} - ${s.roleDisplay}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedStaffId = val;
                          if (val != null && _selectedStatus == 'pending') {
                            _selectedStatus = 'assigned';
                          }
                        });
                      },
                    );
                  },
                ),
                const Divider(height: 32),

                // ── Salt okunur bilgiler ─────────────────────
                _infoRow('Talep Başlığı', request.title),
                const Divider(height: 32),
                _infoRow('Açıklama', request.description),
                const Divider(height: 32),
                _infoRow('Daire', request.unitDisplay ?? 'Bilinmiyor'),
                const Divider(height: 32),
                _infoRow('Kategori', request.safeCategoryDisplay),
                const Divider(height: 32),
                _infoRow('Talep Sahibi', request.creatorName ?? 'Bilinmiyor'),
                const Divider(height: 32),
                _imageRow(context, 'Fotoğraf', request.imageUrl),
                const Divider(height: 32),
                _infoRow('Personel Notu / Cevabı', request.adminNotes ?? '-'),
                const Divider(height: 32),
                _imageRow(context, 'Personel Fotoğrafı', null),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await context.read<MaintenanceCubit>().updateRequestStatus(
                      request.id,
                      _selectedStatus, // artık her zaman uzun form
                      assignedStaffId: _selectedStaffId,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Değişiklikler başarıyla kaydedildi'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hata: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Kaydet'),
              ),
            ),
          ),
        ),
      );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label,
              style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 3,
          child: Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _imageRow(BuildContext context, String label, String? imageUrl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label,
              style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 3,
          child: imageUrl != null && imageUrl.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.all(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              InteractiveViewer(
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      const Center(
                                    child: Icon(Icons.error_outline,
                                        color: Colors.white, size: 48),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white, size: 30),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text('Fotoğrafı Gör',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline)),
                )
              : Text('-',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _buildLabeledDropdown<T>({
    required String label,
    required T? value,
    String? hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(label,
              style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<T>(
            value: value,
            hint: hint != null ? Text(hint) : null,
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
