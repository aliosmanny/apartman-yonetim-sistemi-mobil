import '../../data/dto/finance_dto.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/debt.dart';
import '../../domain/models/payment.dart';
import '../../domain/models/finance_summary.dart';
import '../../domain/models/due_period.dart';
import '../../domain/models/income.dart';
import '../../domain/models/expense.dart';
import '../../domain/repositories/finance_repository.dart';
import 'finance_state.dart';

class FinanceCubit extends Cubit<FinanceState> {
  final FinanceRepository _repository;
  static FinanceLoaded? _cachedState;

  static void clearCache() {
    _cachedState = null;
  }

  FinanceCubit(this._repository) : super(_cachedState ?? FinanceInitial());

  Future<void> fetchDebts() async {
    if (state is! FinanceLoaded) {
      emit(FinanceLoading());
    }
    try {
      final results = await Future.wait([
        _repository.getDebts().catchError((_) => <Debt>[]),
        _repository.getPayments().catchError((_) => <Payment>[]),
      ]);
      final debts = results[0] as List<Debt>;
      final payments = results[1] as List<Payment>;
      final loadedState = FinanceLoaded(debts: debts, payments: payments);
      _cachedState = loadedState;
      emit(loadedState);
    } catch (e) {
      emit(FinanceError(message: 'Borçlar yüklenirken bir hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> fetchManagerFinance() async {
    if (state is! FinanceLoaded) {
      emit(FinanceLoading());
    }
    try {
      final results = await Future.wait([
        _repository.getSummary().catchError((_) => null),
        _repository.getDuePeriods().catchError((_) => <DuePeriod>[]),
        _repository.getDebts().catchError((_) => <Debt>[]),
        _repository.getIncomes().catchError((_) => <Income>[]),
        _repository.getExpenses().catchError((_) => <Expense>[]),
        _repository.getPayments().catchError((_) => <Payment>[]),
      ]);

      final summary = results[0] as FinanceSummary?;
      final duePeriods = results[1] as List<DuePeriod>;
      final debts = results[2] as List<Debt>;
      final incomes = results[3] as List<Income>;
      final expenses = results[4] as List<Expense>;
      var payments = results[5] as List<Payment>;

      if (payments.isEmpty && debts.isNotEmpty) {
        payments = debts.expand((d) => d.payments).toList();
      }

      final loadedState = FinanceLoaded(
        summary: summary,
        duePeriods: duePeriods,
        debts: debts,
        payments: payments,
        incomes: incomes,
        expenses: expenses,
      );
      _cachedState = loadedState;
      emit(loadedState);
    } catch (e) {
      emit(FinanceError(message: 'Finans verileri yüklenirken bir hata oluştu: ${e.toString()}'));
    }
  }

  Future<PaymentInitiateResponseDto> initiatePayment(String debtId, PaymentInitiateRequestDto request) async {
    return await _repository.initiatePayment(debtId, request);
  }

  Future<void> payDebtManual(String debtId, String receiptNote) async {
    try {
      await _repository.payDebtManual(debtId, receiptNote);
      await fetchDebts();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteItem(String type, String id) async {
    try {
      await _repository.deleteItem(type, id);
      await fetchManagerFinance(); // Refresh after delete
    } catch (e) {
      throw Exception('Silme işlemi başarısız: ${e.toString()}');
    }
  }

  Future<void> createDuePeriod(Map<String, dynamic> data) async {
    await _repository.createDuePeriod(data);
    await fetchManagerFinance();
  }

  Future<void> updateDuePeriod(String id, Map<String, dynamic> data) async {
    await _repository.updateDuePeriod(id, data);
    await fetchManagerFinance();
  }

  Future<void> createDebt(Map<String, dynamic> data) async {
    await _repository.createDebt(data);
    await fetchManagerFinance();
  }

  Future<void> updateDebt(String id, Map<String, dynamic> data) async {
    await _repository.updateDebt(id, data);
    await fetchManagerFinance();
  }

  Future<void> createIncome(Map<String, dynamic> data) async {
    await _repository.createIncome(data);
    await fetchManagerFinance();
  }

  Future<void> updateIncome(String id, Map<String, dynamic> data) async {
    await _repository.updateIncome(id, data);
    await fetchManagerFinance();
  }

  Future<void> createExpense(Map<String, dynamic> data) async {
    await _repository.createExpense(data);
    await fetchManagerFinance();
  }

  Future<void> updateExpense(String id, Map<String, dynamic> data) async {
    await _repository.updateExpense(id, data);
    await fetchManagerFinance();
  }
}
