// lib/widgets/transaction_card.dart
import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Icon(Icons.money, color: Colors.teal),
        title: Text(
          transaction.category,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${transaction.description}\n${transaction.date.toLocal().toShortString()}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          '\$${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: transaction.amount < 0 ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}

extension DateFormatting on DateTime {
  String toShortString() {
    return "${this.day}/${this.month}/${this.year}";
  }
}
