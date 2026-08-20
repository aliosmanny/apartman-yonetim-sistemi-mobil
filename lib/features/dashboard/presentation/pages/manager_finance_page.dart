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

class _ManagerFinanceViewState extends State<_ManagerFinanceView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Finans Yönetimi'),
        centerTitle: true,
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
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: _buildSummaryCard(state.summary),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicatorColor: AppColors.primary,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        tabs: const [
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
                controller: _tabController,
                children: [
                  _buildDuePeriodsTab(context, state.duePeriods),
                  _buildDebtsTab(context, state.debts),
                  _buildPaymentsTab(context, state.payments),
                  _buildIncomesTab(context, state.incomes),
                  _buildExpensesTab(context, state.expenses),
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
