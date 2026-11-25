// lib/repositories/trip_repository.dart
// All database work for the "trips" table (CRUD).

import '../database/database_helper.dart';
import '../models/trip.dart';

class TripRepository {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  // CREATE: returns the new id given by the database.
  Future<int> insert(Trip trip) async {
    final db = await _helper.database;
    return db.insert(DatabaseHelper.tableTrips, trip.toMap());
  }

  // READ all trips, newest first. If "status" is given, only that status.
  Future<List<Trip>> getAll({String? status}) async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tableTrips,
      where: status == null ? null : 'status = ?',
      whereArgs: status == null ? null : [status],
      orderBy: 'id DESC',
    );
    return rows.map((row) => Trip.fromMap(row)).toList();
  }

  // READ one trip by id. Returns null if it does not exist.
  Future<Trip?> getById(int id) async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tableTrips,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Trip.fromMap(rows.first);
  }

  // UPDATE: returns how many rows changed (1 if OK).
  Future<int> update(Trip trip) async {
    if (trip.id == null) {
      throw ArgumentError('Cannot update a trip without an id');
    }
    final db = await _helper.database;
    return db.update(
      DatabaseHelper.tableTrips,
      trip.toMap(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  // DELETE: also deletes the trip's places, expenses, etc. (cascade).
  Future<int> delete(int id) async {
    final db = await _helper.database;
    return db.delete(
      DatabaseHelper.tableTrips,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}