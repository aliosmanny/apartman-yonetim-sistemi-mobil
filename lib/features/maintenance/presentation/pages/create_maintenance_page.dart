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
import '../../../dashboard/presentation/controllers/dashboard_cubit.dart';
import '../../../dashboard/presentation/controllers/dashboard_cubit.dart';

class CreateMaintenancePage extends StatefulWidget {
  const CreateMaintenancePage({super.key});

  @override
  State<CreateMaintenancePage> createState() => _CreateMaintenancePageState();
}

class _CreateMaintenancePageState extends State<CreateMaintenancePage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _category = 'plumbing';
  int? _selectedUnitId;
  XFile? _selectedImage;
  bool _isLoading = false;

  final DashboardCubit _dashboardCubit = sl<DashboardCubit>();

  final List<Map<String, String>> _categories = [
    {'value': 'plumbing', 'label': 'Tesisat'},
    {'value': 'electrical', 'label': 'Elektrik'},
    {'value': 'cleaning', 'label': 'Temizlik'},
    {'value': 'elevator', 'label': 'Asansör'},
    {'value': 'other', 'label': 'Diğer'},
  ];

  @override
  void initState() {
    super.initState();
    _dashboardCubit.fetchResidentDashboard();
  }

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
      await sl<MaintenanceCubit>().createRequest(
        title: _title,
        description: _description,
        category: _category,
        unitId: _selectedUnitId,
        image: _selectedImage,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Talebiniz başarıyla oluşturuldu.'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          behavior: SnackBarBehavior.fixed,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yeni Talep / Arıza Bildir'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kategori Seçin', style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_rounded,
                      size: 20, color: AppColors.textTertiary),
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
              const SizedBox(height: 20),
              Text('Daire Seçin', style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              BlocBuilder<DashboardCubit, DashboardState>(
                bloc: _dashboardCubit,
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ResidentDashboardLoaded) {
                    final units = state.data.units;
                    if (units.isEmpty) {
                      return const Text('Daire bulunamadı.');
                    }
                    return DropdownButtonFormField<int>(
                      value: _selectedUnitId,
                      isExpanded: true,
                      hint: const Text('Seçim yapınız'),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.home_work_rounded,
                            size: 20, color: AppColors.textTertiary),
                      ),
                      items: units.map((u) {
                        return DropdownMenuItem(
                          value: u.id,
                          child:
                              Text(u.display, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedUnitId = val);
                      },
                    );
                  }
                  return const Text('Daireler yüklenemedi.');
                },
              ),
              const SizedBox(height: 20),
              Text('Konu / Başlık', style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Örn: Asansör Çalışmıyor',
                  prefixIcon: Icon(Icons.title_rounded,
                      size: 20, color: AppColors.textTertiary),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Zorunlu alan' : null,
                onSaved: (val) => _title = val ?? '',
              ),
              const SizedBox(height: 20),
              Text('Detaylı Açıklama', style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Sorunu veya talebinizi detaylıca açıklayın...',
                  alignLabelWithHint: true,
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Zorunlu alan' : null,
                onSaved: (val) => _description = val ?? '',
              ),
              const SizedBox(height: 20),
              Text('Fotoğraf Ekle (İsteğe Bağlı)',
                  style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.25)),
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_a_photo_rounded,
                                  color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(height: 8),
                            Text('Galeriden Seç',
                                style: AppTextStyles.labelMedium
                                    .copyWith(color: AppColors.primary)),
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
                    onPressed: () => setState(() => _selectedImage = null),
                    child: const Text('Fotoğrafı Kaldır',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Talebi Gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
