import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/agenda_event_model.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> _records(String uid) =>
      _firestore.collection('users').doc(uid).collection('registros');
  Future<void> put(AgendaEvent event) =>
      _records(event.userId)
          .doc(event.id)
          .set(event.toFirestoreMap())
          .timeout(const Duration(seconds: 25));
  Future<void> delete(String uid, String id) =>
      _records(uid).doc(id).delete().timeout(const Duration(seconds: 25));
  Stream<List<AgendaEvent>> watch(String uid) =>
      _records(uid)
          .where('userId', isEqualTo: uid)
          .snapshots(includeMetadataChanges: true)
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => AgendaEvent.fromFirestoreMap(doc.data()))
                .toList(),
          );
}
