import 'package:flutter/material.dart';

class TransactionModal extends StatefulWidget {
  final Function(String phoneNumber, double amount, String category) onSend;

  TransactionModal({required this.onSend});

  @override
  _TransactionModalState createState() => _TransactionModalState();
}

class _TransactionModalState extends State<TransactionModal> {
  final _phoneNumberController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';

  final List<String> _categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Utilities',
    'Others',
  ];

  bool _isLoading = false;

  Future<void> _handleSend() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 5));

    final phoneNumber = _phoneNumberController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    widget.onSend(phoneNumber, amount, _selectedCategory);

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Transaction'),
      content: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSend,
          child: Text('Send'),
        ),
      ],
    );
  }
}
