import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/finance_repository.dart';
import 'finance_state.dart';

class FinanceCubit extends Cubit<FinanceState> {
  final FinanceRepository _repository;

  FinanceCubit(this._repository) : super(FinanceInitial());

  Future<void> fetchDebts() async {
    emit(FinanceLoading());
    try {
      final debts = await _repository.getMyDebts();
      emit(FinanceLoaded(debts: debts));
    } catch (e) {
      emit(FinanceError(message: 'Borçlar yüklenirken bir hata oluştu: ${e.toString()}'));
    }
  }

  // Ödeme işlemi daha sonra eklenecek
}
