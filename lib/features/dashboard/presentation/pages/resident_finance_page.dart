import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../finance/domain/models/debt.dart';
import '../../../finance/presentation/controllers/finance_cubit.dart';
import '../../../finance/presentation/controllers/finance_state.dart';
import '../../../finance/presentation/pages/debt_list_page.dart';

class ResidentFinancePage extends StatefulWidget {
  const ResidentFinancePage({super.key});

  @override
  State<ResidentFinancePage> createState() => _ResidentFinancePageState();
}

class _ResidentFinancePageState extends State<ResidentFinancePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final FinanceCubit _cubit;

  String _selectedDebtStatus = 'all';
  String _selectedDebtApartment = 'all';

  @override
  void initState() {
    super.initState();
    _cubit = sl<FinanceCubit>()..fetchDebts();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cubit.close();
    super.dispose();
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String tempDebtStatus = _selectedDebtStatus;
        String tempDebtApt = _selectedDebtApartment;

        final statuses = const [
          {'value': 'all', 'label': 'Tümü'},
          {'value': 'unpaid', 'label': 'Ödenmedi'},
          {'value': 'paid', 'label': 'Ödendi'},
          {'value': 'overdue', 'label': 'Gecikmiş'},
        ];

        final apartments = ['all', ...state.debts.map((d) => d.apartmentName).whereType<String>().toSet()];

        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            final count = state.debts.where((d) {
              final matchesApt = tempDebtApt == 'all' || d.apartmentName == tempDebtApt;
              final matchesStatus = tempDebtStatus == 'all' ||
                  (tempDebtStatus == 'paid' && d.isPaid) ||
                  (tempDebtStatus == 'unpaid' && !d.isPaid && !d.isOverdue) ||
                  (tempDebtStatus == 'overdue' && d.isOverdue);
              return matchesApt && matchesStatus;
            }).length;

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
                              tempDebtStatus = 'all';
                              tempDebtApt = 'all';
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
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedDebtStatus = tempDebtStatus;
                            _selectedDebtApartment = tempDebtApt;
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
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Finans & Aidat Yönetimi'),
          actions: [
            BlocBuilder<FinanceCubit, FinanceState>(
              builder: (context, state) {
                if (state is! FinanceLoaded) return const SizedBox();
                final index = _tabController.index;
                if (index == 1) return const SizedBox(); // Hide filter icon on Payments tab

                final hasFilter = _selectedDebtStatus != 'all' || _selectedDebtApartment != 'all';
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
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Borçlar'),
              Tab(text: 'Ödemeler'),
            ],
          ),
        ),
        body: BlocBuilder<FinanceCubit, FinanceState>(
          builder: (context, state) {
            if (state is FinanceLoading || state is FinanceInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FinanceError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            } else if (state is FinanceLoaded) {
              final filteredDebts = state.debts.where((d) {
                final matchesApt = _selectedDebtApartment == 'all' || d.apartmentName == _selectedDebtApartment;
                final matchesStatus = _selectedDebtStatus == 'all' ||
                    (_selectedDebtStatus == 'paid' && d.isPaid) ||
                    (_selectedDebtStatus == 'unpaid' && !d.isPaid && !d.isOverdue) ||
                    (_selectedDebtStatus == 'overdue' && d.isOverdue);
                return matchesApt && matchesStatus;
              }).toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  DebtListPage(showAppBar: false, filteredDebts: filteredDebts),
                  const _ResidentPaymentList(),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ResidentPaymentList extends StatelessWidget {
  const _ResidentPaymentList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceCubit, FinanceState>(
      builder: (context, state) {
        if (state is FinanceLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FinanceError) {
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
        } else if (state is FinanceLoaded) {
          final payments = state.payments;
          if (payments.isEmpty) {
            return const Center(child: Text('Ödeme kaydı bulunamadı.'));
          }

          final formatCurrency = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final p = payments[index];
              final dateStr = DateFormat('dd MMM yyyy HH:mm').format(p.paymentDate);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(p.debtDescription ?? 'Ödeme', style: AppTextStyles.titleMedium),
                  subtitle: Text(dateStr, style: AppTextStyles.bodySmall),
                  trailing: Text(
                    formatCurrency.format(p.amount),
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.success),
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
