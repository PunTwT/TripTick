// lib/services/backup_service.dart
// Export all data to a JSON file, or import it back from JSON text.
// Note: the JSON contains photo FILE PATHS, not the photo files themselves.

import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../repositories/trip_repository.dart';
import 'notification_service.dart';

class BackupService {
  final DatabaseHelper _helper = DatabaseHelper.instance;

  // Parent table first, so foreign keys are always valid while importing.
  static final List<String> _tables = [
    DatabaseHelper.tableTrips,
    DatabaseHelper.tableItineraryDays,
    DatabaseHelper.tablePlaces,
    DatabaseHelper.tableExpenses,
    DatabaseHelper.tablePackingItems,
  ];

  /// Reads every table and returns one JSON text.
  Future<String> createBackupJson() async {
    final db = await _helper.database;
    final data = <String, dynamic>{
      'app': 'TripTick',
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
    };
    for (final table in _tables) {
      data[table] = await db.query(table);
    }
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Saves the JSON to a file and opens the phone's share sheet.
  Future<void> exportAndShare() async {
    final json = await createBackupJson();
    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final file = File(p.join(dir.path, 'triptick_backup_$stamp.json'));
    await file.writeAsString(json);
    await Share.shareXFiles([XFile(file.path)], text: 'TripTick backup');
  }

  /// REPLACES all current data with the backup.
  /// Throws FormatException if the text is not a TripTick backup.
  Future<void> importFromJson(String text) async {
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic> || decoded['app'] != 'TripTick') {
      throw const FormatException('This is not a TripTick backup.');
    }

    final oldTrips = await TripRepository().getAll();
    for (final t in oldTrips) {
      await NotificationService.instance.cancelTripReminder(t.id!);
    }

    final db = await _helper.database;
    // A transaction = all or nothing. If one row is bad, nothing changes.
    await db.transaction((txn) async {
      await txn.delete(DatabaseHelper.tableTrips); // cascade deletes the rest
      for (final table in _tables) {
        final rows = decoded[table];
        if (rows is! List) continue;
        for (final row in rows) {
          await txn.insert(
            table,
            Map<String, dynamic>.from(row as Map),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });

    final newTrips = await TripRepository().getAll();
    for (final t in newTrips) {
      await NotificationService.instance.scheduleTripReminder(t);
    }
  }
}