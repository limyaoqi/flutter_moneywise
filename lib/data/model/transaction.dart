class Transaction {
  final String? id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final TransactionPaymentMethod paymentMethod;
  final String? note;
  final TransactionType transactionType;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.paymentMethod,
    this.note,
    required this.transactionType,
  });

  Transaction copy({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? categoryId,
    TransactionPaymentMethod? paymentMethod,
    String? note,
    TransactionType? transactionType,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      transactionType: transactionType ?? this.transactionType,
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, title: $title, amount: $amount, date: $date, categoryId: $categoryId, paymentMethod: $paymentMethod, note: $note, transactionType: $transactionType}';
  }

  // Convert the Transaction object to a map for database storage
  // exp:
  // {
  //   'id': '123',
  //   'title': 'Groceries',
  //   'amount': 50.0,
  //   'date': '2023-10-01T12:00:00Z',
  //   'categoryId': '456',
  //   'paymentMethod': 'cash',
  //   'note': 'Weekly shopping',
  //   'transactionType': 'expense'
  // }

  Map<String, dynamic> toMap() {
    return {
      // 'id' field removed from map as we'll use Firestore document ID
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'paymentMethod': paymentMethod.name,
      'note': note,
      'transactionType': transactionType.name,
    };
  }

  // Convert a map from the database to a Transaction object
  // exp form:
  // {
  //   'id': '123',
  //   'title': 'Groceries',
  //   'amount': 50.0,
  //   'date': '2023-10-01T12:00:00Z',
  //   'categoryId': '456',
  //   'paymentMethod': 'cash',
  //   'note': 'Weekly shopping',
  //   'transactionType': 'expense'
  // }
  // to Transaction object
  // Transaction{
  //   id: '123',
  //   title: 'Groceries',
  //   amount: 50.0,
  //   date: DateTime.parse('2023-10-01T12:00:00Z'),
  //   categoryId: '456',
  //   paymentMethod: TransactionPaymentMethod.cash,
  //   note: 'Weekly shopping',
  //   transactionType: TransactionType.expense
  // }
  static Transaction fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      categoryId: map['categoryId'],
      note: map['note'],
      paymentMethod: TransactionPaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
      ),
      transactionType: TransactionType.values.firstWhere(
        (e) => e.name == map['transactionType'],
      ),
    );
  }
}

enum TransactionType { income, expense }

enum TransactionPaymentMethod { tng, cash, bank }
