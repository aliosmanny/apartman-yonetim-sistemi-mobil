import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../finance/presentation/controllers/finance_cubit.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class ManagerAddExpensePage extends StatefulWidget {
  const ManagerAddExpensePage({super.key});

  @override
  State<ManagerAddExpensePage> createState() => _ManagerAddExpensePageState();
}

class _ManagerAddExpensePageState extends State<ManagerAddExpensePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Finans Kaydı', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(text: 'Gelir Ekle'),
            Tab(text: 'Gider Ekle'),
            Tab(text: 'Borçlandır'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _IncomeFormTab(),
          _ExpenseFormTab(),
          _DebtFormTab(),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// INCOME TAB
// ──────────────────────────────────────────
class _IncomeFormTab extends StatefulWidget {
  const _IncomeFormTab();

  @override
  State<_IncomeFormTab> createState() => _IncomeFormTabState();
}

class _IncomeFormTabState extends State<_IncomeFormTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'Aidat Geliri';
  DateTime _date = DateTime.now();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final data = {
        'title': _titleController.text,
        'amount': double.parse(_amountController.text),
        'description': _descController.text,
        'date': _date.toIso8601String().split('T')[0],
        'category': _category == 'Aidat Geliri' ? 'dues' : 'other',
      };
      await context.read<FinanceCubit>().createIncome(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gelir başarıyla eklendi'), backgroundColor: AppColors.success));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildField('Gelir Başlığı', _titleController),
            const SizedBox(height: 16),
            _buildField('Tutar (₺)', _amountController, isNum: true),
            const SizedBox(height: 16),
            _buildDropdown('Kategori', ['Aidat Geliri', 'Demirbaş Geliri', 'Kira Geliri', 'Diğer'], _category, (v) => setState(() => _category = v!)),
            const SizedBox(height: 16),
            _buildDatePicker('Tarih', _date, (v) => setState(() => _date = v)),
            const SizedBox(height: 16),
            _buildField('Açıklama', _descController, maxLines: 3),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Geliri Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// EXPENSE TAB
// ──────────────────────────────────────────
class _ExpenseFormTab extends StatefulWidget {
  const _ExpenseFormTab();

  @override
  State<_ExpenseFormTab> createState() => _ExpenseFormTabState();
}

class _ExpenseFormTabState extends State<_ExpenseFormTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'Bakım Onarım';
  DateTime _date = DateTime.now();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final data = {
        'title': _titleController.text,
        'amount': double.parse(_amountController.text),
        'description': _descController.text,
        'date': _date.toIso8601String().split('T')[0],
        'category': _category == 'Fatura' ? 'bill' : 'other',
      };
      await context.read<FinanceCubit>().createExpense(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gider başarıyla eklendi'), backgroundColor: AppColors.success));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildField('Gider Başlığı', _titleController),
            const SizedBox(height: 16),
            _buildField('Tutar (₺)', _amountController, isNum: true),
            const SizedBox(height: 16),
            _buildDropdown('Kategori', ['Bakım Onarım', 'Temizlik', 'Personel', 'Fatura', 'Diğer'], _category, (v) => setState(() => _category = v!)),
            const SizedBox(height: 16),
            _buildDatePicker('Tarih', _date, (v) => setState(() => _date = v)),
            const SizedBox(height: 16),
            _buildField('Açıklama', _descController, maxLines: 3),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Gideri Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// DEBT TAB
// ──────────────────────────────────────────
class _DebtFormTab extends StatefulWidget {
  const _DebtFormTab();

  @override
  State<_DebtFormTab> createState() => _DebtFormTabState();
}

class _DebtFormTabState extends State<_DebtFormTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  String _target = 'Tüm Daireler (Toplu)';
  DateTime _date = DateTime.now().add(const Duration(days: 10));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final data = {
        'description': _titleController.text,
        'total_amount': double.parse(_amountController.text),
        'category': 'other',
        'due_date': _date.toIso8601String().split('T')[0],
      };
      await context.read<FinanceCubit>().createDebt(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Borçlandırma başarılı'), backgroundColor: AppColors.success));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info),
                  SizedBox(width: 12),
                  Expanded(child: Text('Tüm apartmanı veya belirli bir daireyi borçlandırabilirsiniz.', style: AppTextStyles.bodySmall)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildDropdown('Kimi Borçlandıracaksınız?', ['Tüm Daireler (Toplu)', 'Belirli Daire Seç'], _target, (v) => setState(() => _target = v!)),
            const SizedBox(height: 16),
            _buildField('Borç Başlığı / Açıklama', _titleController),
            const SizedBox(height: 16),
            _buildField('Tutar (₺)', _amountController, isNum: true),
            const SizedBox(height: 16),
            _buildDatePicker('Son Ödeme Tarihi', _date, (v) => setState(() => _date = v)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Borçlandır'),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// REUSABLE WIDGETS
// ──────────────────────────────────────────
Widget _buildField(String label, TextEditingController controller, {bool isNum = false, int maxLines = 1}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.labelMedium),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Zorunlu alan' : null,
      ),
    ],
  );
}

Widget _buildDropdown(String label, List<String> items, String value, void Function(String?) onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.labelMedium),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    ],
  );
}

Widget _buildDatePicker(String label, DateTime date, void Function(DateTime) onPicked) {
  return StatefulBuilder(
    builder: (context, setStateBuilder) {
      final strDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2030));
              if (picked != null) onPicked(picked);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(strDate, style: AppTextStyles.bodyMedium),
                  const Icon(Icons.calendar_today_outlined, size: 20),
                ],
              ),
            ),
          ),
        ],
      );
    }
  );
}
