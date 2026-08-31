import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../staff/domain/models/staff_member.dart';
import '../../../staff/presentation/controllers/staff_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/controllers/auth_cubit.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../../properties/presentation/controllers/properties_cubit.dart';
import '../../../properties/presentation/controllers/properties_state.dart';

class ManagerStaffFormPage extends StatefulWidget {
  final StaffMember? staff; // null ise Ekle, değilse Düzenle
  
  const ManagerStaffFormPage({super.key, this.staff});

  @override
  State<ManagerStaffFormPage> createState() => _ManagerStaffFormPageState();
}

class _ManagerStaffFormPageState extends State<ManagerStaffFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  
  int? _selectedApartmentId;
  String? _selectedRole;
  bool _isActive = true;
  
  late List<DropdownMenuItem<int>> _apartmentItems;
  late List<DropdownMenuItem<String>> _roleItems;

  bool _isManager = false;

  @override
  void initState() {
    super.initState();
    final staff = widget.staff;
    
    String fName = '';
    String lName = '';
    if (staff != null && staff.userName.isNotEmpty) {
      final parts = staff.userName.split(' ');
      if (parts.length > 1) {
        lName = parts.last;
        fName = parts.sublist(0, parts.length - 1).join(' ');
      } else {
        fName = staff.userName;
      }
    }

    _firstNameController = TextEditingController(text: fName);
    _lastNameController = TextEditingController(text: lName);
    _phoneController = TextEditingController(text: staff?.userPhone ?? '');
    _emailController = TextEditingController(text: staff?.userEmail ?? '');
    _passwordController = TextEditingController();
    
    if (staff != null) {
      _selectedApartmentId = staff.apartmentId;
      _selectedRole = staff.role;
      _isActive = staff.isActive;
    } else {
      _selectedRole = 'teknik'; 
    }

    final roles = {
      'teknik': 'Teknik Servis',
      'temizlik': 'Temizlik Personeli',
      'guvenlik': 'Güvenlik Görevlisi',
      'bahcivan': 'Bahçıvan',
      'diger': 'Diğer',
    };
    if (staff != null && staff.role.isNotEmpty && !roles.containsKey(staff.role)) {
      roles[staff.role] = staff.roleDisplay.isNotEmpty ? staff.roleDisplay : staff.role;
    }
    _roleItems = roles.entries.map((e) => DropdownMenuItem<String>(value: e.key, child: Text(e.value))).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _isManager = authState.user.role == UserRole.apartmentManager;
    }

    final propState = sl<PropertiesCubit>().state;
    final apts = <int, String>{};
    
    if (propState is PropertiesLoaded) {
      for (var a in propState.apartments) {
        apts[a.id] = a.name;
      }
    }

    if (widget.staff != null && widget.staff!.apartmentId != 0 && !apts.containsKey(widget.staff!.apartmentId)) {
      apts[widget.staff!.apartmentId] = widget.staff!.apartmentName.isNotEmpty ? widget.staff!.apartmentName : 'Apartman ${widget.staff!.apartmentId}';
    }
    
    _apartmentItems = apts.entries.map((e) => DropdownMenuItem<int>(value: e.key, child: Text(e.value))).toList();
    
    if (_isManager || apts.length == 1) {
      if (apts.isNotEmpty && _selectedApartmentId == null) {
        _selectedApartmentId = apts.keys.first;
      }
    } else if (_selectedApartmentId == null && apts.isNotEmpty) {
      _selectedApartmentId = apts.keys.first;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isSaving = false;

  void _save() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedApartmentId == null || _selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen apartman ve görev seçiniz.')),
        );
        return;
      }

      setState(() => _isSaving = true);

      final data = <String, dynamic>{
        'apartment_id': _selectedApartmentId,
        'role': _selectedRole,
        'is_active': _isActive,
      };

      try {
        if (widget.staff == null) {
          // Create Mode
          data['first_name'] = _firstNameController.text.trim();
          data['last_name'] = _lastNameController.text.trim();
          data['phone'] = _phoneController.text.trim();
          if (_emailController.text.trim().isNotEmpty) {
            data['email'] = _emailController.text.trim();
          }
          if (_passwordController.text.trim().isNotEmpty) {
            data['password'] = _passwordController.text.trim();
          }
          
          await context.read<StaffCubit>().createStaff(data);
        } else {
          await context.read<StaffCubit>().updateStaff(widget.staff!.id, data);
        }
        
        if (mounted) context.pop();
      } catch (e) {
        if (mounted) {
          String msg = e.toString();
          if (msg.startsWith('ApiException(status:')) {
            // Very quick hack to display just the message part
            msg = msg.split('message:').last.replaceAll(')', '').trim();
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $msg'), backgroundColor: AppColors.error, duration: const Duration(seconds: 5)));
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  void _delete() async {
    if (widget.staff != null) {
      setState(() => _isSaving = true);
      try {
        await context.read<StaffCubit>().deleteStaff(widget.staff!.id);
        if (mounted) context.pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error));
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.staff != null;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? '${widget.staff!.userName}' : 'Yeni Personel Ekle', style: AppTextStyles.titleMedium),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Personel Kimlik Bilgileri ────────────────────
              Text('Personel Kimlik Bilgileri', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildTextField('Ad*', _firstNameController, enabled: !isEdit, validator: (v) => v!.isEmpty ? 'Ad gerekli' : null),
                    const SizedBox(height: 16),
                    _buildTextField('Soyad*', _lastNameController, enabled: !isEdit, validator: (v) => v!.isEmpty ? 'Soyad gerekli' : null),
                    const SizedBox(height: 16),
                    _buildTextField('Telefon Numarası*', _phoneController, enabled: !isEdit, hint: 'Başında 0 olmadan (Örn: 5XX)', validator: (v) => v!.length < 10 ? 'Geçersiz telefon' : null),
                    const SizedBox(height: 16),
                    _buildTextField('E-posta Adresi', _emailController, enabled: !isEdit),
                    if (!isEdit) ...[
                      const SizedBox(height: 16),
                      _buildTextField('Şifre', _passwordController, isPassword: true, hint: 'Boş bırakırsanız rastgele atanır (Min 8 karakter)'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // ── Görev ve Çalışma Bilgileri ────────────────────
              Text('Görev ve Çalışma Bilgileri', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildDropdown(
                      'Apartman / Site*',
                      value: _selectedApartmentId,
                      items: _apartmentItems,
                      onChanged: (_isManager || _apartmentItems.length <= 1) ? null : (val) => setState(() => _selectedApartmentId = val as int?),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      'Görev*',
                      value: _selectedRole,
                      items: _roleItems,
                      onChanged: (val) => setState(() => _selectedRole = val as String?),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Aktif', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        Switch(
                          value: _isActive,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _isActive = val),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              if (isEdit) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _delete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Sil'),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true, bool isPassword = false, String? hint, String? Function(String?)? validator}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, {required dynamic value, required List<DropdownMenuItem<dynamic>> items, required ValueChanged<dynamic>? onChanged}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<dynamic>(
            value: value,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
