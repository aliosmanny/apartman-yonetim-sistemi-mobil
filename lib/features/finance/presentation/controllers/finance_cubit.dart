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

  FinanceCubit(this._repository) : super(FinanceInitial());

  Future<void> fetchDebts() async {
    emit(FinanceLoading());
    try {
      List<Debt> debts = [];
      try { debts = await _repository.getDebts(); } catch (_) {}
      
      List<Payment> payments = [];
      try { payments = await _repository.getPayments(); } catch (_) {}
      
      emit(FinanceLoaded(debts: debts, payments: payments));
    } catch (e) {
      emit(FinanceError(message: 'Borçlar yüklenirken bir hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> fetchManagerFinance() async {
    emit(FinanceLoading());
    try {
      FinanceSummary? summary;
      try { summary = await _repository.getSummary(); } catch (_) {}
      
      List<DuePeriod> duePeriods = [];
      try { duePeriods = await _repository.getDuePeriods(); } catch (_) {}
      
      List<Debt> debts = [];
      try { debts = await _repository.getDebts(); } catch (_) {}
      
      List<Income> incomes = [];
      try { incomes = await _repository.getIncomes(); } catch (_) {}
      
      List<Expense> expenses = [];
      try { expenses = await _repository.getExpenses(); } catch (_) {}
      
      List<Payment> payments = [];
      try {
        payments = await _repository.getPayments();
      } catch (_) {
        payments = debts.expand((d) => d.payments).toList();
      }

      emit(FinanceLoaded(
        summary: summary,
        duePeriods: duePeriods,
        debts: debts,
        payments: payments,
        incomes: incomes,
        expenses: expenses,
      ));
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
