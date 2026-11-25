// lib/providers/trip_provider.dart
// Holds ALL trips in memory. The "trips" getter returns them after
// applying the search text, status filter, country filter and sort.

import 'package:flutter/foundation.dart';

import '../models/trip.dart';
import '../repositories/trip_repository.dart';
import '../services/notification_service.dart';

enum TripSort { newest, name, startDate, budget }

class TripProvider extends ChangeNotifier {
  final TripRepository _repository;

  TripProvider({TripRepository? repository})
      : _repository = repository ?? TripRepository();

  List<Trip> _allTrips = [];
  String? _statusFilter; // null = all
  String? _countryFilter; // null = all
  String _query = '';
  TripSort _sort = TripSort.newest;
  bool _isLoading = false;
  String? _error;

  String? get statusFilter => _statusFilter;
  String? get countryFilter => _countryFilter;
  TripSort get sort => _sort;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasAnyTrips => _allTrips.isNotEmpty;

  /// Countries that exist in the data (for the country filter menu).
  List<String> get countries {
    final list = _allTrips.map((t) => t.country).toSet().toList();
    list.sort();
    return list;
  }

  /// The list the screen shows: filtered, searched and sorted.
  List<Trip> get trips {
    final q = _query.trim().toLowerCase();

    final list = _allTrips.where((t) {
      if (_statusFilter != null && t.status != _statusFilter) return false;
      if (_countryFilter != null && t.country != _countryFilter) return false;
      if (q.isNotEmpty &&
          !t.name.toLowerCase().contains(q) &&
          !t.country.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();

    list.sort((a, b) {
      switch (_sort) {
        case TripSort.newest:
          return (b.id ?? 0).compareTo(a.id ?? 0);
        case TripSort.name:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case TripSort.startDate:
          // Trips without a date go to the bottom.
          if (a.startDate == null && b.startDate == null) return 0;
          if (a.startDate == null) return 1;
          if (b.startDate == null) return -1;
          return a.startDate!.compareTo(b.startDate!);
        case TripSort.budget:
          // Highest max budget first. No budget = bottom.
          final x = a.budgetMax ?? -1;
          final y = b.budgetMax ?? -1;
          return y.compareTo(x);
      }
    });
    return list;
  }

  // ---------- search / filter / sort (no database call needed) ----------
  void setSearchQuery(String text) {
    _query = text;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setCountryFilter(String? country) {
    _countryFilter = country;
    notifyListeners();
  }

  void setSort(TripSort sort) {
    _sort = sort;
    notifyListeners();
  }

  // ---------- database work ----------
  Future<void> loadTrips() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allTrips = await _repository.getAll();
      // If the filtered country no longer exists, clear that filter.
      if (_countryFilter != null &&
          !_allTrips.any((t) => t.country == _countryFilter)) {
        _countryFilter = null;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<int> addTrip(Trip trip) async {
    final id = await _repository.insert(trip);
    await NotificationService.instance.scheduleTripReminder(trip.copyWith(id: id));
    await loadTrips();
    return id;
  }

  Future<void> updateTrip(Trip trip) async {
    await _repository.update(trip);
    await NotificationService.instance.scheduleTripReminder(trip);
    await loadTrips();
  }

  Future<void> deleteTrip(int id) async {
    await _repository.delete(id);
    await NotificationService.instance.cancelTripReminder(id);
    await loadTrips();
  }

  Future<Trip?> getTripById(int id) => _repository.getById(id);
}