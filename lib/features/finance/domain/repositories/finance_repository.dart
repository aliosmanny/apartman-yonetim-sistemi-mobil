import '../models/debt.dart';
import '../models/payment.dart';

abstract class FinanceRepository {
  Future<List<Debt>> getMyDebts();
  Future<Payment> payDebt(String debtId, String cardToken);
}
