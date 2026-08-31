import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../finance/domain/models/debt.dart';
import '../../../finance/domain/models/expense.dart';
import '../../../finance/domain/models/income.dart';
import '../../../finance/domain/models/due_period.dart';
import '../../../finance/domain/models/payment.dart';
import '../../../finance/domain/models/finance_summary.dart';
import '../../../finance/presentation/controllers/finance_cubit.dart';
import '../../../finance/presentation/controllers/finance_state.dart';
import 'package:intl/intl.dart';
import '../../../finance/presentation/widgets/payment_dialog.dart';

class ManagerFinancePage extends StatelessWidget {
  const ManagerFinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FinanceCubit>()..fetchManagerFinance(),
      child: const _ManagerFinanceView(),
    );
  }
}

class _ManagerFinanceView extends StatefulWidget {
  const _ManagerFinanceView();

  @override
  State<_ManagerFinanceView> createState() => _ManagerFinanceViewState();
}

class _ManagerFinanceViewState extends State<_ManagerFinanceView> {
  // Aidat Dönemleri Filtreleri (Tab 0)
  String _selectedDuePeriodApartment = 'all';
  
  // Borçlar Filtreleri (Tab 1)
  String _selectedDebtStatus = 'all';
  String _selectedDebtApartment = 'all';
  
  // Gelirler Filtreleri (Tab 3)
  String _selectedIncomeCategory = 'all';
  String _selectedIncomeApartment = 'all';
  
  // Giderler Filtreleri (Tab 4)
  String _selectedExpenseCategory = 'all';
  String _selectedExpenseApartment = 'all';

  void _showDeleteDialog(BuildContext context, String type, String id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silme İşlemi'),
        content: Text('"$title" silinecek. Onaylıyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<FinanceCubit>().deleteItem(type, id);
            },
            child: const Text('Sil', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _toOptions(Iterable<String> list) {
    return list.map((e) => {'value': e, 'label': e == 'all' ? 'Tümü' : e}).toList();
  }

  Widget _buildListCard({
    required List<Map<String, String>> items,
    required String selectedValue,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, idx) {
          final item = items[idx];
          final isSelected = selectedValue == item['value'];
          return ListTile(
            dense: true,
            title: Text(
              item['label']!,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isSelected 
                ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                : null,
            onTap: () => onChanged(item['value']!),
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, FinanceLoaded state) {
    final index = DefaultTabController.of(context).index;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String tempDueApt = _selectedDuePeriodApartment;
        String tempDebtStatus = _selectedDebtStatus;
        String tempDebtApt = _selectedDebtApartment;
        String tempIncCat = _selectedIncomeCategory;
        String tempIncApt = _selectedIncomeApartment;
        String tempExpCat = _selectedExpenseCategory;
        String tempExpApt = _selectedExpenseApartment;

        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            int count = 0;
            Widget filterContent = const SizedBox();

            if (index == 0) {
              // AİDAT DÖNEMLERİ
              final apartments = ['all', ...state.duePeriods.map((p) => p.apartmentName).toSet()];
              count = state.duePeriods.where((p) {
                return tempDueApt == 'all' || p.apartmentName == tempDueApt;
              }).length;

              filterContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Apartman / Site süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListCard(
                    items: _toOptions(apartments),
                    selectedValue: tempDueApt,
                    onChanged: (val) => setBottomSheetState(() => tempDueApt = val),
                  ),
                ],
              );
            } else if (index == 1) {
              // BORÇLAR
              final statuses = const [
                {'value': 'all', 'label': 'Tümü'},
                {'value': 'unpaid', 'label': 'Ödenmedi'},
                {'value': 'paid', 'label': 'Ödendi'},
                {'value': 'overdue', 'label': 'Gecikmiş'},
              ];
              final apartments = ['all', ...state.debts.map((d) => d.apartmentName).whereType<String>().toSet()];
              
              count = state.debts.where((d) {
                final matchesApt = tempDebtApt == 'all' || d.apartmentName == tempDebtApt;
                final matchesStatus = tempDebtStatus == 'all' ||
                    (tempDebtStatus == 'paid' && d.isPaid) ||
                    (tempDebtStatus == 'unpaid' && !d.isPaid && !d.isOverdue) ||
                    (tempDebtStatus == 'overdue' && d.isOverdue);
                return matchesApt && matchesStatus;
              }).length;

              filterContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Borç Durumu süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListCard(
                    items: statuses,
                    selectedValue: tempDebtStatus,
                    onChanged: (val) => setBottomSheetState(() => tempDebtStatus = val),
                  ),
                  const SizedBox(height: 24),
                  Text('Apartman / Site süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListCard(
                    items: _toOptions(apartments),
                    selectedValue: tempDebtApt,
                    onChanged: (val) => setBottomSheetState(() => tempDebtApt = val),
                  ),
                ],
              );
            } else if (index == 3) {
              // GELİRLER
              final categories = ['all', ...state.incomes.map((i) => i.categoryDisplay).toSet()];
              final apartments = ['all', ...state.incomes.map((i) => i.apartmentName).whereType<String>().toSet()];

              count = state.incomes.where((i) {
                final matchesApt = tempIncApt == 'all' || i.apartmentName == tempIncApt;
                final matchesCat = tempIncCat == 'all' || i.categoryDisplay == tempIncCat;
                return matchesApt && matchesCat;
              }).length;

              filterContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kategori süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListCard(
                    items: _toOptions(categories),
                    selectedValue: tempIncCat,
                    onChanged: (val) => setBottomSheetState(() => tempIncCat = val),
                  ),
                  const SizedBox(height: 24),
                  Text('Apartman / Site süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListCard(
                    items: _toOptions(apartments),
                    selectedValue: tempIncApt,
                    onChanged: (val) => setBottomSheetState(() => tempIncApt = val),
                  ),
                ],
              );
            } else if (index == 4) {
              // GİDERLER
              final categories = ['all', ...state.expenses.map((e) => e.categoryDisplay).toSet()];
              final apartments = ['all', ...state.expenses.map((e) => e.apartmentName).whereType<String>().toSet()];

              count = state.expenses.where((e) {
                final matchesApt = tempExpApt == 'all' || e.apartmentName == tempExpApt;
                final matchesCat = tempExpCat == 'all' || e.categoryDisplay == tempExpCat;
                return matchesApt && matchesCat;
              }).length;

              filterContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kategori süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListCard(
                    items: _toOptions(categories),
                    selectedValue: tempExpCat,
                    onChanged: (val) => setBottomSheetState(() => tempExpCat = val),
                  ),
                  const SizedBox(height: 24),
                  Text('Apartman / Site süzgecine göre', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildListCard(
                    items: _toOptions(apartments),
                    selectedValue: tempExpApt,
                    onChanged: (val) => setBottomSheetState(() => tempExpApt = val),
                  ),
                ],
              );
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Filtrele', style: AppTextStyles.headlineSmall),
                        TextButton(
                          onPressed: () {
                            setBottomSheetState(() {
                              if (index == 0) {
                                tempDueApt = 'all';
                              } else if (index == 1) {
                                tempDebtStatus = 'all';
                                tempDebtApt = 'all';
                              } else if (index == 3) {
                                tempIncCat = 'all';
                                tempIncApt = 'all';
                              } else if (index == 4) {
                                tempExpCat = 'all';
                                tempExpApt = 'all';
                              }
                            });
                          },
                          child: const Text('Temizle', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        filterContent,
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (index == 0) {
                              _selectedDuePeriodApartment = tempDueApt;
                            } else if (index == 1) {
                              _selectedDebtStatus = tempDebtStatus;
                              _selectedDebtApartment = tempDebtApt;
                            } else if (index == 3) {
                              _selectedIncomeCategory = tempIncCat;
                              _selectedIncomeApartment = tempIncApt;
                            } else if (index == 4) {
                              _selectedExpenseCategory = tempExpCat;
                              _selectedExpenseApartment = tempExpApt;
                            }
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Sayıları göster ($count)',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Finans Yönetimi'),
          centerTitle: true,
          actions: [
            Builder(
              builder: (context) {
                final tabController = DefaultTabController.of(context);
                return AnimatedBuilder(
                  animation: tabController,
                  builder: (context, _) {
                    return BlocBuilder<FinanceCubit, FinanceState>(
                      builder: (context, state) {
                        if (state is! FinanceLoaded) return const SizedBox();
                        final index = tabController.index;
                        if (index == 2) return const SizedBox();

                        bool hasFilter = false;
                        if (index == 0) hasFilter = _selectedDuePeriodApartment != 'all';
                        if (index == 1) hasFilter = _selectedDebtStatus != 'all' || _selectedDebtApartment != 'all';
                        if (index == 3) hasFilter = _selectedIncomeCategory != 'all' || _selectedIncomeApartment != 'all';
                        if (index == 4) hasFilter = _selectedExpenseCategory != 'all' || _selectedExpenseApartment != 'all';

                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: IconButton(
                            onPressed: () => _showFilterBottomSheet(context, state),
                            icon: Icon(
                              Icons.filter_list_rounded,
                              color: hasFilter ? AppColors.primary : AppColors.textSecondary,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: hasFilter ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<FinanceCubit, FinanceState>(
          builder: (context, state) {
            if (state is FinanceLoading || state is FinanceInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FinanceError) {
              return Center(
                child: Text(state.message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
              );
            } else if (state is FinanceLoaded) {
              final filteredDuePeriods = state.duePeriods.where((p) {
                return _selectedDuePeriodApartment == 'all' || p.apartmentName == _selectedDuePeriodApartment;
              }).toList();

              final filteredDebts = state.debts.where((d) {
                final matchesApt = _selectedDebtApartment == 'all' || d.apartmentName == _selectedDebtApartment;
                final matchesStatus = _selectedDebtStatus == 'all' ||
                    (_selectedDebtStatus == 'paid' && d.isPaid) ||
                    (_selectedDebtStatus == 'unpaid' && !d.isPaid && !d.isOverdue) ||
                    (_selectedDebtStatus == 'overdue' && d.isOverdue);
                return matchesApt && matchesStatus;
              }).toList();

              final filteredIncomes = state.incomes.where((i) {
                final matchesApt = _selectedIncomeApartment == 'all' || i.apartmentName == _selectedIncomeApartment;
                final matchesCat = _selectedIncomeCategory == 'all' || i.categoryDisplay == _selectedIncomeCategory;
                return matchesApt && matchesCat;
              }).toList();

              final filteredExpenses = state.expenses.where((e) {
                final matchesApt = _selectedExpenseApartment == 'all' || e.apartmentName == _selectedExpenseApartment;
                final matchesCat = _selectedExpenseCategory == 'all' || e.categoryDisplay == _selectedExpenseCategory;
                return matchesApt && matchesCat;
              }).toList();

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: _buildSummaryCard(state.summary),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        const TabBar(
                          isScrollable: true,
                          indicatorColor: AppColors.primary,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          tabs: [
                            Tab(text: 'Aidat Dönemleri'),
                            Tab(text: 'Borçlar'),
                            Tab(text: 'Ödemeler'),
                            Tab(text: 'Gelirler'),
                            Tab(text: 'Giderler'),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    _buildDuePeriodsTab(context, filteredDuePeriods),
                    _buildDebtsTab(context, filteredDebts),
                    _buildPaymentsTab(context, state.payments),
                    _buildIncomesTab(context, filteredIncomes),
                    _buildExpensesTab(context, filteredExpenses),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/manager/finance/add', extra: context.read<FinanceCubit>());
          if (result != null) {
            if (context.mounted) {
              context.read<FinanceCubit>().fetchManagerFinance();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kayıt başarıyla eklendi!'), backgroundColor: AppColors.success),
              );
            }
          }
        },
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: AppColors.textOnPrimary),
      ),
      ),
    );
  }

  Widget _buildSummaryCard(FinanceSummary? summary) {
    if (summary == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kasa Özeti (Gelir Dağılımı)', style: AppTextStyles.titleMedium.copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          Text('₺${summary.totalPaid.toStringAsFixed(2)}', style: AppTextStyles.headlineLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryStat('Bekleyen Borç', summary.totalUnpaid),
              _buildSummaryStat('Gecikme Faizi', summary.totalLateFee),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
        const SizedBox(height: 4),
        Text('₺${value.toStringAsFixed(2)}', style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
      ],
    );
  }

  Widget _buildDuePeriodsTab(BuildContext context, List<DuePeriod> periods) {
    if (periods.isEmpty) {
      return Center(child: Text('Aidat dönemi bulunmuyor.', style: AppTextStyles.bodyMedium));
    }
    return RefreshIndicator(
      onRefresh: () => context.read<FinanceCubit>().fetchManagerFinance(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: periods.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final p = periods[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => context.pushNamed('managerEditDuePeriod', extra: {'period': p, 'cubit': context.read<FinanceCubit>()}),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.periodDisplay, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(p.apartmentName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₺${p.amount.toStringAsFixed(2)}', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _showDeleteDialog(context, 'due_period', p.id, p.periodDisplay),
                              child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDebtsTab(BuildContext context, List<Debt> debts) {
    if (debts.isEmpty) {
      return Center(child: Text('Alacak bulunmuyor.', style: AppTextStyles.bodyMedium));
    }
    return RefreshIndicator(
      onRefresh: () => context.read<FinanceCubit>().fetchManagerFinance(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: debts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final debt = debts[index];
          final isOverdue = debt.isOverdue;
          return Card(
            shape: isOverdue ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: AppColors.error.withValues(alpha: 0.5), width: 1.5)) : null,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => context.pushNamed('managerEditDebt', extra: {'debt': debt, 'cubit': context.read<FinanceCubit>()}),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: (isOverdue ? AppColors.error : AppColors.warning).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                      child: Icon(Icons.account_balance_wallet_rounded, color: isOverdue ? AppColors.error : AppColors.warning),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(debt.description, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(debt.unitDisplay ?? 'Ortak Alan', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: (isOverdue ? AppColors.error : AppColors.success).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(debt.statusDisplay, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isOverdue ? AppColors.error : AppColors.success)),
                              ),
                              const SizedBox(width: 8),
                              if (isOverdue)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Text('Gecikme: ₺${debt.lateFeeAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error)),
                                ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₺${debt.totalAmount.toStringAsFixed(2)}', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800, color: isOverdue ? AppColors.error : AppColors.textPrimary)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (debt.status != 'paid')
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => BlocProvider.value(
                                      value: context.read<FinanceCubit>(),
                                      child: PaymentDialog(debt: debt),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                                  child: const Text('Öde', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => _showDeleteDialog(context, 'debt', debt.id, debt.description),
                              child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentsTab(BuildContext context, List<Payment> payments) {
    if (payments.isEmpty) {
      return Center(child: Text('Ödeme bulunmuyor.', style: AppTextStyles.bodyMedium));
    }
    return RefreshIndicator(
      onRefresh: () => context.read<FinanceCubit>().fetchManagerFinance(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final p = payments[index];
          final dateStr = DateFormat('dd MMM HH:mm').format(p.paymentDate);
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Düzenleme özelliği yakında eklenecek'))),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.arrow_downward_rounded, color: AppColors.success),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.debtDescription ?? 'Ödeme', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${p.unitDisplay ?? 'Bilinmiyor'} • $dateStr', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('+ ₺${p.amount.toStringAsFixed(2)}', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800, color: AppColors.success)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showDeleteDialog(context, 'payment', p.id, 'Ödeme ${p.id}'),
                          child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIncomesTab(BuildContext context, List<Income> incomes) {
    if (incomes.isEmpty) return Center(child: Text('Gelir kaydı bulunmuyor.', style: AppTextStyles.bodyMedium));
    return RefreshIndicator(
      onRefresh: () => context.read<FinanceCubit>().fetchManagerFinance(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: incomes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final inc = incomes[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => context.pushNamed('managerEditTransaction', extra: {'income': inc, 'cubit': context.read<FinanceCubit>()}),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.trending_up_rounded, color: AppColors.success),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(inc.title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(6)),
                            child: Text(inc.categoryDisplay, style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('+ ₺${inc.amount.toStringAsFixed(2)}', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800, color: AppColors.success)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showDeleteDialog(context, 'income', inc.id, inc.title),
                          child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpensesTab(BuildContext context, List<Expense> expenses) {
    if (expenses.isEmpty) return Center(child: Text('Gider kaydı bulunmuyor.', style: AppTextStyles.bodyMedium));
    return RefreshIndicator(
      onRefresh: () => context.read<FinanceCubit>().fetchManagerFinance(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: expenses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final exp = expenses[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => context.pushNamed('managerEditTransaction', extra: {'expense': exp, 'cubit': context.read<FinanceCubit>()}),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.trending_down_rounded, color: AppColors.error),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exp.title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(6)),
                            child: Text(exp.categoryDisplay, style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('- ₺${exp.amount.toStringAsFixed(2)}', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showDeleteDialog(context, 'expense', exp.id, exp.title),
                          child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
