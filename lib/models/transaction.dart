// lib/models/transaction.dart
class Transaction {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String description;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
  });
}
