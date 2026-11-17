// lib/services/sample_data.dart
// Fills the database with demo data for your presentation.

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
import 'notification_service.dart';

class SampleData {
  static Future<void> load() async {
    final tripRepo = TripRepository();
    final dayRepo = ItineraryDayRepository();
    final placeRepo = PlaceRepository();
    final expenseRepo = ExpenseRepository();
    final packingRepo = PackingItemRepository();

    // ----- Trip 1: Japan (planned) -----
    final japanId = await tripRepo.insert(Trip(
      name: 'Japan Spring 2027',
      country: 'Japan',
      status: TripStatus.planned,
      budgetMin: 60000,
      budgetMax: 80000,
      currency: 'THB',
      startDate: DateTime(2027, 3, 1),
      endDate: DateTime(2027, 3, 8),
    ));

    final day1 = await dayRepo.insert(ItineraryDay(
        tripId: japanId, dayNumber: 1, date: DateTime(2027, 3, 1), title: 'Arrive in Tokyo'));
    final day2 = await dayRepo.insert(ItineraryDay(
        tripId: japanId, dayNumber: 2, date: DateTime(2027, 3, 2), title: 'Temples and markets'));
    final day3 = await dayRepo.insert(ItineraryDay(
        tripId: japanId, dayNumber: 3, date: DateTime(2027, 3, 3), title: 'Day trip to Kyoto'));

    await placeRepo.insert(Place(
        tripId: japanId, name: 'Shibuya Crossing', city: 'Tokyo',
        category: 'Landmark', isMustVisit: true, dayId: day1,
        note: 'Go in the evening for the best view.'));
    await placeRepo.insert(Place(
        tripId: japanId, name: 'Senso-ji Temple', city: 'Tokyo',
        category: 'Temple', isMustVisit: true, dayId: day2));
    await placeRepo.insert(Place(
        tripId: japanId, name: 'Tsukiji Outer Market', city: 'Tokyo',
        category: 'Food', dayId: day2));
    await placeRepo.insert(Place(
        tripId: japanId, name: 'Fushimi Inari Shrine', city: 'Kyoto',
        category: 'Landmark', isMustVisit: true, dayId: day3));
    await placeRepo.insert(Place(
        tripId: japanId, name: 'Nara Park', city: 'Nara', category: 'Nature'));

    await expenseRepo.insert(Expense(
        tripId: japanId, category: 'Flight', amount: 18000, note: 'Round trip', date: DateTime(2026, 11, 10)));
    await expenseRepo.insert(Expense(
        tripId: japanId, category: 'Hotel', amount: 12000, note: 'Deposit', date: DateTime(2026, 11, 12)));
    await expenseRepo.insert(Expense(
        tripId: japanId, category: 'Transport', amount: 2200, note: 'Rail pass', date: DateTime(2026, 11, 14)));

    await packingRepo.insert(PackingItem(tripId: japanId, name: 'Passport', isPacked: true));
    await packingRepo.insert(PackingItem(tripId: japanId, name: 'Phone charger'));
    await packingRepo.insert(PackingItem(tripId: japanId, name: 'Power adapter'));
    await packingRepo.insert(PackingItem(tripId: japanId, name: 'Rain jacket', isPacked: true));
    await packingRepo.insert(PackingItem(tripId: japanId, name: 'Camera'));

    // ----- Trip 2: Paris (wishlist, almost empty) -----
    await tripRepo.insert(const Trip(
      name: 'Paris someday',
      country: 'France',
      currency: 'EUR',
    ));

    // Schedule the reminder for the Japan trip.
    final japan = await tripRepo.getById(japanId);
    if (japan != null) {
      await NotificationService.instance.scheduleTripReminder(japan);
    }
  }
}