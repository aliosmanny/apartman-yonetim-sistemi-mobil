import '../../domain/models/payment.dart';

import '../../domain/models/debt.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/income.dart';
import '../../domain/models/due_period.dart';
import '../../domain/models/finance_summary.dart';

abstract class FinanceState {}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceLoaded extends FinanceState {
  final List<Debt> debts;
  final List<Expense> expenses;
  final List<Income> incomes;
  final List<DuePeriod> duePeriods;
  final List<Payment> payments;
  final FinanceSummary? summary;

  FinanceLoaded({
    required this.debts,
    this.expenses = const [],
    this.incomes = const [],
    this.duePeriods = const [],
    this.payments = const [],
    this.summary,
  });
}

class FinanceError extends FinanceState {
  final String message;

  FinanceError({required this.message});
}
