import '../../data/dto/finance_dto.dart';

import '../../domain/models/payment.dart';

import '../../domain/models/debt.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/income.dart';
import '../../domain/models/due_period.dart';
import '../../domain/models/finance_summary.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_remote_data_source.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDataSource _remoteDataSource;

  FinanceRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Debt>> getDebts() async {
    final dtos = await _remoteDataSource.getDebts();
    return dtos.map((dto) => dto.toModel()).toList();
  }

  @override
  Future<List<Expense>> getExpenses() async {
    final dtos = await _remoteDataSource.getExpenses();
    return dtos.map((dto) => dto.toModel()).toList();
  }

  @override
  Future<List<Income>> getIncomes() async {
    final dtos = await _remoteDataSource.getIncomes();
    return dtos.map((dto) => dto.toModel()).toList();
  }

  @override
  Future<List<DuePeriod>> getDuePeriods() async {
    final dtos = await _remoteDataSource.getDuePeriods();
    return dtos.map((dto) => dto.toModel()).toList();
  }

  @override
  Future<List<Payment>> getPayments() async {
    final dtos = await _remoteDataSource.getPayments();
    return dtos.map((dto) => dto.toModel()).toList();
  }

  @override
  Future<PaymentInitiateResponseDto> initiatePayment(String debtId, PaymentInitiateRequestDto request) async {
    return await _remoteDataSource.initiatePayment(debtId, request);
  }

  @override
  Future<FinanceSummary> getSummary() async {
    final dto = await _remoteDataSource.getSummary();
    return dto.toModel();
  }

  @override
  Future<void> payDebtManual(String debtId, String receiptNote) async {
    await _remoteDataSource.payDebtManual(debtId, receiptNote);
  }

  @override
  Future<void> deleteItem(String type, String id) async {
    await _remoteDataSource.deleteItem(type, id);
  }

  @override
  @override 
  Future<void> createPayment(Map<String, dynamic> data) async { 
    await _remoteDataSource.createPayment(data); 
  }

  Future<void> createDuePeriod(Map<String, dynamic> data) async {
    await _remoteDataSource.createDuePeriod(data);
  }

  @override
  Future<void> updateDuePeriod(String id, Map<String, dynamic> data) async {
    await _remoteDataSource.updateDuePeriod(id, data);
  }

  @override
  Future<void> createDebt(Map<String, dynamic> data) async {
    await _remoteDataSource.createDebt(data);
  }

  @override
  Future<void> updateDebt(String id, Map<String, dynamic> data) async {
    await _remoteDataSource.updateDebt(id, data);
  }

  @override
  Future<void> createIncome(Map<String, dynamic> data) async {
    await _remoteDataSource.createIncome(data);
  }

  @override
  Future<void> updateIncome(String id, Map<String, dynamic> data) async {
    await _remoteDataSource.updateIncome(id, data);
  }

  @override
  Future<void> createExpense(Map<String, dynamic> data) async {
    await _remoteDataSource.createExpense(data);
  }

  @override
  Future<void> updateExpense(String id, Map<String, dynamic> data) async {
    await _remoteDataSource.updateExpense(id, data);
  }
}