// lib/database/database_helper.dart
// This class opens the SQLite database and creates all the tables.
// We use the "Singleton" pattern: the whole app shares ONE DatabaseHelper
// and ONE open database connection.

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // ---- Singleton setup ----
  // The private constructor (_internal) stops other files from writing
  // DatabaseHelper() and creating a second copy.
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  // ---- Database settings ----
  static const String _dbName = 'triptick.db';
  static const int _dbVersion = 1; // raise this number when tables change

  // ---- Table names (constants avoid typing mistakes in other files) ----
  static const String tableTrips = 'trips';
  static const String tablePlaces = 'places';
  static const String tableExpenses = 'expenses';
  static const String tablePackingItems = 'packing_items';
  static const String tableItineraryDays = 'itinerary_days';

  // The open database. It is null until the first time we need it.
  Database? _database;

  // Other files call "await DatabaseHelper.instance.database".
  // If the database is already open we reuse it, otherwise we open it now.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Finds the right folder on the phone and opens (or creates) the file.
  Future<Database> _initDatabase() async {
    final String folder = await getDatabasesPath();
    final String path = join(folder, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Runs every time the database is opened, BEFORE onCreate.
  // SQLite ignores foreign keys by default, so we must turn them on.
  // Without this line, "ON DELETE CASCADE" would NOT work.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Runs only ONCE, the first time the database file is created.
  Future<void> _onCreate(Database db, int version) async {
    // Note about booleans: SQLite has no true/false type,
    // so we store them as INTEGER: 0 = false, 1 = true.
    // Note about dates: we store them as TEXT in ISO format
    // (example: 2026-12-25), which sorts correctly.

    // 1) trips: the parent table. Every other table points to it.
    await db.execute('''
      CREATE TABLE $tableTrips (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT NOT NULL,
        country    TEXT NOT NULL,
        status     TEXT NOT NULL DEFAULT 'Wishlist'
                   CHECK (status IN ('Wishlist', 'Planned', 'Completed')),
        budget_min REAL,
        budget_max REAL,
        currency   TEXT NOT NULL DEFAULT 'THB',
        start_date TEXT,
        end_date   TEXT
      )
    ''');

    // 2) itinerary_days: created BEFORE places, because places.day_id
    //    points to this table and the target table must exist first.
    await db.execute('''
      CREATE TABLE $tableItineraryDays (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        trip_id    INTEGER NOT NULL,
        day_number INTEGER NOT NULL,
        date       TEXT,
        title      TEXT,
        FOREIGN KEY (trip_id) REFERENCES $tableTrips (id)
          ON DELETE CASCADE
      )
    ''');

    // 3) places: belong to a trip, and optionally to one itinerary day.
    await db.execute('''
      CREATE TABLE $tablePlaces (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        trip_id       INTEGER NOT NULL,
        name          TEXT NOT NULL,
        city          TEXT,
        category      TEXT,
        is_must_visit INTEGER NOT NULL DEFAULT 0,
        is_visited    INTEGER NOT NULL DEFAULT 0,
        note          TEXT,
        photo_path    TEXT,
        map_link      TEXT,
        day_id        INTEGER,
        FOREIGN KEY (trip_id) REFERENCES $tableTrips (id)
          ON DELETE CASCADE,
        FOREIGN KEY (day_id) REFERENCES $tableItineraryDays (id)
          ON DELETE SET NULL
      )
    ''');

    // 4) expenses: money actually spent on a trip.
    await db.execute('''
      CREATE TABLE $tableExpenses (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        trip_id  INTEGER NOT NULL,
        category TEXT NOT NULL,
        amount   REAL NOT NULL,
        note     TEXT,
        date     TEXT NOT NULL,
        FOREIGN KEY (trip_id) REFERENCES $tableTrips (id)
          ON DELETE CASCADE
      )
    ''');

    // 5) packing_items: things to pack for a trip.
    await db.execute('''
      CREATE TABLE $tablePackingItems (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        trip_id   INTEGER NOT NULL,
        name      TEXT NOT NULL,
        is_packed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (trip_id) REFERENCES $tableTrips (id)
          ON DELETE CASCADE
      )
    ''');
  }

  // Runs when you raise _dbVersion. Empty for now; it is the place where
  // we would add ALTER TABLE commands if the tables change later.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  // Closes the connection (useful for tests).
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}