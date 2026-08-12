class Debt {
  final String id;
  final String apartmentId;
  final String unitId;
  final double amount;
  final double remainingAmount;
  final String description;
  final DateTime dueDate;
  final bool isPaid;
  final DateTime createdAt;

  const Debt({
    required this.id,
    required this.apartmentId,
    required this.unitId,
    required this.amount,
    required this.remainingAmount,
    required this.description,
    required this.dueDate,
    required this.isPaid,
    required this.createdAt,
  });

  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());
}
