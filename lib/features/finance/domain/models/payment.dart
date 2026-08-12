class Payment {
  final String id;
  final String debtId;
  final double amount;
  final DateTime paymentDate;
  final String status; // 'pending', 'completed', 'failed'
  final String? receiptUrl;

  const Payment({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.paymentDate,
    required this.status,
    this.receiptUrl,
  });
}
