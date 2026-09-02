import re

def fix():
    path = 'lib/features/dashboard/presentation/pages/manager_finance_page.dart'
    with open(path, 'r') as f:
        content = f.read()

    # Find where tabs start
    # We will replace from `Widget _buildDuePeriodsTab` all the way to `class _SliverAppBarDelegate`
    start_idx = content.find("  Widget _buildDuePeriodsTab")
    end_idx = content.find("class _SliverAppBarDelegate")
    
    if start_idx == -1 or end_idx == -1:
        print("Could not find bounds")
        return
        
    new_tabs = """  Widget _buildDuePeriodsTab(BuildContext context, List<DuePeriod> periods) {
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
                                  child: Text('Gecikme: ₺${debt.delayPenalty.toStringAsFixed(2)}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error)),
                                ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₺${debt.amount.toStringAsFixed(2)}', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800, color: isOverdue ? AppColors.error : AppColors.textPrimary)),
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

"""
    
    content = content[:start_idx] + new_tabs + content[end_idx:]
    with open(path, 'w') as f:
        f.write(content)

fix()
