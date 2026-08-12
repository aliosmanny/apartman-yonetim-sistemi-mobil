import '../../domain/models/debt.dart';

abstract class FinanceState {}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceLoaded extends FinanceState {
  final List<Debt> debts;
  FinanceLoaded({required this.debts});
}

class FinanceError extends FinanceState {
  final String message;
  FinanceError({required this.message});
}
