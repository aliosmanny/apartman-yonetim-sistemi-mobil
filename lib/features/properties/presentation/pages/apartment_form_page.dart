import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/turkey_cities.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/models/models.dart';
import '../controllers/properties_cubit.dart';
import '../controllers/properties_state.dart';

class ApartmentFormPage extends StatefulWidget {
  final AppApartment? apartment;
  final PropertiesCubit cubit;
  final bool isDuplicate;

  const ApartmentFormPage({super.key, this.apartment, required this.cubit, this.isDuplicate = false});

  @override
  State<ApartmentFormPage> createState() => _ApartmentFormPageState();
}

class _ApartmentFormPageState extends State<ApartmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late String _name;
  String? _city;
  String? _district;
  late String _address;
  late double _lateFee;
  
  List<Map<String, dynamic>> _blocks = [];
  List<int> _deletedBlockIds = [];

  @override
  void initState() {
    super.initState();
    _name = widget.apartment?.name ?? '';
    if (widget.isDuplicate) {
      _name = '$_name (Kopya)';
    }
    _city = widget.apartment?.province;
    if (_city != null && _city!.isEmpty) _city = null;
    _district = widget.apartment?.district;
    if (_district != null && _district!.isEmpty) _district = null;
    _address = widget.apartment?.address ?? '';
    _lateFee = widget.apartment?.monthlyLateFeeRate ?? 0.0;
    
    if (widget.apartment != null && widget.cubit.state is PropertiesLoaded) {
      final state = widget.cubit.state as PropertiesLoaded;
      final aptBlocks = state.blocks.where((b) => b.apartmentId == widget.apartment!.id).toList();
      for (var b in aptBlocks) {
        _blocks.add({
          'id': b.id,
          'name': b.name,
          'floor_count': b.floorCount,
          'unit_count': b.unitCount,
        });
      }
    }
  }


  void _save() {
    // Validate if the General tab is currently visible/mounted
    if (_formKey.currentState != null) {
      if (!_formKey.currentState!.validate()) return;
      _formKey.currentState!.save();
    }
    
    final data = {
      'name': _name,
      'city': _city ?? '',
      'district': _district ?? '',
      'address': _address,
      'monthly_late_fee_rate': _lateFee,
    };
    
    if (widget.apartment != null && !widget.isDuplicate) {
      widget.cubit.saveApartmentWithBlocks(
        widget.apartment!.id,
        data,
        _blocks,
        _deletedBlockIds,
      );
    } else {
      final duplicateBlocks = _blocks.map((b) => {
        'name': b['name'],
        'floor_count': b['floor_count'],
        'unit_count': b['unit_count'],
      }).toList();
      widget.cubit.createApartmentWithBlocks(data, duplicateBlocks);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.apartment == null ? 'Yeni Apartman' : (widget.isDuplicate ? 'Yeni Apartman (Çoğalt)' : 'Apartman Düzenle')),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Genel'),
              Tab(text: 'Bloklar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGeneralTab(),
            _buildBlocksTab(),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (widget.apartment != null && !widget.isDuplicate)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.cubit.deleteApartment(widget.apartment!.id);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    child: const Text('Sil Apartman / Site'),
                  ),
                ),
              if (widget.apartment != null && !widget.isDuplicate) const SizedBox(width: 16),
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
          TextFormField(
            initialValue: _name,
            decoration: const InputDecoration(labelText: 'Apartman / Site Adı *'),
            validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
            onChanged: (v) => _name = v,
            onSaved: (v) => _name = v!,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: (_city != null && TurkeyCities.citiesAndDistricts.keys.contains(_city)) ? _city : null,
            decoration: const InputDecoration(
              labelText: 'İl *',
              hintText: '--- İl Seçiniz ---',
            ),
            items: TurkeyCities.citiesAndDistricts.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            validator: (v) => v == null ? 'Zorunlu alan' : null,
            onChanged: (v) {
              setState(() {
                _city = v;
                _district = null; // Reset district when city changes
              });
            },
            onSaved: (v) => _city = v,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: (_city != null && _district != null && TurkeyCities.citiesAndDistricts[_city]!.contains(_district)) ? _district : null,
            decoration: const InputDecoration(
              labelText: 'İlçe *',
              hintText: '--- Önce İl Seçiniz ---',
            ),
            items: _city == null 
                ? [] 
                : TurkeyCities.citiesAndDistricts[_city]!.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            validator: (v) => v == null ? 'Zorunlu alan' : null,
            onChanged: (v) {
              setState(() {
                _district = v;
              });
            },
            onSaved: (v) => _district = v,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _address,
            decoration: const InputDecoration(labelText: 'Adres *'),
            maxLines: 3,
            validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
            onChanged: (v) => _address = v,
            onSaved: (v) => _address = v!,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _lateFee.toString(),
            decoration: const InputDecoration(labelText: 'Aylık Gecikme Faizi Oranı (%) *'),
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
            onChanged: (v) => _lateFee = double.tryParse(v) ?? 0.0,
            onSaved: (v) => _lateFee = double.tryParse(v!) ?? 0.0,
          ),
        ],
      ),
    );
  }

  Widget _buildBlocksTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: const [
            Expanded(flex: 2, child: Text('Blok Adı*', style: AppTextStyles.labelMedium)),
            SizedBox(width: 8),
            Expanded(flex: 1, child: Text('Kat Sayısı*', style: AppTextStyles.labelMedium)),
            SizedBox(width: 8),
            Expanded(flex: 1, child: Text('Daire Sayısı*', style: AppTextStyles.labelMedium)),
            SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: 8),
        ..._blocks.asMap().entries.map((entry) {
          int index = entry.key;
          var block = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: block['name'],
                    onChanged: (v) => _blocks[index]['name'] = v,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: block['floor_count']?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _blocks[index]['floor_count'] = int.tryParse(v) ?? 0,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: block['unit_count']?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _blocks[index]['unit_count'] = int.tryParse(v) ?? 0,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      if (_blocks[index]['id'] != null) {
                        _deletedBlockIds.add(_blocks[index]['id']);
                      }
                      _blocks.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }).toList(),
        
        TextButton.icon(
          onPressed: () {
            setState(() {
              _blocks.add({'name': '', 'floor_count': 1, 'unit_count': 1});
            });
          },
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Başka bir Blok ekle'),
          style: TextButton.styleFrom(alignment: Alignment.centerLeft),
        ),
      ],
    );
  }
}
