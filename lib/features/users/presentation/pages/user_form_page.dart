import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../properties/presentation/controllers/properties_cubit.dart';
import '../../../properties/presentation/controllers/properties_state.dart';
import '../../domain/models/user.dart';
import '../controllers/user_cubit.dart';
import '../../../auth/presentation/controllers/auth_cubit.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../../auth/domain/models/auth_user.dart';
import 'package:dio/dio.dart';

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
  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmController;

  int? _selectedUnitId;
  int? _selectedBlockId;
  int? _selectedApartmentId;
  bool _isResident = false;

  String _selectedRole = 'owner';
  bool _isStaff = true;
  bool _isSuperuser = false;
  bool _isSaving = false;

  late String _currentUserRole;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _firstNameController =
        TextEditingController(text: widget.user?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: widget.user?.lastName ?? '');
    _companyController =
        TextEditingController(text: widget.user?.companyName ?? '');
    _passwordController = TextEditingController();
    _passwordConfirmController = TextEditingController();

    // AuthCubit might be factory, but we can get it from context later or get the AuthCubit state from a singleton?
    // Wait, AuthCubit is a factory but there's no global AuthCubit.
    // Instead of sl<AuthCubit>(), let's just use 'system_admin' as default until build()
    _currentUserRole = 'system_admin';

    final propCubit = sl<PropertiesCubit>();
    if (propCubit.state is! PropertiesLoaded) {
      propCubit.fetchAll();
    }

    if (widget.user != null) {
      _selectedRole = widget.user!.role;
      _isStaff = widget.user!.isStaff;
      _isSuperuser = widget.user!.isSuperuser;
      _selectedApartmentId = widget.user!.managedApartmentId;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final role = authState.user.role.toString().split('.').last;
      // Enum UserRole to string: UserRole.apartmentManager -> 'apartmentManager'
      // Wait, UserRole values: systemAdmin, apartmentManager, owner, tenant, staff
      if (authState.user.role == UserRole.apartmentManager) {
        _currentUserRole = 'apartment_manager';
      } else {
        _currentUserRole = 'system_admin';
      }

      if (_currentUserRole == 'apartment_manager') {
        if (_selectedRole == 'apartment_manager' ||
            _selectedRole == 'system_admin') {
          _selectedRole = 'owner';
        }

        final propState = sl<PropertiesCubit>().state;
        if (propState is PropertiesLoaded && propState.apartments.isNotEmpty) {
          _selectedApartmentId ??= propState.apartments.first.id;
        }
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'company_name': _companyController.text.trim(),
      'role': _selectedRole,
      'is_staff': _isStaff,
      'is_superuser': _isSuperuser,
    };

    if (_passwordController.text.isNotEmpty) {
      if (_passwordController.text != _passwordConfirmController.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Şifreler eşleşmiyor'),
            backgroundColor: AppColors.error));
        setState(() => _isSaving = false);
        return;
      }
      data['password'] = _passwordController.text;
    }

    if (_selectedUnitId != null) {
      data['unit_id'] = _selectedUnitId;
      data['unit'] =
          _selectedUnitId; // Django backend might expect 'unit' instead of 'unit_id'
    }
    if (_selectedRole == 'owner' || _selectedRole == 'tenant') {
      data['is_resident'] = _isResident;
    }
    if (_selectedRole == 'apartment_manager') {
      data['apartment_id'] = _selectedApartmentId;
      data['managed_apartment'] = _selectedApartmentId;
    } else {
      data['apartment_id'] = _selectedApartmentId;
      data['managed_apartment'] = null;
    }

    try {
      if (widget.user == null) {
        // Create user requires a password usually, but wait, this is user management.
        // Usually creating users from manager panel might need a default password or trigger a reset link.
        // Django model allows creating without password but they can't login until they reset.
        await widget.cubit.createUser(data);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Kullanıcı eklendi'),
              backgroundColor: AppColors.success));
      } else {
        await widget.cubit.updateUser(widget.user!.id, data);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Kullanıcı güncellendi'),
              backgroundColor: AppColors.success));
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (e is DioException && e.response != null) {
          errorMsg = e.response!.data.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Hata: $errorMsg'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5)));
      }
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
              _buildTextField('Telefon Numarası *', _phoneController,
                  hint: '5XXXXXXXXX', isPhone: true),
              _buildTextField('E-posta Adresi', _emailController,
                  hint: 'ornek@mail.com'),
              const SizedBox(height: 24),
              _buildSectionTitle('Kişisel Bilgiler'),
              _buildTextField('Ad *', _firstNameController),
              _buildTextField('Soyad *', _lastNameController),
              _buildTextField('Firma / Yönetim Adı', _companyController,
                  hint: 'Yalnızca yöneticiler için'),
              const SizedBox(height: 24),
              _buildSectionTitle('Rol & Yetkiler'),
              Text('Rol *',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: AppColors.border)),
                ),
                items: [
                  const DropdownMenuItem(
                      value: 'owner', child: Text('Kat Maliki')),
                  const DropdownMenuItem(
                      value: 'tenant', child: Text('Kiracı')),
                  const DropdownMenuItem(
                      value: 'staff', child: Text('Personel')),
                  if (_currentUserRole == 'system_admin') ...[
                    const DropdownMenuItem(
                        value: 'apartment_manager',
                        child: Text('Apartman Yöneticisi')),
                    const DropdownMenuItem(
                        value: 'system_admin',
                        child: Text('Sistem Yöneticisi')),
                  ],
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
              const SizedBox(height: 16),
              if (_selectedRole == 'owner' || _selectedRole == 'tenant') ...[
                BlocBuilder<PropertiesCubit, PropertiesState>(
                  bloc: sl<PropertiesCubit>(),
                  builder: (context, state) {
                    if (state is PropertiesLoaded) {
                      final apartments = state.apartments;
                      final allBlocks = state.blocks;
                      final allUnits = state.units;

                      final isSingleApartment = apartments.length == 1;

                      // Auto-select apartment if manager or if only one apartment exists
                      if (apartments.isNotEmpty &&
                          (isSingleApartment ||
                              _currentUserRole == 'apartment_manager')) {
                        if (_selectedApartmentId == null ||
                            !apartments
                                .any((a) => a.id == _selectedApartmentId)) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted)
                              setState(() =>
                                  _selectedApartmentId = apartments.first.id);
                          });
                        }
                      }

                      final disableApartmentSelection =
                          _currentUserRole == 'apartment_manager' ||
                              isSingleApartment;

                      final filteredBlocks = _selectedApartmentId != null
                          ? allBlocks
                              .where(
                                  (b) => b.apartmentId == _selectedApartmentId)
                              .toList()
                          : [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bağlı Olduğu Apartman / Site *',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _selectedApartmentId,
                            decoration: const InputDecoration(
                              hintText: '--- Apartman Seçiniz ---',
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  borderSide:
                                      BorderSide(color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  borderSide:
                                      BorderSide(color: AppColors.border)),
                            ),
                            items: apartments
                                .map<DropdownMenuItem<int>>(
                                    (a) => DropdownMenuItem<int>(
                                          value: a.id,
                                          child: Text(a.name),
                                        ))
                                .toList(),
                            onChanged: disableApartmentSelection
                                ? null
                                : (val) {
                                    setState(() {
                                      _selectedApartmentId = val;
                                      _selectedBlockId = null;
                                      _selectedUnitId = null;
                                    });
                                  },
                          ),
                          const SizedBox(height: 16),
                          Text('Bağlı Olduğu Blok',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _selectedBlockId,
                            decoration: const InputDecoration(
                              hintText: '--- Blok Seçiniz ---',
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  borderSide:
                                      BorderSide(color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  borderSide:
                                      BorderSide(color: AppColors.border)),
                            ),
                            items: filteredBlocks
                                .map<DropdownMenuItem<int>>(
                                    (b) => DropdownMenuItem<int>(
                                          value: b.id,
                                          child: Text(b.name),
                                        ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedBlockId = val;
                                _selectedUnitId = null;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Text('Bağlı Olduğu Daire',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _selectedUnitId,
                            decoration: const InputDecoration(
                              hintText: '--- Daire Seçiniz ---',
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  borderSide:
                                      BorderSide(color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  borderSide:
                                      BorderSide(color: AppColors.border)),
                            ),
                            items: allUnits
                                .where((u) {
                                  if (_selectedBlockId != null)
                                    return u.blockId == _selectedBlockId;
                                  if (_selectedApartmentId != null)
                                    return allBlocks.any((b) =>
                                        b.apartmentId == _selectedApartmentId &&
                                        b.id == u.blockId);
                                  return true;
                                })
                                .map<DropdownMenuItem<int>>(
                                    (u) => DropdownMenuItem<int>(
                                          value: u.id,
                                          child: Text(
                                              'Blok ${u.blockName} - Daire ${u.number}'),
                                        ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedUnitId = val),
                          ),
                        ],
                      );
                    }
                    return const LinearProgressIndicator();
                  },
                ),
                if (_selectedRole == 'owner') ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Kat Maliki Bu Dairede Mi İkamet Ediyor?',
                        style: AppTextStyles.bodyMedium),
                    value: _isResident,
                    onChanged: (val) => setState(() => _isResident = val),
                    activeColor: AppColors.primary,
                  ),
                ],
                const SizedBox(height: 16),
              ],
              if (_selectedRole == 'apartment_manager' ||
                  _selectedRole == 'staff') ...[
                Text(
                    _selectedRole == 'apartment_manager'
                        ? 'Yönettiği Apartman / Site *'
                        : 'Çalıştığı Apartman / Site *',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                BlocBuilder<PropertiesCubit, PropertiesState>(
                  bloc: sl<PropertiesCubit>(),
                  builder: (context, state) {
                    if (state is PropertiesLoaded) {
                      final apartments = state.apartments;

                      final isSingleApartment = apartments.length == 1;

                      // Auto-select apartment if manager or if only one apartment exists
                      if (apartments.isNotEmpty &&
                          (isSingleApartment ||
                              _currentUserRole == 'apartment_manager')) {
                        if (_selectedApartmentId == null ||
                            !apartments
                                .any((a) => a.id == _selectedApartmentId)) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted)
                              setState(() =>
                                  _selectedApartmentId = apartments.first.id);
                          });
                        }
                      }

                      final disableApartmentSelection =
                          _currentUserRole == 'apartment_manager' ||
                              isSingleApartment;

                      return DropdownButtonFormField<int>(
                        value:
                            apartments.any((a) => a.id == _selectedApartmentId)
                                ? _selectedApartmentId
                                : null,
                        decoration: const InputDecoration(
                          hintText: '--- Apartman Seçiniz ---',
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: AppColors.border)),
                        ),
                        items: apartments
                            .map<DropdownMenuItem<int>>(
                                (a) => DropdownMenuItem<int>(
                                      value: a.id,
                                      child: Text(a.name),
                                    ))
                            .toList(),
                        onChanged: disableApartmentSelection
                            ? null
                            : (val) =>
                                setState(() => _selectedApartmentId = val),
                        validator: (v) => v == null ? 'Zorunlu alan' : null,
                      );
                    }
                    return const LinearProgressIndicator();
                  },
                ),
                const SizedBox(height: 16),
              ],
              if (!isEdit) ...[
                _buildSectionTitle('Güvenlik'),
                _buildTextField('Şifre *', _passwordController),
                _buildTextField('Şifre Tekrar *', _passwordConfirmController),
                const SizedBox(height: 16),
              ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sisteme Giriş İzni (Zorunlu)',
                    style: AppTextStyles.bodyMedium),
                subtitle: Text(
                    'Kullanıcının panele giriş yapabilmesi için açık olmalıdır.',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textSecondary)),
                value: _isStaff,
                onChanged: (val) => setState(() => _isStaff = val),
                activeColor: AppColors.primary,
              ),
              if (_currentUserRole == 'system_admin')
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Süper kullanıcı durumu',
                      style: AppTextStyles.bodyMedium),
                  subtitle: Text(
                      'Bu kullanıcıya ayrı ayrı izin atamadan tüm izinlerin verilip verilmeyeceğini belirler.',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textSecondary)),
                  value: _isSuperuser,
                  onChanged: (val) => setState(() => _isSuperuser = val),
                  activeColor: AppColors.primary,
                ),
              if (isEdit) ...[
                const SizedBox(height: 24),
                _buildSectionTitle('Tarihler'),
                _buildReadOnlyField(
                    'Oluşturulma Tarihi', _formatDate(widget.user!.createdAt)),
                _buildReadOnlyField(
                    'Güncellenme Tarihi', _formatDate(widget.user!.updatedAt)),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Kaydet',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
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
      child: Text(title,
          style:
              AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {String? hint, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            obscureText: label.contains('Şifre'),
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.surface,
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppColors.border)),
              enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppColors.border)),
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
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _monthName(int month) {
    const months = [
      '',
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return months[month];
  }
}
