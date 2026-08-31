import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/models/models.dart';
import '../controllers/properties_cubit.dart';
import '../controllers/properties_state.dart';

class BlockFormPage extends StatefulWidget {
  final AppBlock? block;
  final PropertiesCubit cubit;
  final bool isDuplicate;

  const BlockFormPage({super.key, this.block, required this.cubit, this.isDuplicate = false});

  @override
  State<BlockFormPage> createState() => _BlockFormPageState();
}

class _BlockFormPageState extends State<BlockFormPage> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedApartmentId;
  late String _name;
  late int _floorCount;
  late int _unitCount;

  List<AppApartment> _apartments = [];

  // Local state for nested units (if we implement them like blocks in apartment)
  List<Map<String, dynamic>> _units = [];
  List<int> _deletedUnitIds = [];


  @override
  void initState() {
    super.initState();
    _selectedApartmentId = widget.block?.apartmentId;
    _name = widget.block?.name ?? '';
    if (widget.isDuplicate) {
      _name = '$_name (Kopya)';
    }
    _floorCount = widget.block?.floorCount ?? 1;
    _unitCount = widget.block?.unitCount ?? 1;

    if (widget.cubit.state is PropertiesLoaded) {
      final state = widget.cubit.state as PropertiesLoaded;
      _apartments = state.apartments;

      if (widget.block != null) {
        final blockUnits = state.units.where((u) => u.blockName == widget.block!.name && u.apartmentName == widget.block!.apartmentName).toList();
        for (var u in blockUnits) {
          _units.add({
            'id': u.id,
            'number': u.number,
            'floor': u.floor,
            'usage_status': u.usageStatus,
          });
        }
      }
    }
  }



  void _save() {
    if (_formKey.currentState != null) {
      if (!_formKey.currentState!.validate()) return;
      _formKey.currentState!.save();
    }

    if (_selectedApartmentId == null) return;

    if (widget.block != null && !widget.isDuplicate) {
      widget.cubit.saveBlockWithUnits(
        widget.block!.id,
        {
          'apartment': _selectedApartmentId,
          'name': _name,
          'floor_count': _floorCount,
          'unit_count': _unitCount,
        },
        _units,
        _deletedUnitIds,
      );
    } else {
      final duplicateUnits = _units.map((u) => {
        'number': u['number'],
        'floor': u['floor'],
        'usage_status': u['usage_status'],
      }).toList();
      widget.cubit.createBlockWithUnits({
          'apartment': _selectedApartmentId,
          'name': _name,
          'floor_count': _floorCount,
          'unit_count': _unitCount,
      }, duplicateUnits);
    }
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.block == null ? 'Yeni Blok' : (widget.isDuplicate ? 'Yeni Blok (Çoğalt)' : 'Blok Düzenle')),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Genel'),
              Tab(text: 'Daireler'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGeneralTab(),
            _buildUnitsTab(),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (widget.block != null && !widget.isDuplicate)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.cubit.deleteBlock(widget.block!.id);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    child: const Text('Sil Blok'),
                  ),
                ),
              if (widget.block != null && !widget.isDuplicate) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralTab() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Blok Tanımı', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  value: _selectedApartmentId,
                  decoration: const InputDecoration(labelText: 'Apartman / Site *', border: OutlineInputBorder()),
                  items: _apartments.map((apt) {
                    return DropdownMenuItem<int>(
                      value: apt.id,
                      child: Text(apt.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedApartmentId = val;
                    });
                  },
                  validator: (v) => v == null ? 'Zorunlu alan' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Blok Adı *', border: OutlineInputBorder()),
                  onChanged: (v) => _name = v,
                  onSaved: (v) => _name = v!,
                  validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Kat ve Daire Sayıları', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                TextFormField(
                  initialValue: _floorCount.toString(),
                  decoration: const InputDecoration(labelText: 'Kat Sayısı *', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _floorCount = int.tryParse(v) ?? 1,
                  onSaved: (v) => _floorCount = int.tryParse(v!) ?? 1,
                  validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _unitCount.toString(),
                  decoration: const InputDecoration(labelText: 'Daire Sayısı *', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _unitCount = int.tryParse(v) ?? 1,
                  onSaved: (v) => _unitCount = int.tryParse(v!) ?? 1,
                  validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildUnitsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: const [
            Expanded(flex: 2, child: Text('Daire Numarası*', style: AppTextStyles.labelMedium)),
            SizedBox(width: 8),
            Expanded(flex: 1, child: Text('Kat*', style: AppTextStyles.labelMedium)),
            SizedBox(width: 8),
            Expanded(flex: 2, child: Text('Kullanım Durumu*', style: AppTextStyles.labelMedium)),
            SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: 8),
        ..._units.asMap().entries.map((entry) {
          int index = entry.key;
          var unit = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: unit['number'],
                    onChanged: (v) => _units[index]['number'] = v,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: unit['floor']?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _units[index]['floor'] = int.tryParse(v) ?? 0,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: unit['usage_status'],
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: const [
                      DropdownMenuItem(value: 'empty', child: Text('Boş')),
                      DropdownMenuItem(value: 'rented', child: Text('Kirada')),
                      DropdownMenuItem(value: 'owner_occupied', child: Text('Malik Oturuyor')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _units[index]['usage_status'] = val;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      if (_units[index]['id'] != null) {
                        _deletedUnitIds.add(_units[index]['id']);
                      }
                      _units.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

}
