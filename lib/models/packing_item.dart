// lib/models/packing_item.dart
// One PackingItem = one row in the "packing_items" table.

class PackingItem {
  final int? id;
  final int tripId;
  final String name;
  final bool isPacked;

  const PackingItem({
    this.id,
    required this.tripId,
    required this.name,
    this.isPacked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'trip_id': tripId,
      'name': name,
      'is_packed': isPacked ? 1 : 0,
    };
  }

  factory PackingItem.fromMap(Map<String, dynamic> map) {
    return PackingItem(
      id: map['id'] as int?,
      tripId: map['trip_id'] as int,
      name: map['name'] as String,
      isPacked: map['is_packed'] == 1,
    );
  }

  PackingItem copyWith({
    int? id,
    int? tripId,
    String? name,
    bool? isPacked,
  }) {
    return PackingItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      isPacked: isPacked ?? this.isPacked,
    );
  }
}