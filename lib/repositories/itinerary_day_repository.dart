// lib/repositories/itinerary_day_repository.dart
// All database work for the "itinerary_days" table (CRUD).

import '../database/database_helper.dart';
import '../models/itinerary_day.dart';

class ItineraryDayRepository {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  Future<int> insert(ItineraryDay day) async {
    final db = await _helper.database;
    return db.insert(DatabaseHelper.tableItineraryDays, day.toMap());
  }

  // All days of one trip: Day 1, Day 2, Day 3...
  Future<List<ItineraryDay>> getByTripId(int tripId) async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tableItineraryDays,
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'day_number ASC',
    );
    return rows.map((row) => ItineraryDay.fromMap(row)).toList();
  }

  Future<ItineraryDay?> getById(int id) async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tableItineraryDays,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ItineraryDay.fromMap(rows.first);
  }

  Future<int> update(ItineraryDay day) async {
    if (day.id == null) {
      throw ArgumentError('Cannot update a day without an id');
    }
    final db = await _helper.database;
    return db.update(
      DatabaseHelper.tableItineraryDays,
      day.toMap(),
      where: 'id = ?',
      whereArgs: [day.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _helper.database;
    return db.delete(
      DatabaseHelper.tableItineraryDays,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}