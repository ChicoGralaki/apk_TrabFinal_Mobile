import 'package:cloud_firestore/cloud_firestore.dart';

class AgendaEvent {
  const AgendaEvent({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.eventAt,
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
    this.imagePath,
    this.deletedAt,
    this.isSynced = false,
  });

  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime eventAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? latitude;
  final double? longitude;

  /// Device-local path. It is intentionally never uploaded to Firestore.
  final String? imagePath;
  final DateTime? deletedAt;
  final bool isSynced;

  AgendaEvent copyWith({
    String? title,
    String? description,
    DateTime? eventAt,
    DateTime? updatedAt,
    double? latitude,
    double? longitude,
    String? imagePath,
    bool clearLocation = false,
    bool clearImage = false,
    DateTime? deletedAt,
    bool? isSynced,
  }) => AgendaEvent(
    id: id,
    userId: userId,
    title: title ?? this.title,
    description: description ?? this.description,
    eventAt: eventAt ?? this.eventAt,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    latitude: clearLocation ? null : latitude ?? this.latitude,
    longitude: clearLocation ? null : longitude ?? this.longitude,
    imagePath: clearImage ? null : imagePath ?? this.imagePath,
    deletedAt: deletedAt,
    isSynced: isSynced ?? this.isSynced,
  );

  Map<String, Object?> toLocalMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'eventAt': eventAt.toUtc().toIso8601String(),
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'imagePath': imagePath,
    'deletedAt': deletedAt?.toUtc().toIso8601String(),
    'isSynced': isSynced ? 1 : 0,
  };

  factory AgendaEvent.fromLocalMap(Map<String, Object?> map) => AgendaEvent(
    id: map['id']! as String,
    userId: map['userId']! as String,
    title: map['title']! as String,
    description: map['description']! as String,
    eventAt: DateTime.parse(map['eventAt']! as String).toLocal(),
    createdAt: DateTime.parse(map['createdAt']! as String).toLocal(),
    updatedAt: DateTime.parse(map['updatedAt']! as String).toLocal(),
    latitude: (map['latitude'] as num?)?.toDouble(),
    longitude: (map['longitude'] as num?)?.toDouble(),
    imagePath: map['imagePath'] as String?,
    deletedAt: map['deletedAt'] == null
        ? null
        : DateTime.parse(map['deletedAt']! as String).toLocal(),
    isSynced: map['isSynced'] == 1,
  );

  Map<String, Object?> toFirestoreMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'eventAt': Timestamp.fromDate(eventAt.toUtc()),
    'createdAt': Timestamp.fromDate(createdAt.toUtc()),
    'updatedAt': Timestamp.fromDate(updatedAt.toUtc()),
    'latitude': latitude,
    'longitude': longitude,
  };

  factory AgendaEvent.fromFirestoreMap(Map<String, dynamic> map) {
    DateTime date(Object? value) => value is Timestamp
        ? value.toDate().toLocal()
        : DateTime.parse(value as String).toLocal();
    return AgendaEvent(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      eventAt: date(map['eventAt']),
      createdAt: date(map['createdAt']),
      updatedAt: date(map['updatedAt']),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isSynced: true,
    );
  }

  bool occursOn(DateTime day) =>
      eventAt.year == day.year &&
      eventAt.month == day.month &&
      eventAt.day == day.day;
}
