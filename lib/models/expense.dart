// lib/models/expense.dart
// One Expense = one row in the "expenses" table (money actually spent).

import '../utils/date_helper.dart';

class Expense {
  final int? id;
  final int tripId;
  final String category; // example: Food, Transport, Hotel
  final double amount;
  final String? note;
  final DateTime date; // required in the database (NOT NULL)

  const Expense({
    this.id,
    required this.tripId,
    required this.category,
    required this.amount,
    this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'trip_id': tripId,
      'category': category,
      'amount': amount,
      'note': note,
      'date': dateToDb(date), // never null here because date is required
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      tripId: map['trip_id'] as int,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
    );
  }

  Expense copyWith({
    int? id,
    int? tripId,
    String? category,
    double? amount,
    String? note,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }
}