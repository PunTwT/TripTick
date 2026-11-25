# TripTick

**An offline vacation checklist and planner built with Flutter and SQLite.**

ITCS259 Mobile Application Development – Final Project
Faculty of Information and Communication Technology, Mahidol University

TripTick helps travelers keep everything about a trip in one place: destinations, places to visit, budget, packing list and a day-by-day plan. All data is stored in a SQLite database on the phone, so the app needs **no internet, no server and no account**.

---

## Features

- **Destination checklist:** add, edit and delete destinations with status (Wishlist / Planned / Completed), expected budget range (min and max), currency and travel period
- **Places:** save landmarks and must-visit spots, mark them as must-visit, tick them as visited, with a progress bar
- **Budget tracker:** log expenses by category and compare the total with the expected budget, with an over-budget warning
- **Packing list:** add items, tick them as packed, see a progress bar
- **Itinerary:** create Day 1 to Day N (automatically from the trip dates or by hand) and assign places to each day
- **Notes and photos:** add notes and a photo (camera or gallery) to each place
- **Reminders:** a local notification at 09:00 on the day before a trip starts
- **Search, filter and sort:** by name, country, status, start date or budget
- **Maps shortcut:** open a place in the phone's map app or browser
- **Backup:** export all data to a JSON file, copy it to the clipboard, or import it back
- **Light / dark theme:** system, light or dark, remembered after the app closes
- **Sample data:** one tap in Settings loads a demo Japan trip and a Paris wishlist

---

## Tech stack

| Technology | Purpose |
|---|---|
| Flutter and Dart (null safety) | UI and app logic |
| `sqflite`, `path`, `path_provider` | Local SQLite database and file paths |
| `provider` | State management |
| `intl` | Date and money formatting |
| `image_picker` | Camera and gallery photos |
| `flutter_local_notifications`, `timezone` | Local reminders |
| `url_launcher` | Open places in the maps app |
| `share_plus` | Share the exported backup file |
| `shared_preferences` | Save the theme setting |

---

## Architecture

The app has layers. Each layer only talks to the layer below it.

```
UI (screens, widgets)
        |
State (providers: TripProvider, TripContentProvider, ThemeProvider)
        |
Repositories (one per table: CRUD)
        |
DatabaseHelper  ->  SQLite file (triptick.db)
```

### Project structure

```
lib/
├── main.dart
├── app_routes.dart
├── database/
│   └── database_helper.dart       # opens the database, creates tables
├── models/                        # Trip, Place, Expense, PackingItem, ItineraryDay
├── repositories/                  # CRUD for each table
├── providers/                     # TripProvider, TripContentProvider, ThemeProvider
├── services/                      # notifications, backup, sample data
├── screens/                       # home, trip form, trip detail, place form, settings
│   └── tabs/                      # overview, places, budget, packing, itinerary
├── widgets/                       # reusable widgets and dialogs
├── theme/                         # light and dark theme
└── utils/                         # constants, formatting, maps, photos, dates
```

## Database

SQLite database `triptick.db` with 5 tables. Every table links to `trips` with `trip_id`, and deleting a trip also deletes everything under it (`ON DELETE CASCADE`).

| Table | Main columns |
|---|---|
| `trips` | id, name, country, status, budget_min, budget_max, currency, start_date, end_date |
| `places` | id, trip_id, name, city, category, is_must_visit, is_visited, note, photo_path, map_link, day_id |
| `expenses` | id, trip_id, category, amount, note, date |
| `packing_items` | id, trip_id, name, is_packed |
| `itinerary_days` | id, trip_id, day_number, date, title |

Notes: booleans are stored as 0/1 and dates as ISO text (`2027-03-01`). Foreign keys are switched on with `PRAGMA foreign_keys = ON` each time the database opens. If a day is deleted, its places stay in the trip (`ON DELETE SET NULL`).

---

## Getting started

### Requirements

- Flutter SDK [version, for example 3.x. Run `flutter --version` and write yours]
- Android Studio with the Android SDK, and an Android emulator or a real phone with USB debugging
- Git

### Installation

```bash
# 1. Clone the project
git clone https://github.com/PunTwT/TripTick.git

# 2. Download the packages
flutter pub get

# 3. Check your setup (Flutter and Android toolchain should be green)
flutter doctor

# 4. List devices and run on an Android emulator or phone
flutter devices
flutter run -d <device-id>
```

The first build takes several minutes.

### Android setup (already done in this repository)

These changes are needed for local notifications. If you create the project from scratch, add them yourself:

1. `android/app/src/main/AndroidManifest.xml` has the permissions `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED` and `VIBRATE`, and the two `flutter_local_notifications` receivers.
2. `android/app/build.gradle.kts` has core library desugaring turned on (`isCoreLibraryDesugaringEnabled = true` and the `desugar_jdk_libs` dependency).

---

## How to use and test

1. Open the app and tap **Settings → Load sample data** to get a full demo trip (or tap **Add destination** to start from nothing).
2. Tap a trip to open its 5 tabs: Overview, Places, Budget, Packing, Itinerary.
3. **Reminders:** Settings → **Send test notification**. For a real reminder, set a trip start date that is at least two days away and allow notifications when Android asks.
4. **Backup:** Settings → **Export and share backup** (creates a `.json` file) or **Copy backup to clipboard**. To restore, use **Import backup**, paste the JSON and confirm. Importing replaces all current data.
5. **Theme:** Settings → System / Light / Dark.

## Known limitations

- Data is stored only on one phone. There is no cloud sync.
- The backup file stores photo paths, not the photo files, so photos are not restored on another phone.
- Import works by pasting JSON text, not by choosing a file.
- Reminders use an inexact schedule, so Android may deliver them a little after 09:00.
- One currency per trip, with no exchange rates.
- Testing was manual. There are no automated tests yet.

## Future improvements

- Cloud backup and sync
- Photos included in the backup and choosing the import file from storage
- In-app map view
- Exchange rates and spending charts
- Shared trips and packing templates
- Automated unit and widget tests

---