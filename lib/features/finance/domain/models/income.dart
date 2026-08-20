class Income {
  final String id;
  final String? apartmentName;
  final String title;
  final double amount;
  final String category;
  final String categoryDisplay;
  final DateTime date;
  final String description;

  const Income({
    required this.id,
    this.apartmentName,
    required this.title,
    required this.amount,
    required this.category,
    required this.categoryDisplay,
    required this.date,
    required this.description,
  });
}
