import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hogwarts_explorer/models/agenda_event_model.dart';

void main() {
  group('AgendaEvent conversions', () {
    final event = AgendaEvent(
      id: 'stable-event-1',
      userId: 'user-1',
      title: 'Aula de poções',
      description: 'Levar o caldeirão',
      eventAt: DateTime(2026, 11, 25, 15, 30),
      createdAt: DateTime(2026, 11, 20),
      updatedAt: DateTime(2026, 11, 21),
      latitude: -23.55,
      longitude: -46.63,
      imagePath: r'C:\local\agenda\event.jpg',
    );

    test('local round trip preserves owner, image and coordinates', () {
      final restored = AgendaEvent.fromLocalMap(event.toLocalMap());
      expect(restored.id, event.id);
      expect(restored.userId, event.userId);
      expect(restored.eventAt, event.eventAt);
      expect(restored.imagePath, event.imagePath);
      expect(restored.latitude, event.latitude);
      expect(restored.longitude, event.longitude);
    });

    test('Firestore payload uses Timestamp and excludes local image paths', () {
      final data = event.toFirestoreMap();
      expect(data['eventAt'], isA<Timestamp>());
      expect(data['createdAt'], isA<Timestamp>());
      expect(data.containsKey('imagePath'), isFalse);
      final restored = AgendaEvent.fromFirestoreMap(data);
      expect(restored.id, event.id);
      expect(restored.userId, event.userId);
      expect(restored.latitude, event.latitude);
      expect(restored.isSynced, isTrue);
    });

    test('event day comparison uses the device calendar day', () {
      expect(event.occursOn(DateTime(2026, 11, 25, 0)), isTrue);
      expect(event.occursOn(DateTime(2026, 11, 26, 0)), isFalse);
    });
  });
}
