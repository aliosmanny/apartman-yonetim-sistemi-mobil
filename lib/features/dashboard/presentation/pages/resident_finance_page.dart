import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../finance/presentation/controllers/finance_cubit.dart';
import '../../../finance/presentation/controllers/finance_state.dart';
import '../../../finance/domain/models/debt.dart';
import '../../../finance/domain/models/payment.dart';
import '../../../finance/presentation/pages/debt_list_page.dart';
import 'package:intl/intl.dart';

class ResidentFinancePage extends StatelessWidget {
  const ResidentFinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FinanceCubit>()..fetchDebts(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Finans & Aidat Yönetimi'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Borçlar'),
                Tab(text: 'Ödemeler'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              DebtListPage(showAppBar: false), // This already exists
              _ResidentPaymentList(),
            ],
          ),
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
