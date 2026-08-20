class DuePeriod {
  final String id;
  final String apartmentName;
  final String period;
  final double amount;
  final DateTime dueDate;
  final double? lateFeeRate;
  final String? description;

  const DuePeriod({
    required this.id,
    required this.apartmentName,
    required this.period,
    required this.amount,
    required this.dueDate,
    this.lateFeeRate,
    this.description,
  });

  String get periodDisplay => period;
}
