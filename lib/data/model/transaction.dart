class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final TransactionPaymentMethod paymentMethod;
  final String? note;
  final TransactionType transactionType;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.paymentMethod,
    this.note,
    required this.transactionType,
  });

  @override
  String toString() {
    return 'Transaction{id: $id, title: $title, amount: $amount, date: $date, categoryId: $categoryId, paymentMethod: $paymentMethod, note: $note, transactionType: $transactionType}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'paymentMethod': paymentMethod,
      'note': note,
      'transactionType': transactionType,
    };
  }

  static Transaction fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      categoryId: map['categoryId'],
      paymentMethod: map['paymentMethod'],
      note: map['note'],
      transactionType: map['transactionType'],
    );
  }
}

enum TransactionType {
  income,
  expense,
}

enum TransactionPaymentMethod{
  tng,
  cash,
  bank,
}