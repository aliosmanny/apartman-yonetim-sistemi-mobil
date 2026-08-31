import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../finance/presentation/controllers/finance_cubit.dart';
import '../../../finance/presentation/controllers/finance_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/controllers/auth_cubit.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../../properties/presentation/controllers/properties_cubit.dart';
import '../../../properties/presentation/controllers/properties_state.dart';

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
    _tabController = TabController(length: 5, vsync: this);
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
          isScrollable: true,
          tabs: const [
            Tab(text: 'Aidat Dönemi'),
            Tab(text: 'Gelir Ekle'),
            Tab(text: 'Gider Ekle'),
            Tab(text: 'Borçlandır'),
            Tab(text: 'Ödeme Ekle'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _DuesPeriodFormTab(),
          _IncomeFormTab(),
          _ExpenseFormTab(),
          _DebtFormTab(),
          _PaymentFormTab(),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// DUES PERIOD TAB
// ──────────────────────────────────────────
class _DuesPeriodFormTab extends StatefulWidget {
  const _DuesPeriodFormTab();

  @override
  State<_DuesPeriodFormTab> createState() => _DuesPeriodFormTabState();
}

class _DuesPeriodFormTabState extends State<_DuesPeriodFormTab> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _lateFeeController = TextEditingController();
  
  String _year = DateTime.now().year.toString();
  String _month = DateTime.now().month.toString().padLeft(2, '0');
  DateTime _dueDate = DateTime.now().add(const Duration(days: 10));

  bool _isSaving = false;
  int? _selectedApartmentId;
  late List<DropdownMenuItem<int>> _apartmentItems = [];
  bool _isManager = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final authState = sl<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _isManager = authState.user.role == UserRole.apartmentManager;
    }

    final propState = sl<PropertiesCubit>().state;
    final apts = <int, String>{};
    
    if (propState is PropertiesLoaded) {
      for (var a in propState.apartments) {
        apts[a.id] = a.name;
      }
    }
    
    _apartmentItems = apts.entries.map((e) => DropdownMenuItem<int>(value: e.key, child: Text(e.value))).toList();
    
    if (_isManager || apts.length == 1) {
      if (apts.isNotEmpty && _selectedApartmentId == null) {
        _selectedApartmentId = apts.keys.first;
      }
    } else if (_selectedApartmentId == null && apts.isNotEmpty) {
      _selectedApartmentId = apts.keys.first;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedApartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen apartman seçiniz'), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isSaving = true);
    try {
      const monthNames = {
        '01': 'Ocak', '02': 'Şubat', '03': 'Mart', '04': 'Nisan',
        '05': 'Mayıs', '06': 'Haziran', '07': 'Temmuz', '08': 'Ağustos',
        '09': 'Eylül', '10': 'Ekim', '11': 'Kasım', '12': 'Aralık'
      };
      final monthName = monthNames[_month] ?? 'Ocak';
      
      final data = {
        'apartment': _selectedApartmentId,
        'apartment_id': _selectedApartmentId,
        'period': '$_year - $monthName',
        'amount': double.parse(_amountController.text),
        'due_date': _dueDate.toIso8601String().split('T')[0],
      };
      
      if (_descController.text.trim().isNotEmpty) {
        data['description'] = _descController.text.trim();
      }
      if (_lateFeeController.text.trim().isNotEmpty) {
        data['late_fee_rate'] = double.parse(_lateFeeController.text.trim());
      }
      
      await context.read<FinanceCubit>().createDuePeriod(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aidat dönemi başarıyla oluşturuldu'), backgroundColor: AppColors.success));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (e is DioException) {
          if (e.response != null && e.response!.data != null) {
            msg = e.response!.data.toString();
          } else {
            msg = e.message ?? 'Bilinmeyen bağlantı hatası';
          }
        } else if (msg.startsWith('Exception: ApiException(status:')) {
          msg = msg.split('message:').last.replaceAll(')', '').trim();
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Hata: $msg'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final years = List.generate(5, (index) => (DateTime.now().year - 1 + index).toString());
    final months = [
      {'value': '01', 'label': 'Ocak'},
      {'value': '02', 'label': 'Şubat'},
      {'value': '03', 'label': 'Mart'},
      {'value': '04', 'label': 'Nisan'},
      {'value': '05', 'label': 'Mayıs'},
      {'value': '06', 'label': 'Haziran'},
      {'value': '07', 'label': 'Temmuz'},
      {'value': '08', 'label': 'Ağustos'},
      {'value': '09', 'label': 'Eylül'},
      {'value': '10', 'label': 'Ekim'},
      {'value': '11', 'label': 'Kasım'},
      {'value': '12', 'label': 'Aralık'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Apartman / Site*', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _apartmentItems.any((e) => e.value == _selectedApartmentId) ? _selectedApartmentId : null,
              decoration: InputDecoration(
                hintText: '--- Seçiniz ---',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: _apartmentItems,
              onChanged: (_isManager || _apartmentItems.length <= 1) ? null : (val) => setState(() => _selectedApartmentId = val),
              validator: (v) => v == null ? 'Zorunlu' : null,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildDropdown('Yıl*', years, _year, (v) => setState(() => _year = v!)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ay*', style: AppTextStyles.labelMedium),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _month,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        items: months.map((e) => DropdownMenuItem(value: e['value'], child: Text(e['label']!))).toList(),
                        onChanged: (v) => setState(() => _month = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildField('Aidat Tutarı*', _amountController, isNum: true),
            const SizedBox(height: 16),
            _buildDatePicker('Son Ödeme Tarihi*', _dueDate, (v) => setState(() => _dueDate = v)),
            const SizedBox(height: 16),
            _buildField('Aylık Gecikme Faizi Oranı (%)', _lateFeeController, isNum: true, hint: 'Boş bırakılırsa varsayılan uygulanır', required: false),
            const SizedBox(height: 16),
            _buildField('Açıklama', _descController, maxLines: 3, required: false),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Aidat Dönemi Oluştur'),
            ),
          ],
        ),
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
  
  String _category = 'other';
  DateTime? _date = DateTime.now();
  int? _selectedApartmentId;
  bool _isManager = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = sl<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _isManager = authState.user.role == UserRole.apartmentManager;
    }
    
    final propState = sl<PropertiesCubit>().state;
    if (propState is PropertiesLoaded) {
      if (propState.apartments.isNotEmpty && _selectedApartmentId == null) {
        if (_isManager || propState.apartments.length == 1) {
          _selectedApartmentId = propState.apartments.first.id;
        }
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedApartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen apartman/site seçiniz'), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final data = {
        'apartment': _selectedApartmentId,
        'apartment_id': _selectedApartmentId,
        'title': _titleController.text.trim(),
        'amount': double.parse(_amountController.text),
        'category': _category,
        'date': _date?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
      };
      
      if (_descController.text.trim().isNotEmpty) {
        data['description'] = _descController.text.trim();
      }
      
      await context.read<FinanceCubit>().createIncome(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gelir başarıyla eklendi'), backgroundColor: AppColors.success));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (e is DioException) {
          if (e.response != null && e.response!.data != null) {
            msg = e.response!.data.toString();
          } else {
            msg = e.message ?? 'Bilinmeyen bağlantı hatası';
          }
        } else if (msg.startsWith('Exception: ApiException(status:')) {
          msg = msg.split('message:').last.replaceAll(')', '').trim();
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $msg'), backgroundColor: AppColors.error, duration: const Duration(seconds: 4)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
            // Apartman Seçimi
            Text('Apartman / Site*', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            BlocBuilder<PropertiesCubit, PropertiesState>(
              bloc: sl<PropertiesCubit>(),
              builder: (context, state) {
                if (state is PropertiesLoaded) {
                  final apartments = state.apartments;
                  return DropdownButtonFormField<int>(
                    value: apartments.any((a) => a.id == _selectedApartmentId) ? _selectedApartmentId : null,
                    decoration: InputDecoration(
                      hintText: 'Seçim yapınız',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: apartments.map((a) => DropdownMenuItem(
                      value: a.id,
                      child: Text(a.name),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedApartmentId = val),
                    validator: (v) => v == null ? 'Zorunlu alan' : null,
                  );
                }
                return const LinearProgressIndicator();
              },
            ),
            const SizedBox(height: 16),
            
            _buildField('Gelir Başlığı*', _titleController),
            const SizedBox(height: 16),
            
            Text('Kategori*', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: _ManagerAddExpensePageState._incomeCategoryMap.entries.map((e) => DropdownMenuItem(
                value: e.value,
                child: Text(e.key),
              )).toList(),
              onChanged: (val) => setState(() => _category = val!),
            ),
            const SizedBox(height: 16),
            
            _buildField('Tutar*', _amountController, isNum: true),
            const SizedBox(height: 16),
            
            Text('Gelir Tarihi*', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context, 
                  initialDate: _date ?? DateTime.now(), 
                  firstDate: DateTime(2000), 
                  lastDate: DateTime(2100)
                );
                if (date != null) setState(() => _date = date);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_date == null ? '' : '${_date!.day.toString().padLeft(2, '0')}/${_date!.month.toString().padLeft(2, '0')}/${_date!.year}', style: AppTextStyles.bodyMedium),
                    const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildField('Açıklama', _descController, maxLines: 4, required: false),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Kaydet'),
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
  
  String _category = 'other';
  DateTime? _date = DateTime.now();
  int? _selectedApartmentId;
  bool _isManager = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = sl<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _isManager = authState.user.role == UserRole.apartmentManager;
    }
    
    final propState = sl<PropertiesCubit>().state;
    if (propState is PropertiesLoaded) {
      if (propState.apartments.isNotEmpty && _selectedApartmentId == null) {
        if (_isManager || propState.apartments.length == 1) {
          _selectedApartmentId = propState.apartments.first.id;
        }
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedApartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen apartman/site seçiniz'), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final data = {
        'apartment': _selectedApartmentId,
        'apartment_id': _selectedApartmentId,
        'title': _titleController.text.trim(),
        'amount': double.parse(_amountController.text),
        'category': _category,
        'date': _date?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
      };
      
      if (_descController.text.trim().isNotEmpty) {
        data['description'] = _descController.text.trim();
      }
      
      await context.read<FinanceCubit>().createExpense(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gider başarıyla eklendi'), backgroundColor: AppColors.success));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (e is DioException) {
          if (e.response != null && e.response!.data != null) {
            msg = e.response!.data.toString();
          } else {
            msg = e.message ?? 'Bilinmeyen bağlantı hatası';
          }
        } else if (msg.startsWith('Exception: ApiException(status:')) {
          msg = msg.split('message:').last.replaceAll(')', '').trim();
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $msg'), backgroundColor: AppColors.error, duration: const Duration(seconds: 4)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
            // Apartman Seçimi
            Text('Apartman / Site*', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            BlocBuilder<PropertiesCubit, PropertiesState>(
              bloc: sl<PropertiesCubit>(),
              builder: (context, state) {
                if (state is PropertiesLoaded) {
                  final apartments = state.apartments;
                  return DropdownButtonFormField<int>(
                    value: apartments.any((a) => a.id == _selectedApartmentId) ? _selectedApartmentId : null,
                    decoration: InputDecoration(
                      hintText: 'Seçim yapınız',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: apartments.map((a) => DropdownMenuItem(
                      value: a.id,
                      child: Text(a.name),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedApartmentId = val),
                    validator: (v) => v == null ? 'Zorunlu alan' : null,
                  );
                }
                return const LinearProgressIndicator();
              },
            ),
            const SizedBox(height: 16),
            
            _buildField('Gider Başlığı*', _titleController),
            const SizedBox(height: 16),
            
            Text('Kategori*', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: _ManagerAddExpensePageState._expenseCategoryMap.entries.map((e) => DropdownMenuItem(
                value: e.value,
                child: Text(e.key),
              )).toList(),
              onChanged: (val) => setState(() => _category = val!),
            ),
            const SizedBox(height: 16),
            
            _buildField('Tutar*', _amountController, isNum: true),
            const SizedBox(height: 16),
            
            Text('Gider Tarihi*', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context, 
                  initialDate: _date ?? DateTime.now(), 
                  firstDate: DateTime(2000), 
                  lastDate: DateTime(2100)
                );
                if (date != null) setState(() => _date = date);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_date == null ? '' : '${_date!.day.toString().padLeft(2, '0')}/${_date!.month.toString().padLeft(2, '0')}/${_date!.year}', style: AppTextStyles.bodyMedium),
                    const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildField('Açıklama', _descController, maxLines: 4, required: false),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Kaydet'),
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
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  final _lateFeeController = TextEditingController();
  DateTime? _dueDate;

  String _category = 'dues_collection';
  int? _selectedApartmentId;
  int? _selectedUnitId;
  bool _isSaving = false;
  bool _isManager = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = sl<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _isManager = authState.user.role == UserRole.apartmentManager;
    }
    
    final propState = sl<PropertiesCubit>().state;
    if (propState is PropertiesLoaded) {
      if (propState.apartments.isNotEmpty && _selectedApartmentId == null) {
        if (_isManager || propState.apartments.length == 1) {
          _selectedApartmentId = propState.apartments.first.id;
        }
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen daire seçiniz'), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final data = {
        'unit': _selectedUnitId,
        'unit_id': _selectedUnitId,
        'description': _descController.text.trim(),
        'total_amount': double.parse(_amountController.text),
        'category': _category,
      };
      
      if (_dueDate != null) {
        data['due_date'] = _dueDate!.toIso8601String().split('T')[0];
      }
      if (_lateFeeController.text.trim().isNotEmpty) {
        data['late_fee_rate'] = double.parse(_lateFeeController.text.trim());
      }
      
      await context.read<FinanceCubit>().createDebt(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Borçlandırma başarılı'), backgroundColor: AppColors.success));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (e is DioException) {
          if (e.response != null && e.response!.data != null) {
            msg = e.response!.data.toString();
          } else {
            msg = e.message ?? 'Bilinmeyen bağlantı hatası';
          }
        } else if (msg.startsWith('Exception: ApiException(status:')) {
          msg = msg.split('message:').last.replaceAll(')', '').trim();
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $msg'), backgroundColor: AppColors.error, duration: const Duration(seconds: 4)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
            _buildField('Açıklama*', _descController),
            const SizedBox(height: 16),
            
            // Daire Seçimi
            Text('Daire*', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            BlocBuilder<PropertiesCubit, PropertiesState>(
              bloc: sl<PropertiesCubit>(),
              builder: (context, state) {
                if (state is PropertiesLoaded) {
                  final allUnits = state.units;
                  final allBlocks = state.blocks;
                  
                  final filteredUnits = allUnits.where((u) {
                    if (_selectedApartmentId != null) {
                      return allBlocks.any((b) => b.apartmentId == _selectedApartmentId && b.id == u.blockId);
                    }
                    return true;
                  }).toList();

                  return DropdownButtonFormField<int>(
                    value: _selectedUnitId,
                    decoration: InputDecoration(
                      hintText: 'Seçim yapınız',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: filteredUnits.map((u) => DropdownMenuItem(
                      value: u.id,
                      child: Text('Blok ${u.blockName} - Daire ${u.number}'),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedUnitId = val),
                    validator: (v) => v == null ? 'Zorunlu alan' : null,
                  );
                }
                return const LinearProgressIndicator();
              },
            ),
            const SizedBox(height: 16),
            
            _buildField('Toplam Borç*', _amountController, isNum: true),
            const SizedBox(height: 16),
            
            Text('Kategori*', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: _ManagerAddExpensePageState._incomeCategoryMap.entries.map((e) => DropdownMenuItem(
                value: e.value,
                child: Text(e.key),
              )).toList(),
              onChanged: (val) => setState(() => _category = val!),
            ),
            const SizedBox(height: 16),
            
            Text('Son Ödeme Tarihi', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context, 
                  initialDate: _dueDate ?? DateTime.now(), 
                  firstDate: DateTime(2000), 
                  lastDate: DateTime(2100)
                );
                if (date != null) setState(() => _dueDate = date);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_dueDate == null ? '' : '${_dueDate!.day.toString().padLeft(2, '0')}/${_dueDate!.month.toString().padLeft(2, '0')}/${_dueDate!.year}', style: AppTextStyles.bodyMedium),
                    const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildField('Aylık Gecikme Faizi Oranı (%)', _lateFeeController, isNum: true, hint: 'Boş bırakılırsa aidat dönemi veya apartman varsayılan faizi kullanılır. Sıfır (0) girilirse faiz işlemez.', required: false),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Kaydet'),
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
Widget _buildField(String label, TextEditingController controller, {bool isNum = false, int maxLines = 1, String? hint, bool required = true}) {
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
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: required ? (v) => (v == null || v.isEmpty) ? 'Zorunlu alan' : null : null,
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

// ──────────────────────────────────────────
// PAYMENT TAB
// ──────────────────────────────────────────
class _PaymentFormTab extends StatefulWidget {
  const _PaymentFormTab();

  @override
  State<_PaymentFormTab> createState() => _PaymentFormTabState();
}

class _PaymentFormTabState extends State<_PaymentFormTab> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _transactionIdController = TextEditingController();
  
  String? _selectedDebtId;
  bool _isSaving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDebtId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen borç seçiniz'), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final data = {
        'debt': _selectedDebtId,
        'amount': double.parse(_amountController.text),
      };
      
      if (_descController.text.trim().isNotEmpty) {
        data['note'] = _descController.text.trim();
        data['description'] = _descController.text.trim();
      }
      if (_transactionIdController.text.trim().isNotEmpty) {
        data['transaction_id'] = _transactionIdController.text.trim();
      }
      
      await context.read<FinanceCubit>().createPayment(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ödeme başarıyla eklendi'), backgroundColor: AppColors.success));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (e is DioException) {
          if (e.response != null && e.response!.data != null) {
            msg = e.response!.data.toString();
          } else {
            msg = e.message ?? 'Bilinmeyen bağlantı hatası';
          }
        } else if (msg.startsWith('Exception: ApiException(status:')) {
          msg = msg.split('message:').last.replaceAll(')', '').trim();
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $msg'), backgroundColor: AppColors.error, duration: const Duration(seconds: 4)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
            Text('Borç*', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            BlocBuilder<FinanceCubit, FinanceState>(
              builder: (context, state) {
                if (state is FinanceLoaded) {
                  // Sadece ödenmemiş veya kısmi ödenmiş borçlar (örneğin pending, overdue, partial)
                  final activeDebts = state.debts.where((d) => d.status != 'paid').toList();
                  
                  return DropdownButtonFormField<String>(
                    value: activeDebts.any((d) => d.id == _selectedDebtId) ? _selectedDebtId : null,
                    isExpanded: true,
                    decoration: InputDecoration(
                      hintText: 'Seçim yapınız',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: activeDebts.map((d) {
                      String label = d.description;
                      if (d.unitDisplay != null) {
                        label = '${d.unitDisplay} - $label';
                      }
                      label += ' (${d.remainingAmount.toStringAsFixed(2)} ₺)';
                      
                      return DropdownMenuItem(
                        value: d.id,
                        child: Text(label, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedDebtId = val;
                        if (val != null) {
                          final selectedDebt = activeDebts.firstWhere((d) => d.id == val);
                          _amountController.text = selectedDebt.remainingAmount.toStringAsFixed(2);
                          _descController.text = 'Ödeme: ${selectedDebt.description}';
                          
                          // Generate random UUID-like transaction ID
                          final rnd = (DateTime.now().millisecondsSinceEpoch % 1000000000).toString();
                          final hex = (val.hashCode).toRadixString(16);
                          _transactionIdController.text = 'TXN-$hex-$rnd';
                        }
                      });
                    },
                    validator: (v) => v == null ? 'Zorunlu alan' : null,
                  );
                }
                return const LinearProgressIndicator();
              },
            ),
            const SizedBox(height: 16),
            
            _buildField('Ödeme Tutarı*', _amountController, isNum: true),
            const SizedBox(height: 16),
            
            _buildField('Açıklama', _descController, maxLines: 3, required: false),
            const SizedBox(height: 16),
            
            _buildField('İşlem Numarası', _transactionIdController, required: false),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
