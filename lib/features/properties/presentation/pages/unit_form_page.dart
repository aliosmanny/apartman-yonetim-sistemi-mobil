import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/models.dart';
import '../controllers/properties_cubit.dart';
import '../controllers/properties_state.dart';

class UnitFormPage extends StatefulWidget {
  final AppUnit? unit;
  final PropertiesCubit cubit;
  final bool isDuplicate;

  const UnitFormPage({super.key, this.unit, required this.cubit, this.isDuplicate = false});

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
    if (widget.isDuplicate) {
      _number = '$_number (Kopya)';
    }
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

    final data = {
      'block': _selectedBlockId,
      'number': _number,
      'floor': _floor,
      'usage_status': _usageStatus,
    };
    if (widget.unit != null && !widget.isDuplicate) {
      widget.cubit.updateUnitDetails(widget.unit!.id, data);
    } else {
      widget.cubit.createUnit(data);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.unit == null ? 'Daire Ekle' : (widget.isDuplicate ? 'Daire Ekle (Çoğalt)' : 'Daire Düzenle'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Daire Bilgileri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<int>(
                    value: _selectedBlockId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Blok *', border: OutlineInputBorder()),
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
                    decoration: const InputDecoration(labelText: 'Daire Numarası *', border: OutlineInputBorder()),
                    onChanged: (v) => _number = v,
                    onSaved: (v) => _number = v!,
                    validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _floor.toString(),
                    decoration: const InputDecoration(labelText: 'Kat *', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _floor = int.tryParse(v) ?? 0,
                    onSaved: (v) => _floor = int.tryParse(v!) ?? 0,
                    validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Özellikler & Durum', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _usageStatus,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Kullanım Durumu *', border: OutlineInputBorder()),
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
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (widget.unit != null && !widget.isDuplicate)
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
            if (widget.unit != null && !widget.isDuplicate) const SizedBox(width: 16),
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
