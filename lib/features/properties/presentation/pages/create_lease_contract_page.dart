import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/properties_cubit.dart';
import '../controllers/properties_state.dart';

class CreateLeaseContractPage extends StatefulWidget {
  const CreateLeaseContractPage({super.key});

  @override
  State<CreateLeaseContractPage> createState() => _CreateLeaseContractPageState();
}

class _CreateLeaseContractPageState extends State<CreateLeaseContractPage> {
  final _formKey = GlobalKey<FormState>();
  
  String _title = '';
  int? _selectedUnitId;
  int? _selectedOwnerId;
  int? _selectedTenantId;
  String _monthlyRent = '';
  String _depositAmount = '0';
  DateTime? _startDate;
  DateTime? _endDate;
  File? _selectedFile;

@override
  void initState() {
    super.initState();
    final state = context.read<PropertiesCubit>().state;
    if (state is PropertiesLoaded) {
      if (state.units.isEmpty) context.read<PropertiesCubit>().fetchAll();
      
      
    } else {
      context.read<PropertiesCubit>().fetchAll();
      
      
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarihleri seçiniz.')));
        return;
      }
      _formKey.currentState!.save();

      final data = {
        'title': _title,
        'unit': _selectedUnitId,
        'owner': _selectedOwnerId,
        'tenant': _selectedTenantId,
        'start_date': _startDate!.toIso8601String().split('T').first,
        'end_date': _endDate!.toIso8601String().split('T').first,
        'monthly_rent': _monthlyRent,
        'deposit_amount': _depositAmount,
        'status': 'active',
      };

      context.read<PropertiesCubit>().createContract(data, filePath: _selectedFile?.path).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kira Sözleşmesi eklendi!')));
        context.pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Kira Sözleşmesi')),
      body: BlocBuilder<PropertiesCubit, PropertiesState>(
        builder: (context, state) {
if (state is PropertiesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final units = state is PropertiesLoaded ? state.units : [];
          final owners = state is PropertiesLoaded ? state.owners : [];
          final tenants = state is PropertiesLoaded ? state.tenants : [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Sözleşme Başlığı'),
                    validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null,
                    onSaved: (v) => _title = v!,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Daire'),
                    value: _selectedUnitId,
                    items: units.map<DropdownMenuItem<int>>((u) => DropdownMenuItem(value: u.id, child: Text(u.display))).toList(),
                    onChanged: (v) => setState(() => _selectedUnitId = v),
                    validator: (v) => v == null ? 'Zorunlu alan' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Kat Maliki'),
                    value: _selectedOwnerId,
                    items: owners.map<DropdownMenuItem<int>>((o) => DropdownMenuItem(value: o.id, child: Text(o.firstName))).toList(),
                    onChanged: (v) => setState(() => _selectedOwnerId = v),
                    validator: (v) => v == null ? 'Zorunlu alan' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Kiracı'),
                    value: _selectedTenantId,
                    items: tenants.map<DropdownMenuItem<int>>((t) => DropdownMenuItem(value: t.id, child: Text(t.firstName))).toList(),
                    onChanged: (v) => setState(() => _selectedTenantId = v),
                    validator: (v) => v == null ? 'Zorunlu alan' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                            if (date != null) setState(() => _startDate = date);
                          },
                          child: Text(_startDate == null ? 'Başlangıç Seç' : _startDate!.toIso8601String().split('T').first),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final date = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 365)), firstDate: DateTime(2000), lastDate: DateTime(2100));
                            if (date != null) setState(() => _endDate = date);
                          },
                          child: Text(_endDate == null ? 'Bitiş Seç' : _endDate!.toIso8601String().split('T').first),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Aylık Kira (₺)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null,
                    onSaved: (v) => _monthlyRent = v!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Depozito (₺)'),
                    keyboardType: TextInputType.number,
                    initialValue: '0',
                    onSaved: (v) => _depositAmount = v ?? '0',
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: AppColors.primary.withOpacity(0.05),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.upload_file, size: 40, color: AppColors.primary),
                          const SizedBox(height: 8),
                          Text(
                            _selectedFile == null ? 'Sözleşme Belgesi Yükle (PDF, JPG, PNG)' : _selectedFile!.path.split('/').last,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _pickFile,
                            child: const Text('Dosya Seç'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Sözleşmeyi Kaydet'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
