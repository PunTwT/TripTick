// lib/models/place.dart
// One Place = one row in the "places" table (a landmark or must-visit spot).

class Place {
  final int? id;
  final int tripId; // which trip this place belongs to
  final String name;
  final String? city;
  final String? category; // example: Landmark, Food, Nature
  final bool isMustVisit;
  final bool isVisited;
  final String? note;
  final String? photoPath;
  final String? mapLink;
  final int? dayId; // which itinerary day (null = not assigned yet)

  const Place({
    this.id,
    required this.tripId,
    required this.name,
    this.city,
    this.category,
    this.isMustVisit = false,
    this.isVisited = false,
    this.note,
    this.photoPath,
    this.mapLink,
    this.dayId,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'trip_id': tripId,
      'name': name,
      'city': city,
      'category': category,
      'is_must_visit': isMustVisit ? 1 : 0, // bool -> 0/1
      'is_visited': isVisited ? 1 : 0,
      'note': note,
      'photo_path': photoPath,
      'map_link': mapLink,
      'day_id': dayId,
    };
  }

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'] as int?,
      tripId: map['trip_id'] as int,
      name: map['name'] as String,
      city: map['city'] as String?,
      category: map['category'] as String?,
      isMustVisit: map['is_must_visit'] == 1, // 0/1 -> bool
      isVisited: map['is_visited'] == 1,
      note: map['note'] as String?,
      photoPath: map['photo_path'] as String?,
      mapLink: map['map_link'] as String?,
      dayId: map['day_id'] as int?,
    );
  }

  Place copyWith({
    int? id,
    int? tripId,
    String? name,
    String? city,
    String? category,
    bool? isMustVisit,
    bool? isVisited,
    String? note,
    String? photoPath,
    String? mapLink,
    int? dayId,
  }) {
    return Place(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      city: city ?? this.city,
      category: category ?? this.category,
      isMustVisit: isMustVisit ?? this.isMustVisit,
      isVisited: isVisited ?? this.isVisited,
      note: note ?? this.note,
      photoPath: photoPath ?? this.photoPath,
      mapLink: mapLink ?? this.mapLink,
      dayId: dayId ?? this.dayId,
    );
  }
}