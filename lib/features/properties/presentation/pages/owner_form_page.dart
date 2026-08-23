import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/models.dart';
import '../controllers/properties_cubit.dart';
import '../controllers/properties_state.dart';

class OwnerFormPage extends StatefulWidget {
  final AppOwner owner;
  final PropertiesCubit cubit;

  const OwnerFormPage({super.key, required this.owner, required this.cubit});

  @override
  State<OwnerFormPage> createState() => _OwnerFormPageState();
}

class _OwnerFormPageState extends State<OwnerFormPage> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedUnitId;
  late bool _isResident;
  late bool _isDeleted;

  List<AppUnit> _units = [];

  @override
  void initState() {
    super.initState();
    _selectedUnitId = widget.owner.unitId;
    _isResident = widget.owner.isResident;
    _isDeleted = widget.owner.isDeleted;

    if (widget.cubit.state is PropertiesLoaded) {
      _units = (widget.cubit.state as PropertiesLoaded).units;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedUnitId == null) return;

    widget.cubit.updateOwnerDetails(widget.owner.id, {
      'unit': _selectedUnitId,
      'is_resident': _isResident,
      'is_deleted': _isDeleted,
    });
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kat Maliki Düzenle')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Malik Bilgileri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: '${widget.owner.userName} (${widget.owner.userPhone})',
              decoration: const InputDecoration(labelText: 'Kullanıcı Hesabı *'),
              enabled: false,
            ),
            const SizedBox(height: 32),
            
            const Text('Bağlı Daire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedUnitId,
              decoration: const InputDecoration(labelText: 'Daire *'),
              items: _units.map((u) {
                return DropdownMenuItem<int>(
                  value: u.id,
                  child: Text('${u.apartmentName} - ${u.blockName} - ${u.number}'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedUnitId = val;
                });
              },
              validator: (v) => v == null ? 'Zorunlu alan' : null,
            ),
            const SizedBox(height: 32),

            const Text('Durum', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Bu Dairede Mi İkamet Ediyor?'),
              subtitle: const Text('Kat maliki aynı zamanda satın aldığı bu dairede oturuyorsa işaretleyin.'),
              value: _isResident,
              onChanged: (val) {
                setState(() {
                  _isResident = val;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Silindi'),
              value: _isDeleted,
              onChanged: (val) {
                setState(() {
                  _isDeleted = val;
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  widget.cubit.deleteOwner(widget.owner.id);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Sil Kat Maliki'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
