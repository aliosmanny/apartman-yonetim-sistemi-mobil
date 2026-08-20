import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../finance/presentation/controllers/finance_cubit.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../finance/domain/models/income.dart';
import '../../../finance/domain/models/expense.dart';

class ManagerEditTransactionPage extends StatefulWidget {
  final Income? income;
  final Expense? expense;

  const ManagerEditTransactionPage({super.key, this.income, this.expense})
      : assert(income != null || expense != null);

  @override
  State<ManagerEditTransactionPage> createState() => _ManagerEditTransactionPageState();
}

class _ManagerEditTransactionPageState extends State<ManagerEditTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  static const Map<String, String> _incomeCategoryMap = {
    'Aidat Tahsilat': 'dues_collection',
    'Isınma / Yakıt': 'heating_fuel',
    'Ortak Alan': 'common_area',
    'Diğer': 'other',
  };

  static const Map<String, String> _expenseCategoryMap = {
    'Elektrik': 'electricity',
    'Su': 'water',
    'Doğalgaz': 'natural_gas',
    'Temizlik': 'cleaning',
    'Personel Giderleri': 'staff_expenses',
    'Asansör Bakımı': 'elevator_maintenance',
    'Güvenlik': 'security',
    'Bahçe Bakımı': 'garden_maintenance',
    'Demirbaş': 'fixtures',
    'Diğer Giderler': 'other',
  };


  late bool _isIncome;
  late String _id;
  late String _apartmentName;
  late String _selectedCategory;
  late DateTime _selectedDate;

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descController;

  final List<String> _incomeCategories = _incomeCategoryMap.keys.toList();
  final List<String> _expenseCategories = _expenseCategoryMap.keys.toList();

  @override
  void initState() {
    super.initState();
    _isIncome = widget.income != null;

    if (_isIncome) {
      _id = widget.income!.id;
      _apartmentName = widget.income!.apartmentName ?? 'Apartman/Site';
      _titleController = TextEditingController(text: widget.income!.title);
      _amountController = TextEditingController(text: widget.income!.amount.toStringAsFixed(2));
      _selectedCategory = _incomeCategoryMap.containsKey(widget.income!.categoryDisplay) 
          ? widget.income!.categoryDisplay 
          : 'Diğer';
      _selectedDate = widget.income!.date;
      _descController = TextEditingController(text: widget.income!.description);
      
      if (!_incomeCategories.contains(_selectedCategory)) {
        _incomeCategories.add(_selectedCategory);
      }
    } else {
      _id = widget.expense!.id;
      _apartmentName = widget.expense!.apartmentName ?? 'Apartman/Site';
      _titleController = TextEditingController(text: widget.expense!.title);
      _amountController = TextEditingController(text: widget.expense!.amount.toStringAsFixed(2));
      _selectedCategory = _expenseCategoryMap.containsKey(widget.expense!.categoryDisplay) 
          ? widget.expense!.categoryDisplay 
          : 'Diğer Giderler';
      _selectedDate = widget.expense!.date;
      _descController = TextEditingController(text: widget.expense!.description);
      
      if (!_expenseCategories.contains(_selectedCategory)) {
        _expenseCategories.add(_selectedCategory);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      try {
        final data = {
          'title': _titleController.text,
          'amount': double.parse(_amountController.text),
          'date': _selectedDate.toIso8601String().split('T')[0],
          'description': _descController.text,
          'category': _isIncome 
              ? (_incomeCategoryMap[_selectedCategory] ?? 'other') 
              : (_expenseCategoryMap[_selectedCategory] ?? 'other'),
        };
        
        if (_isIncome) {
           await context.read<FinanceCubit>().updateIncome(_id, data);
        } else {
           await context.read<FinanceCubit>().updateExpense(_id, data);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_isIncome ? "Gelir" : "Gider"} başarıyla güncellendi'), backgroundColor: AppColors.success));
          context.pop();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _delete() async {
    try {
      await context.read<FinanceCubit>().deleteItem(_isIncome ? 'income' : 'expense', _id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_isIncome ? "Gelir" : "Gider"} silindi'), backgroundColor: AppColors.error));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelType = _isIncome ? 'Gelir' : 'Gider';
    final categories = _isIncome ? _incomeCategories : _expenseCategories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_titleController.text.isEmpty ? 'Yeni $labelType' : _titleController.text),
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
                    _buildDisabledField('Apartman / Site*', _apartmentName),
                    const Divider(height: 32),
                    _buildTextField('$labelType Başlığı*', _titleController, TextInputType.text),
                    const Divider(height: 32),
                    _buildTextField('Tutar*', _amountController, TextInputType.number),
                    const Divider(height: 32),
                    _buildDropdown('Kategori*', categories, _selectedCategory, (v) => setState(() => _selectedCategory = v!)),
                    const Divider(height: 32),
                    _buildDatePicker('$labelType Tarihi*', _selectedDate),
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
                      child: Text('Sil $labelType', style: const TextStyle(fontWeight: FontWeight.bold)),
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
            Text(label.replaceAll('*', ''), style: AppTextStyles.labelMedium),
            if (label.endsWith('*')) const Text('*', style: TextStyle(color: Colors.red)),
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
            Text(label.replaceAll('*', ''), style: AppTextStyles.labelMedium),
            if (label.endsWith('*')) const Text('*', style: TextStyle(color: Colors.red)),
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
            if (label.endsWith('*')) const Text('*', style: TextStyle(color: Colors.red)),
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
