// lib/repositories/expense_repository.dart
// All database work for the "expenses" table (CRUD).

import '../database/database_helper.dart';
import '../models/expense.dart';

class ExpenseRepository {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  Future<int> insert(Expense expense) async {
    final db = await _helper.database;
    return db.insert(DatabaseHelper.tableExpenses, expense.toMap());
  }

  // All expenses of one trip, newest date first.
  Future<List<Expense>> getByTripId(int tripId) async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tableExpenses,
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map((row) => Expense.fromMap(row)).toList();
  }

  Future<Expense?> getById(int id) async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tableExpenses,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Expense.fromMap(rows.first);
  }

  Future<int> update(Expense expense) async {
    if (expense.id == null) {
      throw ArgumentError('Cannot update an expense without an id');
    }
    final db = await _helper.database;
    return db.update(
      DatabaseHelper.tableExpenses,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _helper.database;
    return db.delete(
      DatabaseHelper.tableExpenses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}