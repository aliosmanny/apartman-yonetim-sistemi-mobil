import 'payment.dart';

class Debt {
  final String id;
  final String? unitDisplay;
  final String? apartmentName;
  final String description;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final double lateFeeAmount;
  final double lateFeeRate;
  final String status;
  final String statusDisplay;
  final String category;
  final String categoryDisplay;
  final DateTime dueDate;
  final DateTime createdAt;
  final List<Payment> payments;

  const Debt({
    required this.id,
    this.unitDisplay,
    this.apartmentName,
    required this.description,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.lateFeeAmount,
    required this.lateFeeRate,
    required this.status,
    required this.statusDisplay,
    required this.category,
    required this.categoryDisplay,
    required this.dueDate,
    required this.createdAt,
    this.payments = const [],
  });

  bool get isOverdue => (status != 'paid' && status != 'cancelled') && dueDate.isBefore(DateTime.now());
  bool get isPaid => status == 'paid';
}
