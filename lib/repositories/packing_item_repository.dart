// lib/repositories/packing_item_repository.dart
// All database work for the "packing_items" table (CRUD).

import '../database/database_helper.dart';
import '../models/packing_item.dart';

class PackingItemRepository {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  Future<int> insert(PackingItem item) async {
    final db = await _helper.database;
    return db.insert(DatabaseHelper.tablePackingItems, item.toMap());
  }

  // All items of one trip, in the order they were added.
  Future<List<PackingItem>> getByTripId(int tripId) async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tablePackingItems,
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'id ASC',
    );
    return rows.map((row) => PackingItem.fromMap(row)).toList();
  }

  Future<PackingItem?> getById(int id) async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tablePackingItems,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PackingItem.fromMap(rows.first);
  }

  Future<int> update(PackingItem item) async {
    if (item.id == null) {
      throw ArgumentError('Cannot update a packing item without an id');
    }
    final db = await _helper.database;
    return db.update(
      DatabaseHelper.tablePackingItems,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _helper.database;
    return db.delete(
      DatabaseHelper.tablePackingItems,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}