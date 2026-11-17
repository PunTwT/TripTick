// lib/services/notification_service.dart
// Local notifications: one reminder per trip, 1 day before the start date,
// at 09:00. No internet needed, the phone itself fires them.

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/trip.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'trip_reminders',
      'Trip reminders',
      channelDescription: 'Reminders for upcoming trips',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> init() async {
    tz_data.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings);
    _ready = true;
  }

  /// Android 13+ and iOS ask the user for permission.
  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Schedules (or re-schedules) the reminder of one trip.
  /// The notification id is the trip id, so we can cancel it later.
  Future<void> scheduleTripReminder(Trip trip) async {
    if (!_ready || trip.id == null) return;
    await cancelTripReminder(trip.id!);

    final start = trip.startDate;
    if (start == null || trip.status == TripStatus.completed) return;

    // 1 day before, at 09:00 (DateTime fixes "day 0" by itself).
    final when = DateTime(start.year, start.month, start.day - 1, 9);
    if (!when.isAfter(DateTime.now())) return; // time already passed

    try {
      await _plugin.zonedSchedule(
        trip.id!,
        'Trip tomorrow: ${trip.name}',
        'Your trip to ${trip.country} starts tomorrow. Check your packing list!',
        tz.TZDateTime.from(when, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Could not schedule reminder: $e');
    }
  }

  Future<void> cancelTripReminder(int tripId) async {
    if (!_ready) return;
    try {
      await _plugin.cancel(tripId);
    } catch (e) {
      debugPrint('Could not cancel reminder: $e');
    }
  }

  /// Shows a notification right now (used by the Settings test button).
  Future<void> showTestNotification() async {
    if (!_ready) return;
    await _plugin.show(
      0, // trip ids start at 1, so 0 is free for tests
      'TripTick',
      'Reminders work ✅',
      _details,
    );
  }
}