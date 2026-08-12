import 'package:uuid/uuid.dart';
import '../../domain/models/debt.dart';
import '../../domain/models/payment.dart';
import '../../../../core/network/api_exception.dart';

class FinanceMockDataSource {
  final _uuid = const Uuid();

  // Sahte veriler (Mock)
  late List<Debt> _debts;

  FinanceMockDataSource() {
    _debts = [
      Debt(
        id: _uuid.v4(),
        apartmentId: 'apt-1',
        unitId: 'unit-5',
        amount: 850.0,
        remainingAmount: 850.0,
        description: 'Ağustos 2026 Aidat Ödemesi',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        isPaid: false,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Debt(
        id: _uuid.v4(),
        apartmentId: 'apt-1',
        unitId: 'unit-5',
        amount: 300.0,
        remainingAmount: 300.0,
        description: 'Ortak Alan Elektrik Gideri (Ek)',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        isPaid: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Debt(
        id: _uuid.v4(),
        apartmentId: 'apt-1',
        unitId: 'unit-5',
        amount: 850.0,
        remainingAmount: 0.0,
        description: 'Temmuz 2026 Aidat Ödemesi',
        dueDate: DateTime.now().subtract(const Duration(days: 25)),
        isPaid: true,
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
      ),
    ];
  }

  Future<List<Debt>> getMyDebts() async {
    await Future.delayed(const Duration(seconds: 1));
    return _debts;
  }

  Future<Payment> payDebt(String debtId, String cardToken) async {
    await Future.delayed(const Duration(seconds: 2));

    final debtIndex = _debts.indexWhere((d) => d.id == debtId);
    if (debtIndex == -1) {
      throw const ApiException(message: 'Borç bulunamadı.', statusCode: 404);
    }

    final debt = _debts[debtIndex];
    if (debt.isPaid) {
      throw const ApiException(message: 'Bu borç zaten ödenmiş.', statusCode: 400);
    }

    // Borcu ödendi olarak işaretle
    _debts[debtIndex] = Debt(
      id: debt.id,
      apartmentId: debt.apartmentId,
      unitId: debt.unitId,
      amount: debt.amount,
      remainingAmount: 0,
      description: debt.description,
      dueDate: debt.dueDate,
      isPaid: true,
      createdAt: debt.createdAt,
    );

    return Payment(
      id: _uuid.v4(),
      debtId: debtId,
      amount: debt.amount,
      paymentDate: DateTime.now(),
      status: 'completed',
    );
  }
}
