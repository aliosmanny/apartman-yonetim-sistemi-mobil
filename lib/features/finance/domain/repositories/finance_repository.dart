import '../../data/dto/finance_dto.dart';

import '../models/payment.dart';

import '../models/debt.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/due_period.dart';
import '../models/finance_summary.dart';

abstract class FinanceRepository {
  Future<List<Debt>> getDebts();
  Future<List<Expense>> getExpenses();
  Future<void> payDebtManual(String debtId, String receiptNote);
  Future<FinanceSummary> getSummary();
  Future<List<Income>> getIncomes();
  Future<List<DuePeriod>> getDuePeriods();
  Future<List<Payment>> getPayments();
  Future<PaymentInitiateResponseDto> initiatePayment(String debtId, PaymentInitiateRequestDto request);
    Future<void> deleteItem(String type, String id);

  Future<void> createDuePeriod(Map<String, dynamic> data);
  Future<void> updateDuePeriod(String id, Map<String, dynamic> data);

  Future<void> createDebt(Map<String, dynamic> data);
  Future<void> updateDebt(String id, Map<String, dynamic> data);

  Future<void> createIncome(Map<String, dynamic> data);
  Future<void> updateIncome(String id, Map<String, dynamic> data);

  Future<void> createExpense(Map<String, dynamic> data);
  Future<void> updateExpense(String id, Map<String, dynamic> data);
}
