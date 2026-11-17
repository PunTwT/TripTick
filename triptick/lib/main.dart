// lib/main.dart
// Step 3 test file: tests Create, Read, Update, Delete for all 5 repositories.
// We will replace this file in Step 4.

import 'package:flutter/material.dart';

import 'models/expense.dart';
import 'models/itinerary_day.dart';
import 'models/packing_item.dart';
import 'models/place.dart';
import 'models/trip.dart';
import 'repositories/expense_repository.dart';
import 'repositories/itinerary_day_repository.dart';
import 'repositories/packing_item_repository.dart';
import 'repositories/place_repository.dart';
import 'repositories/trip_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TripTickApp());
}

class TripTickApp extends StatelessWidget {
  const TripTickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripTick',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const CrudTestScreen(),
    );
  }
}

class CrudTestScreen extends StatefulWidget {
  const CrudTestScreen({super.key});

  @override
  State<CrudTestScreen> createState() => _CrudTestScreenState();
}

class _CrudTestScreenState extends State<CrudTestScreen> {
  String _result = 'Running tests...';

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    final tripRepo = TripRepository();
    final placeRepo = PlaceRepository();
    final expenseRepo = ExpenseRepository();
    final packingRepo = PackingItemRepository();
    final dayRepo = ItineraryDayRepository();

    final out = StringBuffer();
    bool allOk = true;

    // Small helper: prints a line and remembers if something failed.
    void check(String label, bool ok) {
      out.writeln('${ok ? '✅' : '❌'} $label');
      if (!ok) allOk = false;
    }

    try {
      // ---------- TRIP: create, read, update, filter ----------
      final tripId = await tripRepo.insert(Trip(
        name: 'Japan 2027',
        country: 'Japan',
        status: TripStatus.planned,
        budgetMin: 30000,
        budgetMax: 50000,
        currency: 'THB',
        startDate: DateTime(2027, 3, 1),
        endDate: DateTime(2027, 3, 8),
      ));
      check('Create trip', tripId > 0);

      final trip = await tripRepo.getById(tripId);
      check(
        'Read trip (name, budget, dates)',
        trip != null &&
            trip.name == 'Japan 2027' &&
            trip.budgetMax == 50000 &&
            trip.startDate == DateTime(2027, 3, 1),
      );

      await tripRepo.update(trip!.copyWith(status: TripStatus.completed));
      final updatedTrip = await tripRepo.getById(tripId);
      check('Update trip status',
          updatedTrip?.status == TripStatus.completed);

      final completed = await tripRepo.getAll(status: TripStatus.completed);
      check('Filter trips by status',
          completed.any((t) => t.id == tripId));

      // ---------- ITINERARY DAY ----------
      await dayRepo.insert(ItineraryDay(
        tripId: tripId,
        dayNumber: 1,
        date: DateTime(2027, 3, 1),
        title: 'Arrive in Tokyo',
      ));
      final days = await dayRepo.getByTripId(tripId);
      check('Create + read itinerary day',
          days.length == 1 && days.first.title == 'Arrive in Tokyo');
      final dayId = days.first.id!;

      // ---------- PLACES ----------
      final placeA = await placeRepo.insert(Place(
        tripId: tripId,
        name: 'Fushimi Inari',
        city: 'Kyoto',
        category: 'Landmark',
        isMustVisit: true,
      ));
      final placeB = await placeRepo.insert(Place(
        tripId: tripId,
        name: 'Shibuya Crossing',
        city: 'Tokyo',
        dayId: dayId, // this place is assigned to Day 1
      ));
      final places = await placeRepo.getByTripId(tripId);
      check('Create + read places (2 places)', places.length == 2);
      check('Must-visit place comes first',
          places.first.name == 'Fushimi Inari' && places.first.isMustVisit);

      final placeAData = await placeRepo.getById(placeA);
      await placeRepo.update(placeAData!.copyWith(isVisited: true));
      final placeAUpdated = await placeRepo.getById(placeA);
      check('Update place (tick as visited)',
          placeAUpdated?.isVisited == true);

      // ---------- EXPENSE ----------
      final expenseId = await expenseRepo.insert(Expense(
        tripId: tripId,
        category: 'Food',
        amount: 450.5,
        date: DateTime(2027, 3, 2),
      ));
      final expense = await expenseRepo.getById(expenseId);
      check('Create + read expense',
          expense != null && expense.amount == 450.5);

      // ---------- PACKING ITEM ----------
      final itemId = await packingRepo.insert(
        PackingItem(tripId: tripId, name: 'Passport'),
      );
      final item = await packingRepo.getById(itemId);
      await packingRepo.update(item!.copyWith(isPacked: true));
      final itemUpdated = await packingRepo.getById(itemId);
      check('Create + update packing item',
          itemUpdated?.isPacked == true);

      // ---------- DELETE tests ----------
      await dayRepo.delete(dayId);
      final placeBAfter = await placeRepo.getById(placeB);
      check('Delete day -> place stays, day_id becomes null',
          placeBAfter != null && placeBAfter.dayId == null);

      await placeRepo.delete(placeA);
      final placesLeft = await placeRepo.getByTripId(tripId);
      check('Delete one place (1 left)', placesLeft.length == 1);

      await tripRepo.delete(tripId);
      check('Delete trip', await tripRepo.getById(tripId) == null);
      check(
        'Cascade: places, expenses, packing, days all gone',
        (await placeRepo.getByTripId(tripId)).isEmpty &&
            (await expenseRepo.getByTripId(tripId)).isEmpty &&
            (await packingRepo.getByTripId(tripId)).isEmpty &&
            (await dayRepo.getByTripId(tripId)).isEmpty,
      );
    } catch (e) {
      // If anything crashes, show the error on screen so you can copy it.
      out.writeln('\n❌ ERROR: $e');
      allOk = false;
    }

    out.writeln(allOk ? '\nAll tests passed 🎉' : '\nSome tests FAILED');
    setState(() => _result = out.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Step 3: CRUD test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(_result, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}