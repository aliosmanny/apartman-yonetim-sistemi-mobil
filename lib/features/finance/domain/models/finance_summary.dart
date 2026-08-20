class FinanceSummary {
  final double totalDebts;
  final double totalPaid;
  final double totalUnpaid;
  final double totalOverdue;
  final double totalLateFee;

  const FinanceSummary({
    required this.totalDebts,
    required this.totalPaid,
    required this.totalUnpaid,
    required this.totalOverdue,
    required this.totalLateFee,
  });
}
