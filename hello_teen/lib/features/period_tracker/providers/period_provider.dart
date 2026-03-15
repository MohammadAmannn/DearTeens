import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class CycleLog {
  final String id;
  final DateTime periodStart;
  final DateTime? periodEnd;
  final List<String> symptoms;
  final DateTime createdAt;

  CycleLog({
    required this.id,
    required this.periodStart,
    this.periodEnd,
    required this.symptoms,
    required this.createdAt,
  });

  factory CycleLog.fromMap(String id, Map<String, dynamic> map) {
    return CycleLog(
      id: id,
      periodStart: (map['periodStart'] as Timestamp).toDate(),
      periodEnd: map['periodEnd'] != null ? (map['periodEnd'] as Timestamp).toDate() : null,
      symptoms: List<String>.from(map['symptoms'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

final periodProvider = Provider<PeriodService>((ref) {
  return PeriodService(FirebaseFirestore.instance, ref);
});

final cycleLogsStreamProvider = StreamProvider<List<CycleLog>>((ref) {
  return ref.watch(periodProvider).getCycleLogs();
});

class PeriodService {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  PeriodService(this._firestore, this._ref);

  Stream<List<CycleLog>> getCycleLogs() {
    final user = _ref.watch(authProvider).currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('cycle_data')
        .where('userId', isEqualTo: user.uid)
        .orderBy('periodStart', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CycleLog.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addCycleLog({
    required DateTime periodStart,
    DateTime? periodEnd,
    required List<String> symptoms,
  }) async {
    final user = _ref.read(authProvider).currentUser;
    if (user == null) throw Exception('User not logged in');

    await _firestore.collection('cycle_data').add({
      'userId': user.uid,
      'periodStart': Timestamp.fromDate(periodStart),
      'periodEnd': periodEnd != null ? Timestamp.fromDate(periodEnd) : null,
      'symptoms': symptoms,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  DateTime predictNextPeriod(List<CycleLog> logs) {
    if (logs.isEmpty) {
      return DateTime.now(); // Default if none exists
    }
    // Assuming a standard 28-day cycle from the last period start
    final latestPeriod = logs.first.periodStart;
    return latestPeriod.add(const Duration(days: 28));
  }
}
