import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/models/user.dart';
import '../controllers/user_cubit.dart';

class UserFormPage extends StatefulWidget {
  final UserCubit cubit;
  final AppUser? user; // Null if create, not null if edit

  const UserFormPage({super.key, required this.cubit, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _companyController;
  
  String _selectedRole = 'owner';
  bool _isStaff = true;
  bool _isSuperuser = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _firstNameController = TextEditingController(text: widget.user?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.user?.lastName ?? '');
    _companyController = TextEditingController(text: widget.user?.companyName ?? '');
    
    if (widget.user != null) {
      _selectedRole = widget.user!.role;
      _isStaff = widget.user!.isStaff;
      _isSuperuser = widget.user!.isSuperuser;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final data = {
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'company_name': _companyController.text.trim(),
      'role': _selectedRole,
      'is_staff': _isStaff,
      'is_superuser': _isSuperuser,
    };
    
    try {
      if (widget.user == null) {
        // Create user requires a password usually, but wait, this is user management.
        // Usually creating users from manager panel might need a default password or trigger a reset link.
        // Django model allows creating without password but they can't login until they reset.
        await widget.cubit.createUser(data);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kullanıcı eklendi'), backgroundColor: AppColors.success));
      } else {
        await widget.cubit.updateUser(widget.user!.id, data);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kullanıcı güncellendi'), backgroundColor: AppColors.success));
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Kullanıcıyı Düzenle' : 'Yeni Kullanıcı'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Giriş Bilgileri'),
              _buildTextField('Telefon Numarası *', _phoneController, hint: '5XXXXXXXXX', isPhone: true),
              _buildTextField('E-posta Adresi', _emailController, hint: 'ornek@mail.com'),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Kişisel Bilgiler'),
              _buildTextField('Ad *', _firstNameController),
              _buildTextField('Soyad *', _lastNameController),
              _buildTextField('Firma / Yönetim Adı', _companyController, hint: 'Yalnızca yöneticiler için'),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Rol & Yetkiler'),
              Text('Rol *', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.border)),
                ),
                items: const [
                  DropdownMenuItem(value: 'owner', child: Text('Kat Maliki')),
                  DropdownMenuItem(value: 'tenant', child: Text('Kiracı')),
                  DropdownMenuItem(value: 'staff', child: Text('Personel')),
                  DropdownMenuItem(value: 'apartment_manager', child: Text('Apartman Yöneticisi')),
                  DropdownMenuItem(value: 'system_admin', child: Text('Sistem Yöneticisi')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sisteme Giriş İzni (Zorunlu)', style: AppTextStyles.bodyMedium),
                subtitle: Text('Kullanıcının panele giriş yapabilmesi için açık olmalıdır.', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                value: _isStaff,
                onChanged: (val) => setState(() => _isStaff = val),
                activeColor: AppColors.primary,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Süper kullanıcı durumu', style: AppTextStyles.bodyMedium),
                subtitle: Text('Bu kullanıcıya ayrı ayrı izin atamadan tüm izinlerin verilip verilmeyeceğini belirler.', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                value: _isSuperuser,
                onChanged: (val) => setState(() => _isSuperuser = val),
                activeColor: AppColors.primary,
              ),
              
              if (isEdit) ...[
                const SizedBox(height: 24),
                _buildSectionTitle('Tarihler'),
                _buildReadOnlyField('Oluşturulma Tarihi', _formatDate(widget.user!.createdAt)),
                _buildReadOnlyField('Güncellenme Tarihi', _formatDate(widget.user!.updatedAt)),
              ],
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.surface,
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.border)),
              enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.border)),
            ),
            validator: (val) {
              if (label.contains('*') && (val == null || val.trim().isEmpty)) {
                return 'Bu alan zorunludur';
              }
              if (isPhone && val != null && val.trim().isNotEmpty) {
                final phoneStr = val.trim();
                if (phoneStr.length != 10 || !phoneStr.startsWith('5')) {
                  return 'Başında 0 olmadan 10 haneli giriniz (Örn: 5XXXXXXXXX)';
                }
              }
              return null;
            },

          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _monthName(int month) {
    const months = ['', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return months[month];
  }
}
