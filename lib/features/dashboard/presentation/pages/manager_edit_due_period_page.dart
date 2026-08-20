import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../finance/presentation/controllers/finance_cubit.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../finance/domain/models/due_period.dart';

class ManagerEditDuePeriodPage extends StatefulWidget {
  final DuePeriod period;

  const ManagerEditDuePeriodPage({super.key, required this.period});

  @override
  State<ManagerEditDuePeriodPage> createState() => _ManagerEditDuePeriodPageState();
}

class _ManagerEditDuePeriodPageState extends State<ManagerEditDuePeriodPage> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedYear;
  late String _selectedMonth;
  late TextEditingController _amountController;
  late TextEditingController _lateFeeController;
  late TextEditingController _descController;
  late DateTime _selectedDueDate;

  final List<String> _years = ['2024', '2025', '2026', '2027'];
  final List<String> _months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];

  @override
  void initState() {
    super.initState();
    // Parse period (e.g., "2025 - Ocak" or similar)
    // Fallbacks if formatting is different
    final parts = widget.period.period.split(' - ');
    if (parts.length == 2) {
      _selectedYear = parts[0];
      _selectedMonth = parts[1];
    } else {
      _selectedYear = '2025';
      _selectedMonth = 'Ocak';
    }

    if (!_years.contains(_selectedYear)) _years.add(_selectedYear);
    if (!_months.contains(_selectedMonth)) _months.add(_selectedMonth);

    _amountController = TextEditingController(text: widget.period.amount.toStringAsFixed(2));
    _lateFeeController = TextEditingController(text: widget.period.lateFeeRate?.toString() ?? '');
    _descController = TextEditingController(text: widget.period.description ?? '');
    _selectedDueDate = widget.period.dueDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _lateFeeController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      try {
        final data = {
          'period': '$_selectedYear - $_selectedMonth',
          'amount': double.parse(_amountController.text),
          'due_date': _selectedDueDate.toIso8601String().split('T')[0],
          'late_fee_rate': _lateFeeController.text.isEmpty ? null : double.parse(_lateFeeController.text),
          'description': _descController.text,
        };
        await context.read<FinanceCubit>().updateDuePeriod(widget.period.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aidat Dönemi başarıyla güncellendi'), backgroundColor: AppColors.success));
          context.pop();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _delete() async {
    try {
      await context.read<FinanceCubit>().deleteItem('due_period', widget.period.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aidat Dönemi silindi'), backgroundColor: AppColors.error));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.period.apartmentName} - ${widget.period.period}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFieldContainer(
                child: Column(
                  children: [
                    _buildDisabledField('Apartman / Site', widget.period.apartmentName),
                    const Divider(height: 32),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('Yıl', _years, _selectedYear, (v) => setState(() => _selectedYear = v!))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDropdown('Ay', _months, _selectedMonth, (v) => setState(() => _selectedMonth = v!))),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildTextField('Aidat Tutarı*', _amountController, TextInputType.number),
                    const Divider(height: 32),
                    _buildDatePicker('Son Ödeme Tarihi*', _selectedDueDate),
                    const Divider(height: 32),
                    _buildTextField('Aylık Gecikme Faizi Oranı (%)', _lateFeeController, TextInputType.number, hint: 'Boş bırakılırsa varsayılan uygulanır'),
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Boş bırakılırsa apartman varsayılan faizi kullanılır. Sıfır (0) girilirse faiz işlemez.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                    const Divider(height: 32),
                    _buildTextField('Açıklama', _descController, TextInputType.multiline, maxLines: 4),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Butonlar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _delete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Sil Aidat Dönemi', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDisabledField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.labelMedium),
            const Text('*', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(value, style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade600)),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type, {int maxLines = 1, String? hint}) {
    final isRequired = label.endsWith('*');
    final cleanLabel = label.replaceAll('*', '');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(cleanLabel, style: AppTextStyles.labelMedium),
            if (isRequired) const Text('*', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (v) {
            if (isRequired && (v == null || v.isEmpty)) return 'Bu alan zorunludur';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.labelMedium),
            const Text('*', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime date) {
    final strDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label.replaceAll('*', ''), style: AppTextStyles.labelMedium),
            const Text('*', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(strDate, style: AppTextStyles.bodyMedium),
                const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
