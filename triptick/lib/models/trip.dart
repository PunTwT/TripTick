// lib/models/trip.dart
// One Trip = one row in the "trips" table.

import '../utils/date_helper.dart';

/// The three allowed statuses. Constants avoid typing mistakes like "planed".
class TripStatus {
  static const String wishlist = 'Wishlist';
  static const String planned = 'Planned';
  static const String completed = 'Completed';

  static const List<String> all = [wishlist, planned, completed];
}

class Trip {
  final int? id; // null until the database gives it an id
  final String name;
  final String country;
  final String status;
  final double? budgetMin;
  final double? budgetMax;
  final String currency;
  final DateTime? startDate;
  final DateTime? endDate;

  const Trip({
    this.id,
    required this.name,
    required this.country,
    this.status = TripStatus.wishlist,
    this.budgetMin,
    this.budgetMax,
    this.currency = 'THB',
    this.startDate,
    this.endDate,
  });

  // Object -> Map, to save into the database.
  // We skip "id" when it is null so SQLite creates the id automatically.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'country': country,
      'status': status,
      'budget_min': budgetMin,
      'budget_max': budgetMax,
      'currency': currency,
      'start_date': dateToDb(startDate),
      'end_date': dateToDb(endDate),
    };
  }

  // Map (one database row) -> object, to use in the app.
  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] as int?,
      name: map['name'] as String,
      country: map['country'] as String,
      status: map['status'] as String,
      budgetMin: (map['budget_min'] as num?)?.toDouble(),
      budgetMax: (map['budget_max'] as num?)?.toDouble(),
      currency: map['currency'] as String,
      startDate: dateFromDb(map['start_date'] as String?),
      endDate: dateFromDb(map['end_date'] as String?),
    );
  }

  // Objects are final (cannot change), so to "change" one we make a copy
  // with some new values. Note: copyWith cannot set a field back to null.
  Trip copyWith({
    int? id,
    String? name,
    String? country,
    String? status,
    double? budgetMin,
    double? budgetMax,
    String? currency,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      status: status ?? this.status,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}