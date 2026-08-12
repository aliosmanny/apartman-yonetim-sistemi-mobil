import '../../../../core/network/api_exception.dart';
import '../../domain/models/debt.dart';
import '../../domain/models/payment.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_mock_data_source.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceMockDataSource mockDataSource;

  FinanceRepositoryImpl({required this.mockDataSource});

  @override
  Future<List<Debt>> getMyDebts() async {
    return await mockDataSource.getMyDebts();
  }

  @override
  Future<Payment> payDebt(String debtId, String cardToken) async {
    return await mockDataSource.payDebt(debtId, cardToken);
  }
}
