class Payment {
  final String id;
  final String debtId;
  final String? debtDescription;
  final String? unitDisplay;
  final double amount;
  final DateTime paymentDate;
  final String status;
  final String statusDisplay;

  const Payment({
    required this.id,
    required this.debtId,
    this.debtDescription,
    this.unitDisplay,
    required this.amount,
    required this.paymentDate,
    required this.status,
    required this.statusDisplay,
  });
}
