// lib/providers/trip_provider.dart
// Holds the list of trips in memory and tells the screens when it changes.
// Flow: screen -> provider -> repository -> database
//       and back: database -> repository -> provider -> screen redraws.

import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/trip.dart';
import '../repositories/trip_repository.dart';

class TripProvider extends ChangeNotifier {
  final TripRepository _repository;

  // Optional parameter: normally we use the real repository.
  // It also makes testing easier, because a test can pass a fake one.
  TripProvider({TripRepository? repository})
      : _repository = repository ?? TripRepository();

  List<Trip> _trips = [];
  String? _statusFilter; // null = show all statuses
  bool _isLoading = false;
  String? _error;

  // Screens can read the list but cannot change it by accident.
  UnmodifiableListView<Trip> get trips => UnmodifiableListView(_trips);
  String? get statusFilter => _statusFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load trips from the database (using the current filter).
  Future<void> loadTrips() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _trips = await _repository.getAll(status: _statusFilter);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Change the status filter (Wishlist / Planned / Completed / null = all).
  Future<void> setStatusFilter(String? status) async {
    _statusFilter = status;
    await loadTrips();
  }

  // Each change: save in the database first, then reload the list.
  // This way the screen always shows what is really in the database.
  Future<int> addTrip(Trip trip) async {
    final id = await _repository.insert(trip);
    await loadTrips();
    return id;
  }

  Future<void> updateTrip(Trip trip) async {
    await _repository.update(trip);
    await loadTrips();
  }

  Future<void> deleteTrip(int id) async {
    await _repository.delete(id);
    await loadTrips();
  }

  // Read one trip (used by the detail screen).
  Future<Trip?> getTripById(int id) => _repository.getById(id);
}