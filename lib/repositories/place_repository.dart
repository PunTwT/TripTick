// lib/repositories/place_repository.dart
// All database work for the "places" table (CRUD).

import '../database/database_helper.dart';
import '../models/place.dart';

class PlaceRepository {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  Future<int> insert(Place place) async {
    final db = await _helper.database;
    return db.insert(DatabaseHelper.tablePlaces, place.toMap());
  }

  // All places of one trip. Must-visit places come first, then by name.
  Future<List<Place>> getByTripId(int tripId) async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tablePlaces,
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'is_must_visit DESC, name ASC',
    );
    return rows.map((row) => Place.fromMap(row)).toList();
  }

  Future<Place?> getById(int id) async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tablePlaces,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Place.fromMap(rows.first);
  }

  Future<int> update(Place place) async {
    if (place.id == null) {
      throw ArgumentError('Cannot update a place without an id');
    }
    final db = await _helper.database;
    return db.update(
      DatabaseHelper.tablePlaces,
      place.toMap(),
      where: 'id = ?',
      whereArgs: [place.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _helper.database;
    return db.delete(
      DatabaseHelper.tablePlaces,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}