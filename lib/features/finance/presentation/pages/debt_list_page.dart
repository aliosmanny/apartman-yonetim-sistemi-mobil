import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../domain/models/debt.dart';
import '../widgets/payment_dialog.dart';
import '../controllers/finance_cubit.dart';
import '../controllers/finance_state.dart';

class DebtListPage extends StatelessWidget {
  final bool showAppBar;
  const DebtListPage({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FinanceCubit>()..fetchDebts(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: showAppBar ? AppBar(
          title: const Text('Borçlarım ve Ödemeler'),
          centerTitle: false,
        ) : null,
        body: BlocBuilder<FinanceCubit, FinanceState>(
          builder: (context, state) {
            if (state is FinanceLoading || state is FinanceInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is FinanceError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(state.message, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<FinanceCubit>().fetchDebts(),
                      child: const Text('Tekrar Dene'),
                    )
                  ],
                ),
              );
            }

            if (state is FinanceLoaded) {
              final debts = state.debts;
              if (debts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 64, color: AppColors.debtPaid),
                      const SizedBox(height: 16),
                      Text('Harika! Hiç borcunuz yok.',
                          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary)),
                    ],
                  ),
                );
              }

              // Ödenmemişleri en üste, tarihi geçmişleri en başa al
              debts.sort((a, b) {
                if (a.isPaid != b.isPaid) return a.isPaid ? 1 : -1;
                return a.dueDate.compareTo(b.dueDate);
              });

              return RefreshIndicator(
                onRefresh: () => context.read<FinanceCubit>().fetchDebts(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: debts.length,
                  itemBuilder: (context, index) {
                    final debt = debts[index];
                    return _DebtCard(debt: debt);
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  final Debt debt;

  const _DebtCard({required this.debt});

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = debt.isOverdue;
    final bool isPaid = debt.isPaid;

    Color statusColor = AppColors.primary;
    String statusText = 'Ödenecek';
    IconData statusIcon = Icons.schedule_rounded;

    if (isPaid) {
      statusColor = AppColors.debtPaid;
      statusText = 'Ödendi';
      statusIcon = Icons.check_circle_rounded;
    } else if (isOverdue) {
      statusColor = AppColors.debtOverdue;
      statusText = 'Gecikmiş';
      statusIcon = Icons.warning_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOverdue ? AppColors.debtOverdue.withOpacity(0.3) : AppColors.border,
          width: isOverdue ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(debt.description, style: AppTextStyles.titleMedium),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusText,
                              style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Son Ödeme: ${_formatDate(debt.dueDate)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isOverdue ? AppColors.debtOverdue : AppColors.textSecondary,
                          fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '₺${debt.totalAmount.toStringAsFixed(2)}',
                style: AppTextStyles.amountMedium,
              ),
            ),
            if (!isPaid) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => BlocProvider.value(
                        value: context.read<FinanceCubit>(),
                        child: PaymentDialog(debt: debt),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOverdue ? AppColors.debtOverdue : AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Hemen Öde'),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.debtPaid.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Bu borç ödenmiştir.',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.debtPaid, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}