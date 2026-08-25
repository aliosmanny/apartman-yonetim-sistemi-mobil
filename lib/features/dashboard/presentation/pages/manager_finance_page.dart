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
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: periods.length,
        itemBuilder: (context, index) {
          final p = periods[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(p.periodDisplay, style: AppTextStyles.titleMedium),
              subtitle: Text(p.apartmentName, style: AppTextStyles.bodySmall),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('₺${p.amount.toStringAsFixed(2)}', style: AppTextStyles.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => _showDeleteDialog(context, 'due_period', p.id, p.periodDisplay),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                    onPressed: () => context.pushNamed('managerEditDuePeriod', extra: {'period': p, 'cubit': context.read<FinanceCubit>()}),
                  ),
                ],
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
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: debts.length,
        itemBuilder: (context, index) {
          final debt = debts[index];
          final isOverdue = debt.isOverdue;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isOverdue ? AppColors.error.withValues(alpha: 0.5) : Colors.transparent),
            ),
            child: ListTile(
              title: Text(debt.description, style: AppTextStyles.titleMedium),
              subtitle: Text(debt.unitDisplay ?? 'Ortak Alan', style: AppTextStyles.bodySmall),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('₺${debt.totalAmount.toStringAsFixed(2)}', style: AppTextStyles.titleMedium),
                      if (debt.isPaid)
                        Text(
                          '✓ Ödendi',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  if (!debt.isPaid)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          minimumSize: const Size(0, 32),
                        ),
                        icon: const Icon(Icons.payment, size: 14),
                        label: const Text('Ödeme Yap', style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => BlocProvider.value(
                              value: context.read<FinanceCubit>(),
                              child: PaymentDialog(debt: debt),
                            ),
                          );
                        },
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => context.pushNamed('managerEditDebt', extra: {'debt': debt, 'cubit': context.read<FinanceCubit>()}),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showDeleteDialog(context, 'debt', debt.id, debt.description),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentsTab(BuildContext context, List<Payment> payments) {
    if (payments.isEmpty) {
      return Center(child: Text('Ödeme kaydı bulunmuyor.', style: AppTextStyles.bodyMedium));
    }
    return RefreshIndicator(
      onRefresh: () => context.read<FinanceCubit>().fetchManagerFinance(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final p = payments[index];
          final dateStr = DateFormat('dd MMM yyyy HH:mm').format(p.paymentDate);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(p.debtDescription ?? 'Ödeme', style: AppTextStyles.titleMedium),
              subtitle: Text('${p.unitDisplay ?? ''}\n$dateStr', style: AppTextStyles.bodySmall),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('₺${p.amount.toStringAsFixed(2)}', style: AppTextStyles.titleMedium.copyWith(color: AppColors.success)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => _showDeleteDialog(context, 'payment', p.id, 'Ödeme ${p.id}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Düzenleme özelliği yakında eklenecek'))),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildIncomesTab(BuildContext context, List<Income> incomes) {
    if (incomes.isEmpty) {
      return Center(child: Text('Gelir kaydı bulunmuyor.', style: AppTextStyles.bodyMedium));
    }
    return RefreshIndicator(
      onRefresh: () => context.read<FinanceCubit>().fetchManagerFinance(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: incomes.length,
        itemBuilder: (context, index) {
          final inc = incomes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(inc.title, style: AppTextStyles.titleMedium),
              subtitle: Text(inc.categoryDisplay, style: AppTextStyles.bodySmall),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('+₺${inc.amount.toStringAsFixed(2)}', style: AppTextStyles.titleMedium.copyWith(color: AppColors.success)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => _showDeleteDialog(context, 'income', inc.id, inc.title),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                    onPressed: () => context.pushNamed('managerEditTransaction', extra: {'income': inc, 'cubit': context.read<FinanceCubit>()}),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpensesTab(BuildContext context, List<Expense> expenses) {
    if (expenses.isEmpty) {
      return Center(child: Text('Gider kaydı bulunmuyor.', style: AppTextStyles.bodyMedium));
    }
    return RefreshIndicator(
      onRefresh: () => context.read<FinanceCubit>().fetchManagerFinance(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final exp = expenses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(exp.title, style: AppTextStyles.titleMedium),
              subtitle: Text(exp.categoryDisplay, style: AppTextStyles.bodySmall),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('-₺${exp.amount.toStringAsFixed(2)}', style: AppTextStyles.titleMedium.copyWith(color: AppColors.error)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => _showDeleteDialog(context, 'expense', exp.id, exp.title),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                    onPressed: () => context.pushNamed('managerEditTransaction', extra: {'expense': exp, 'cubit': context.read<FinanceCubit>()}),
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
