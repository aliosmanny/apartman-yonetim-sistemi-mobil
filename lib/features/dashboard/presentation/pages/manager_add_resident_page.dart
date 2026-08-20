import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class ManagerAddResidentPage extends StatefulWidget {
  const ManagerAddResidentPage({super.key});

  @override
  State<ManagerAddResidentPage> createState() => _ManagerAddResidentPageState();
}

class _ManagerAddResidentPageState extends State<ManagerAddResidentPage> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedBlock;
  final TextEditingController _flatController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _residentType = 'Kiracı'; // Kiracı veya Ev Sahibi

  @override
  void dispose() {
    _flatController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveResident() {
    if (_formKey.currentState!.validate()) {
      // TODO: Gerçek veritabanına veya stateli yönetimine (Cubit/Bloc) kayıt eklenecek.
      // Şimdilik sadece mock olarak başarı mesajı verip geri dönüyoruz.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} başarıyla eklendi!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yeni Sakin Ekle'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Daire Bilgileri ───────────────────────
              const Text('Daire Bilgileri', style: AppTextStyles.titleMedium),
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
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Blok Seçimi',
                        prefixIcon: Icon(Icons.domain),
                      ),
                      value: _selectedBlock,
                      items: ['A Blok', 'B Blok', 'C Blok']
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedBlock = val),
                      validator: (val) => val == null ? 'Lütfen bir blok seçin' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _flatController,
                      decoration: const InputDecoration(
                        labelText: 'Daire Numarası',
                        prefixIcon: Icon(Icons.meeting_room_outlined),
                        hintText: 'Örn: 12',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) => (val == null || val.isEmpty) ? 'Daire numarası zorunludur' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Sakin Bilgileri ───────────────────────
              const Text('Sakin Bilgileri', style: AppTextStyles.titleMedium),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Ad Soyad',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? 'Ad soyad zorunludur' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefon Numarası',
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: '05XX XXX XX XX',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (val) => (val == null || val.isEmpty) ? 'Telefon numarası zorunludur' : null,
                    ),
                    const SizedBox(height: 24),
                    const Text('Sakin Durumu', style: AppTextStyles.labelMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Kiracı', style: AppTextStyles.bodyMedium),
                            value: 'Kiracı',
                            groupValue: _residentType,
                            onChanged: (val) => setState(() => _residentType = val!),
                            contentPadding: EdgeInsets.zero,
                            activeColor: AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Ev Sahibi', style: AppTextStyles.bodyMedium),
                            value: 'Ev Sahibi',
                            groupValue: _residentType,
                            onChanged: (val) => setState(() => _residentType = val!),
                            contentPadding: EdgeInsets.zero,
                            activeColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── Kaydet Butonu ─────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveResident,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Sakini Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
