import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../finance/presentation/controllers/finance_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../finance/domain/models/debt.dart';
import '../../../finance/domain/models/payment.dart';

class ManagerEditDebtPage extends StatefulWidget {
  final Debt debt;

  const ManagerEditDebtPage({super.key, required this.debt});

  @override
  State<ManagerEditDebtPage> createState() => _ManagerEditDebtPageState();
}

class _ManagerEditDebtPageState extends State<ManagerEditDebtPage> {
  final _formKey = GlobalKey<FormState>();

  static const Map<String, String> _debtCategoryMap = {
    'Aidat Tahsilat': 'dues_collection',
    'Isınma / Yakıt': 'heating_fuel',
    'Ortak Alan': 'common_area',
    'Diğer': 'other',
  };


  late TextEditingController _descController;
  late TextEditingController _amountController;
  late TextEditingController _lateFeeController;
  
  late String _selectedCategory;
  late DateTime _selectedDueDate;

  final List<String> _categories = ['Aidat Tahsilat', 'Demirbaş', 'Ek Gider', 'Ceza', 'Diğer'];

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.debt.description);
    _amountController = TextEditingController(text: widget.debt.totalAmount.toStringAsFixed(2));
    _lateFeeController = TextEditingController(text: widget.debt.lateFeeRate.toString());
    
    _selectedCategory = widget.debt.categoryDisplay;
    if (!_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory);
    }
    
    _selectedDueDate = widget.debt.dueDate;
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    _lateFeeController.dispose();
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
          'description': _descController.text,
          'total_amount': double.parse(_amountController.text),
          'category': _debtCategoryMap[_selectedCategory] ?? 'other',
          'due_date': _selectedDueDate.toIso8601String().split('T')[0],
          'late_fee_rate': _lateFeeController.text.isEmpty ? null : double.parse(_lateFeeController.text),
        };
        await context.read<FinanceCubit>().updateDebt(widget.debt.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Borç başarıyla güncellendi'), backgroundColor: AppColors.success));
          context.pop();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _delete() async {
    try {
      await context.read<FinanceCubit>().deleteItem('debt', widget.debt.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Borç silindi'), backgroundColor: AppColors.error));
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
        title: Text(widget.debt.description),
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
                    _buildTextField('Açıklama*', _descController, TextInputType.text),
                    const Divider(height: 32),
                    _buildDisabledField('Daire*', widget.debt.unitDisplay ?? 'Bilinmiyor'),
                    const Divider(height: 32),
                    _buildTextField('Toplam Borç*', _amountController, TextInputType.number),
                    const Divider(height: 32),
                    _buildDropdown('Kategori*', _categories, _selectedCategory, (v) => setState(() => _selectedCategory = v!)),
                    const Divider(height: 32),
                    _buildDatePicker('Son Ödeme Tarihi', _selectedDueDate),
                    const Divider(height: 32),
                    _buildTextField('Aylık Gecikme Faizi Oranı (%)', _lateFeeController, TextInputType.number),
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Boş bırakılırsa aidat dönemi veya apartman varsayılan faizi kullanılır. Sıfır (0) girilirse faiz işlemez.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Ödemeler Bölümü
              const Text('Ödemeler', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              _buildPaymentsSection(),

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
                      child: const Text('Sil Borç', style: TextStyle(fontWeight: FontWeight.bold)),
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
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Toplu Borçlandırma ekranına yönlendirilecek')));
                },
                icon: const Icon(Icons.group_add_outlined, size: 20),
                label: const Text('Toplu Borçlandır'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentsSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.debt.payments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('Henüz ödeme kaydı bulunmuyor.', style: TextStyle(color: Colors.grey))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.debt.payments.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final payment = widget.debt.payments[index];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(payment.debtDescription ?? 'Ödeme', style: AppTextStyles.labelMedium),
                          const SizedBox(height: 4),
                          Text(DateFormat('dd/MM/yyyy HH:mm').format(payment.paymentDate), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₺${payment.amount.toStringAsFixed(2)}', style: AppTextStyles.titleMedium.copyWith(color: AppColors.success)),
                          const SizedBox(height: 4),
                          payment.status == 'approved'
                              ? const Text('Onaylandı', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold))
                              : const Text('Bekliyor', style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          
          const Divider(height: 1),
          InkWell(
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yeni ödeme ekleme dialogu açılacak')));
            },
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.add_circle, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Başka bir Ödeme ekle', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          )
        ],
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
