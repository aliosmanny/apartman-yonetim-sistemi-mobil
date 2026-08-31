import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/models.dart';
import '../controllers/properties_cubit.dart';
import '../controllers/properties_state.dart';
import '../../../users/domain/models/user.dart';
import '../../../users/presentation/controllers/user_cubit.dart';
import '../../../users/presentation/controllers/user_state.dart';

class OwnerFormPage extends StatefulWidget {
  final AppOwner? owner;
  final PropertiesCubit cubit;
  final UserCubit userCubit;

  const OwnerFormPage({super.key, this.owner, required this.cubit, required this.userCubit});

  @override
  State<OwnerFormPage> createState() => _OwnerFormPageState();
}

class _OwnerFormPageState extends State<OwnerFormPage> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedUserId;
  int? _selectedUnitId;
  bool _isResident = false;
  bool _isDeleted = false;

  List<AppUnit> _units = [];
  List<AppUser> _users = [];

  @override
  void initState() {
    super.initState();

    if (widget.owner != null) {
      _isResident = widget.owner!.isResident;
      _isDeleted = widget.owner!.isDeleted;
    }

    if (widget.cubit.state is PropertiesLoaded) {
      final allUnits = (widget.cubit.state as PropertiesLoaded).units;
      final seen = <int>{};
      for (final u in allUnits) {
        if (seen.add(u.id)) _units.add(u);
      }
    }

    if (widget.owner?.unitId != null) {
      if (_units.any((u) => u.id == widget.owner!.unitId)) {
        _selectedUnitId = widget.owner!.unitId;
      }
    }

    final userState = widget.userCubit.state;
    if (userState is UserLoaded) {
      final seen = <int>{};
      for (final u in userState.users) {
        if (seen.add(u.id)) _users.add(u);
      }
    }

    if (widget.owner?.userId != null) {
      if (_users.any((u) => u.id == widget.owner!.userId)) {
        _selectedUserId = widget.owner!.userId;
      }
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    
    final selectedUser = _users.firstWhere((u) => u.id == _selectedUserId);
    
    final data = {
      'phone': selectedUser.phone,
      'first_name': selectedUser.firstName,
      'last_name': selectedUser.lastName,
      'email': selectedUser.email ?? '',
      'unit_id': _selectedUnitId,
      'is_resident': _isResident,
      'is_deleted': _isDeleted,
    };
    if (widget.owner == null) {
      widget.cubit.createOwner(data);
    } else {
      widget.cubit.updateOwnerDetails(widget.owner!.id, data);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.owner == null ? 'Kat Maliki Ekle' : 'Kat Maliki Düzenle'),
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
              // --- Malik Bilgileri ---
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Malik Bilgileri', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: _users.any((u) => u.id == _selectedUserId) ? _selectedUserId : null,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Kullanıcı Hesabı *',
                          border: OutlineInputBorder(),
                        ),
                        hint: Text(_users.isEmpty ? 'Yükleniyor...' : 'Seçin'),
                        items: _users.map((u) => DropdownMenuItem(
                          value: u.id,
                          child: Text('${u.firstName} ${u.lastName} (${u.phone})',
                              overflow: TextOverflow.ellipsis),
                        )).toList(),
                        onChanged: widget.owner != null
                            ? null
                            : (v) => setState(() => _selectedUserId = v),
                        validator: (v) => v == null ? 'Zorunlu alan' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // --- Bağlı Daire ---
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bağlı Daire', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: _units.any((u) => u.id == _selectedUnitId) ? _selectedUnitId : null,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Daire *',
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('Seçin'),
                        items: _units.map((u) => DropdownMenuItem(
                          value: u.id,
                          child: Text('${u.apartmentName} - ${u.blockName} - ${u.number}',
                              overflow: TextOverflow.ellipsis),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedUnitId = v),
                        validator: (v) => v == null ? 'Zorunlu alan' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // --- Durum ---
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Durum', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        title: const Text('Bu Dairede Mi İkamet Ediyor?'),
                        value: _isResident,
                        onChanged: (v) => setState(() => _isResident = v ?? false),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      SwitchListTile(
                        title: const Text('Silindi'),
                        value: _isDeleted,
                        onChanged: (v) => setState(() => _isDeleted = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Butonlar ---
              if (widget.owner != null)
                OutlinedButton(
                  onPressed: () {
                    widget.cubit.deleteOwner(widget.owner!.id);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Sil'),
                ),
              if (widget.owner != null) const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B1B2F),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Kaydet'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
