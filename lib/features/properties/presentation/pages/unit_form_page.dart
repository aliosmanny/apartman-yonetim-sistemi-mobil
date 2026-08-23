import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/models.dart';
import '../controllers/properties_cubit.dart';
import '../controllers/properties_state.dart';

class UnitFormPage extends StatefulWidget {
  final AppUnit? unit;
  final PropertiesCubit cubit;

  const UnitFormPage({super.key, this.unit, required this.cubit});

  @override
  State<UnitFormPage> createState() => _UnitFormPageState();
}

class _UnitFormPageState extends State<UnitFormPage> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedBlockId;
  late String _number;
  late int _floor;
  late String _usageStatus;

  List<AppBlock> _blocks = [];

  @override
  void initState() {
    super.initState();
    _selectedBlockId = widget.unit?.blockId;
    _number = widget.unit?.number ?? '';
    _floor = widget.unit?.floor ?? 0;
    _usageStatus = widget.unit?.usageStatus ?? 'empty';

    if (widget.cubit.state is PropertiesLoaded) {
      _blocks = (widget.cubit.state as PropertiesLoaded).blocks;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedBlockId == null) return;

    if (widget.unit != null) {
      widget.cubit.updateUnitDetails(widget.unit!.id, {
        'block_id': _selectedBlockId,
        'number': _number,
        'floor': _floor,
        'usage_status': _usageStatus,
      });
    }
    // We cannot create unit directly from mobile as backend only allows creation via block save.
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.unit == null ? 'Daire Ekle' : 'Daire Düzenle')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              value: _selectedBlockId,
              decoration: const InputDecoration(labelText: 'Blok *'),
              items: _blocks.map((b) {
                return DropdownMenuItem<int>(
                  value: b.id,
                  child: Text('${b.apartmentName} - ${b.name}'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedBlockId = val;
                });
              },
              validator: (v) => v == null ? 'Zorunlu alan' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _number,
              decoration: const InputDecoration(labelText: 'Daire Numarası *'),
              onSaved: (v) => _number = v!,
              validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _floor.toString(),
              decoration: const InputDecoration(labelText: 'Kat *'),
              keyboardType: TextInputType.number,
              onSaved: (v) => _floor = int.tryParse(v!) ?? 0,
              validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _usageStatus,
              decoration: const InputDecoration(labelText: 'Kullanım Durumu *'),
              items: const [
                DropdownMenuItem(value: 'empty', child: Text('Boş')),
                DropdownMenuItem(value: 'owner_occupied', child: Text('Malik Oturuyor')),
                DropdownMenuItem(value: 'rented', child: Text('Kirada')),
              ],
              onChanged: (val) {
                setState(() {
                  _usageStatus = val!;
                });
              },
              validator: (v) => v == null ? 'Zorunlu alan' : null,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (widget.unit != null)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.cubit.deleteUnit(widget.unit!.id);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  child: const Text('Sil Daire'),
                ),
              ),
            if (widget.unit != null) const SizedBox(width: 16),
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
