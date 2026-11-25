// lib/providers/trip_content_provider.dart
// Data of ONE trip: the trip itself, its places, expenses, packing items, days.
// Created by TripDetailScreen, so it exists only while that screen is open.

import 'package:flutter/foundation.dart';

import '../models/expense.dart';
import '../models/itinerary_day.dart';
import '../models/packing_item.dart';
import '../models/place.dart';
import '../models/trip.dart';
import '../repositories/expense_repository.dart';
import '../repositories/itinerary_day_repository.dart';
import '../repositories/packing_item_repository.dart';
import '../repositories/place_repository.dart';
import '../repositories/trip_repository.dart';

class TripContentProvider extends ChangeNotifier {
  final int tripId;
  TripContentProvider(this.tripId);

  final _tripRepo = TripRepository();
  final _placeRepo = PlaceRepository();
  final _expenseRepo = ExpenseRepository();
  final _packingRepo = PackingItemRepository();
  final _dayRepo = ItineraryDayRepository();

  Trip? trip;
  List<Place> places = [];
  List<Expense> expenses = [];
  List<PackingItem> packingItems = [];
  List<ItineraryDay> days = [];
  bool isLoading = true;

  // Safety: if the screen closes while a database call is still running,
  // we must not call notifyListeners on a disposed provider.
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  /// Reads everything of this trip from the database.
  Future<void> load() async {
    trip = await _tripRepo.getById(tripId);
    places = await _placeRepo.getByTripId(tripId);
    expenses = await _expenseRepo.getByTripId(tripId);
    packingItems = await _packingRepo.getByTripId(tripId);
    days = await _dayRepo.getByTripId(tripId);
    isLoading = false;
    notifyListeners();
  }

  // ===================== Places (Step 6) =====================
  Future<void> addPlace(Place place) async {
    await _placeRepo.insert(place);
    await load();
  }

  Future<void> updatePlace(Place place) async {
    await _placeRepo.update(place);
    await load();
  }

  Future<void> deletePlace(int id) async {
    await _placeRepo.delete(id);
    await load();
  }

  Future<void> toggleVisited(Place place) =>
      updatePlace(place.copyWith(isVisited: !place.isVisited));

  int get visitedCount => places.where((p) => p.isVisited).length;

  // ===================== Budget (Step 7) =====================
  Future<void> addExpense(Expense expense) async {
    await _expenseRepo.insert(expense);
    await load();
  }

  Future<void> updateExpense(Expense expense) async {
    await _expenseRepo.update(expense);
    await load();
  }

  Future<void> deleteExpense(int id) async {
    await _expenseRepo.delete(id);
    await load();
  }

  double get totalSpent => expenses.fold(0.0, (sum, e) => sum + e.amount);

  Map<String, double> get spentByCategory {
    final map = <String, double>{};
    for (final e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  // ===================== Packing (Step 8) =====================
  Future<void> addPackingItem(String name) async {
    await _packingRepo.insert(PackingItem(tripId: tripId, name: name));
    await load();
  }

  Future<void> togglePacked(PackingItem item) async {
    await _packingRepo.update(item.copyWith(isPacked: !item.isPacked));
    await load();
  }

  Future<void> deletePackingItem(int id) async {
    await _packingRepo.delete(id);
    await load();
  }

  int get packedCount => packingItems.where((i) => i.isPacked).length;

  // ===================== Itinerary (Step 9) =====================
  Future<void> addDay() async {
    final nextNumber = days.isEmpty
        ? 1
        : days.map((d) => d.dayNumber).reduce((a, b) => a > b ? a : b) + 1;
    final start = trip?.startDate;
    final date = start == null
        ? null
        : DateTime(start.year, start.month, start.day + nextNumber - 1);
    await _dayRepo.insert(
      ItineraryDay(tripId: tripId, dayNumber: nextNumber, date: date),
    );
    await load();
  }

  /// Creates Day 1..N from the trip's start and end dates (max 60 days).
  Future<void> generateDaysFromDates() async {
    final start = trip?.startDate;
    final end = trip?.endDate;
    if (start == null || end == null) return;

    // UTC dates avoid daylight-saving problems when counting days.
    final count = DateTime.utc(end.year, end.month, end.day)
            .difference(DateTime.utc(start.year, start.month, start.day))
            .inDays +
        1;
    if (count < 1) return;

    for (var i = 0; i < count && i < 60; i++) {
      await _dayRepo.insert(ItineraryDay(
        tripId: tripId,
        dayNumber: i + 1,
        date: DateTime(start.year, start.month, start.day + i),
      ));
    }
    await load();
  }

  Future<void> renameDay(ItineraryDay day, String title) async {
    await _dayRepo.update(day.copyWith(title: title));
    await load();
  }

  Future<void> deleteDay(int id) async {
    await _dayRepo.delete(id); // places on that day become "unassigned"
    await load();
  }

  ItineraryDay? dayById(int? id) =>
      days.where((d) => d.id == id).firstOrNull;

  List<Place> placesOfDay(int dayId) =>
      places.where((p) => p.dayId == dayId).toList();

  List<Place> get unassignedPlaces =>
      places.where((p) => p.dayId == null).toList();

  /// Puts a place on a day (or removes it from a day when dayId is null).
  /// We build a new Place because copyWith cannot set a field to null.
  Future<void> setPlaceDay(Place p, int? dayId) {
    return updatePlace(Place(
      id: p.id,
      tripId: p.tripId,
      name: p.name,
      city: p.city,
      category: p.category,
      isMustVisit: p.isMustVisit,
      isVisited: p.isVisited,
      note: p.note,
      photoPath: p.photoPath,
      mapLink: p.mapLink,
      dayId: dayId,
    ));
  }
}