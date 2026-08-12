import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../controllers/maintenance_cubit.dart';

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
  bool _isLoading = false;

  final List<Map<String, String>> _categories = [
    {'value': 'plumbing', 'label': 'Tesisat'},
    {'value': 'electrical', 'label': 'Elektrik'},
    {'value': 'cleaning', 'label': 'Temizlik'},
    {'value': 'elevator', 'label': 'Asansör'},
    {'value': 'other', 'label': 'Diğer'},
  ];

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    
    try {
      await sl<MaintenanceCubit>().createRequest(
        title: _title,
        description: _description,
        category: _category,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _category,
                    isExpanded: true,
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
                ),
              ),
              const SizedBox(height: 20),

              Text('Konu / Başlık', style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Örn: Asansör Çalışmıyor',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Zorunlu alan' : null,
                onSaved: (val) => _title = val ?? '',
              ),
              const SizedBox(height: 20),

              Text('Detaylı Açıklama', style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Sorunu veya talebinizi detaylıca açıklayın...',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Zorunlu alan' : null,
                onSaved: (val) => _description = val ?? '',
              ),
              const SizedBox(height: 20),

              // Fotoğraf Yükleme (Mock UI)
              Text('Fotoğraf Ekle (İsteğe Bağlı)', style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fotoğraf yükleme yapım aşamasında.')),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_outlined, color: AppColors.textTertiary, size: 32),
                      const SizedBox(height: 8),
                      Text('Galeriden Seç', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Talebi Gönder',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
