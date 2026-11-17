// lib/utils/date_helper.dart
// SQLite stores our dates as TEXT like "2027-03-01".
// These two small functions convert between DateTime (Dart) and TEXT (database).
// Every model uses them, so we write them once here.

/// DateTime -> "2027-03-01" (or null if there is no date)
String? dateToDb(DateTime? date) {
  if (date == null) return null;
  return date.toIso8601String().substring(0, 10);
}

/// "2027-03-01" -> DateTime (or null if empty)
DateTime? dateFromDb(String? text) {
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}