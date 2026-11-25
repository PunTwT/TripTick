// lib/models/itinerary_day.dart
// One ItineraryDay = one row in the "itinerary_days" table (Day 1, Day 2, ...).

import '../utils/date_helper.dart';

class ItineraryDay {
  final int? id;
  final int tripId;
  final int dayNumber; // 1, 2, 3, ...
  final DateTime? date;
  final String? title; // example: "Arrive in Tokyo"

  const ItineraryDay({
    this.id,
    required this.tripId,
    required this.dayNumber,
    this.date,
    this.title,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'trip_id': tripId,
      'day_number': dayNumber,
      'date': dateToDb(date),
      'title': title,
    };
  }

  factory ItineraryDay.fromMap(Map<String, dynamic> map) {
    return ItineraryDay(
      id: map['id'] as int?,
      tripId: map['trip_id'] as int,
      dayNumber: map['day_number'] as int,
      date: dateFromDb(map['date'] as String?),
      title: map['title'] as String?,
    );
  }

  ItineraryDay copyWith({
    int? id,
    int? tripId,
    int? dayNumber,
    DateTime? date,
    String? title,
  }) {
    return ItineraryDay(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      dayNumber: dayNumber ?? this.dayNumber,
      date: date ?? this.date,
      title: title ?? this.title,
    );
  }
}