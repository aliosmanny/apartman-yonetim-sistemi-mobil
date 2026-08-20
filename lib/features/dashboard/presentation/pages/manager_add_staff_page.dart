import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class ManagerAddStaffPage extends StatefulWidget {
  const ManagerAddStaffPage({super.key});

  @override
  State<ManagerAddStaffPage> createState() => _ManagerAddStaffPageState();
}

class _ManagerAddStaffPageState extends State<ManagerAddStaffPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedRole;

  final List<String> _staffRoles = ['Tesisat / Genel Bakım', 'Elektrik Uzmanı', 'Temizlik Personeli', 'Güvenlik', 'Diğer'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveStaff() {
    if (_formKey.currentState!.validate()) {
      final newStaff = {
        'name': _nameController.text,
        'role': _selectedRole ?? 'Diğer',
        'phone': _phoneController.text,
        'status': 'Aktif',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personel başarıyla kaydedildi!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop(newStaff);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yeni Personel Ekle'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Personel Bilgileri', style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
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
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Ad Soyad',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        hintText: 'Örn: Ahmet Yılmaz',
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? 'Ad Soyad zorunludur' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefon Numarası',
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: '0555 123 45 67',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (val) => (val == null || val.isEmpty) ? 'Telefon numarası zorunludur' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Görevi / Rolü',
                        prefixIcon: Icon(Icons.work_outline_rounded),
                      ),
                      value: _selectedRole,
                      items: _staffRoles
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedRole = val),
                      validator: (val) => val == null ? 'Lütfen görev seçin' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveStaff,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
