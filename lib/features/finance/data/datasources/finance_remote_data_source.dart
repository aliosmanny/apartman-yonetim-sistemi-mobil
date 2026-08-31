import 'package:dio/dio.dart';
import '../dto/finance_dto.dart';

abstract class FinanceRemoteDataSource {
  Future<List<DebtDto>> getDebts();
  Future<List<ExpenseDto>> getExpenses();
  Future<void> payDebtManual(String debtId, String receiptNote);
  Future<FinanceSummaryDto> getSummary();
  Future<List<IncomeDto>> getIncomes();
  Future<List<DuePeriodDto>> getDuePeriods();
  Future<List<PaymentDto>> getPayments();
  Future<PaymentInitiateResponseDto> initiatePayment(String debtId, PaymentInitiateRequestDto request);
    Future<void> deleteItem(String type, String id);
  Future<void> createPayment(Map<String, dynamic> data);


  Future<void> createDuePeriod(Map<String, dynamic> data);
  Future<void> updateDuePeriod(String id, Map<String, dynamic> data);

  Future<void> createDebt(Map<String, dynamic> data);
  Future<void> updateDebt(String id, Map<String, dynamic> data);

  Future<void> createIncome(Map<String, dynamic> data);
  Future<void> updateIncome(String id, Map<String, dynamic> data);

  Future<void> createExpense(Map<String, dynamic> data);
  Future<void> updateExpense(String id, Map<String, dynamic> data);
}

class FinanceRemoteDataSourceImpl implements FinanceRemoteDataSource {
  final Dio _dio;

  FinanceRemoteDataSourceImpl(this._dio);

  Future<List<T>> _fetchList<T>(String path, T Function(Map<String, dynamic>) fromJson) async {
    final response = await _dio.get(path);
    final data = response.data;
    List<dynamic> listData = [];
    if (data is Map<String, dynamic> && data.containsKey('results')) {
      listData = data['results'] as List<dynamic>;
    } else if (data is List) {
      listData = data;
    }
    return listData.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<DebtDto>> getDebts() => _fetchList('/debts/', DebtDto.fromJson);

  @override
  Future<List<ExpenseDto>> getExpenses() => _fetchList('/expenses/', ExpenseDto.fromJson);

  @override
  Future<List<IncomeDto>> getIncomes() => _fetchList('/incomes/', IncomeDto.fromJson);

  @override
  Future<List<DuePeriodDto>> getDuePeriods() => _fetchList('/due-periods/', DuePeriodDto.fromJson);

  @override
  Future<List<PaymentDto>> getPayments() => _fetchList('/payments/', PaymentDto.fromJson);

  @override
  Future<PaymentInitiateResponseDto> initiatePayment(String debtId, PaymentInitiateRequestDto request) async {
    final response = await _dio.post('/debts/$debtId/pay/', data: request.toJson());
    return PaymentInitiateResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<FinanceSummaryDto> getSummary() async {
    final response = await _dio.get('/debts/summary/');
    return FinanceSummaryDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> payDebtManual(String debtId, String receiptNote) async {
    await _dio.post(
      '/debts/$debtId/pay/manual/',
      data: {'note': receiptNote},
    );
  }

  @override
  Future<void> deleteItem(String type, String id) async {
    String endpoint = '';
    switch (type) {
      case 'debt': endpoint = '/debts/$id/'; break;
      case 'expense': endpoint = '/expenses/$id/'; break;
      case 'income': endpoint = '/incomes/$id/'; break;
      case 'due_period': endpoint = '/due-periods/$id/'; break;
      case 'payment': endpoint = '/payments/$id/'; break;
    }
    await _dio.delete(endpoint);
  }

  @override
  Future<void> createPayment(Map<String, dynamic> data) async {
    final debtId = data['debt'];
    await _dio.post('/debts/$debtId/pay/manual/', data: data);
  }

  @override
  Future<void> createDuePeriod(Map<String, dynamic> data) async {
    await _dio.post('/due-periods/', data: data);
  }

  @override
  Future<void> updateDuePeriod(String id, Map<String, dynamic> data) async {
    await _dio.patch('/due-periods/$id/', data: data);
  }

  @override
  Future<void> createDebt(Map<String, dynamic> data) async {
    await _dio.post('/debts/', data: data);
  }

  @override
  Future<void> updateDebt(String id, Map<String, dynamic> data) async {
    await _dio.patch('/debts/$id/', data: data);
  }

  @override
  Future<void> createIncome(Map<String, dynamic> data) async {
    await _dio.post('/incomes/', data: data);
  }

  @override
  Future<void> updateIncome(String id, Map<String, dynamic> data) async {
    await _dio.patch('/incomes/$id/', data: data);
  }

  @override
  Future<void> createExpense(Map<String, dynamic> data) async {
    await _dio.post('/expenses/', data: data);
  }

  @override
  Future<void> updateExpense(String id, Map<String, dynamic> data) async {
    await _dio.patch('/expenses/$id/', data: data);
  }
}
