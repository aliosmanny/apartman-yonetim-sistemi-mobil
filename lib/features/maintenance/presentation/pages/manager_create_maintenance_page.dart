import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../controllers/maintenance_cubit.dart';
import '../../../properties/presentation/controllers/properties_cubit.dart';
import '../../../properties/presentation/controllers/properties_state.dart';
import '../../../properties/domain/models/models.dart';
import '../../../staff/presentation/controllers/staff_cubit.dart';
import '../../../staff/domain/models/staff_member.dart';

class ManagerCreateMaintenancePage extends StatefulWidget {
  const ManagerCreateMaintenancePage({super.key});

  @override
  State<ManagerCreateMaintenancePage> createState() =>
      _ManagerCreateMaintenancePageState();
}

class _ManagerCreateMaintenancePageState
    extends State<ManagerCreateMaintenancePage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _category = 'other';
  String _status = 'pending';
  int? _selectedUnitId;
  int? _assignedStaffId;
  XFile? _selectedImage;
  bool _isLoading = false;

  final List<Map<String, String>> _categories = [
    {'value': 'plumbing', 'label': 'Su Tesisatı'},
    {'value': 'electrical', 'label': 'Elektrik'},
    {'value': 'cleaning', 'label': 'Temizlik'},
    {'value': 'elevator', 'label': 'Asansör'},
    {'value': 'security', 'label': 'Güvenlik'},
    {'value': 'common_area', 'label': 'Ortak Alan'},
    {'value': 'garden', 'label': 'Bahçe'},
    {'value': 'parking', 'label': 'Otopark'},
    {'value': 'other', 'label': 'Diğer'},
  ];

  final List<Map<String, String>> _statuses = [
    {'value': 'pending', 'label': 'Beklemede'},
    {'value': 'assigned', 'label': 'Personel Atandı'},
    {'value': 'in_progress', 'label': 'İşlem Devam Ediyor'},
    {'value': 'completed', 'label': 'Tamamlandı'},
    {'value': 'cancelled', 'label': 'İptal Edildi'},
  ];

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir daire seçin.')),
      );
      return;
    }
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      await context.read<MaintenanceCubit>().createRequest(
        title: _title,
        description: _description,
        category: _category,
        unitId: _selectedUnitId,
        image: _selectedImage,
        status: _status,
        assignedToStaffId: _assignedStaffId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bakım talebi başarıyla oluşturuldu.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 1024,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf seçilemedi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Bakım Talebi Ekle'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Talep Bilgileri ---
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Talep Bilgileri',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Talep Başlığı *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Zorunlu alan'
                              : null,
                          onSaved: (val) => _title = val ?? '',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Açıklama *',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Zorunlu alan'
                              : null,
                          onSaved: (val) => _description = val ?? '',
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _category,
                          decoration: const InputDecoration(
                            labelText: 'Kategori *',
                            border: OutlineInputBorder(),
                          ),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat['value'],
                              child: Text(cat['label']!),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _category = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // --- Durum ve Atama ---
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Durum ve Atama',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _status,
                          decoration: const InputDecoration(
                            labelText: 'Durum *',
                            border: OutlineInputBorder(),
                          ),
                          items: _statuses.map((s) {
                            return DropdownMenuItem(
                              value: s['value'],
                              child: Text(s['label']!),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _status = val);
                          },
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<StaffCubit, StaffState>(
                          builder: (context, state) {
                            List<StaffMember> staffList = [];
                            if (state is StaffLoaded) {
                              staffList = state.staffList
                                  .where((s) => s.isActive)
                                  .toList();
                            }
                            return DropdownButtonFormField<int>(
                              value: _assignedStaffId,
                              decoration: const InputDecoration(
                                labelText: 'Atanan Personel',
                                border: OutlineInputBorder(),
                              ),
                              hint: Text(state is StaffLoading
                                  ? 'Yükleniyor...'
                                  : 'Seçim yapınız'),
                              items: staffList.map((s) {
                                return DropdownMenuItem(
                                  value: s.id,
                                  child:
                                      Text('${s.userName} (${s.roleDisplay})'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() => _assignedStaffId = val);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // --- Daire Seçimi ---
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Daire Seçimi',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        BlocBuilder<PropertiesCubit, PropertiesState>(
                          builder: (context, state) {
                            List<AppUnit> units = [];
                            if (state is PropertiesLoaded) {
                              units = state.units;
                            }
                            return DropdownButtonFormField<int>(
                              value: _selectedUnitId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Daire *',
                                border: OutlineInputBorder(),
                              ),
                              hint: Text(state is PropertiesLoading
                                  ? 'Yükleniyor...'
                                  : 'Seçim yapınız'),
                              items: units.map((u) {
                                return DropdownMenuItem(
                                  value: u.id,
                                  child: Text(
                                      '${u.apartmentName} - ${u.blockName} - Daire ${u.number}',
                                      overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _selectedUnitId = val);
                              },
                              validator: (v) =>
                                  v == null ? 'Zorunlu alan' : null,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // --- Fotoğraf ---
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fotoğraf Ekle',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.primary.withOpacity(0.25)),
                            ),
                            child: _selectedImage == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                            Icons.add_a_photo_rounded,
                                            color: AppColors.primary,
                                            size: 24),
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Galeriden Seç',
                                          style: AppTextStyles.labelMedium
                                              .copyWith(
                                                  color: AppColors.primary)),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      File(_selectedImage!.path),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                          ),
                        ),
                        if (_selectedImage != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  setState(() => _selectedImage = null),
                              child: const Text('Fotoğrafı Kaldır',
                                  style: TextStyle(color: AppColors.error)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B1B2F),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Kaydet',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
    );
  }
}
