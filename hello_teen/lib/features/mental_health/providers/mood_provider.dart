import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class MoodLog {
  final String id;
  final String mood;
  final int moodLevel; // 1 to 5 for charting
  final String? note;
  final DateTime timestamp;

  MoodLog({
    required this.id,
    required this.mood,
    required this.moodLevel,
    this.note,
    required this.timestamp,
  });

  factory MoodLog.fromMap(String id, Map<String, dynamic> map) {
    return MoodLog(
      id: id,
      mood: map['mood'] ?? 'happy',
      moodLevel: map['moodLevel'] ?? 3,
      note: map['note'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}

final moodProvider = Provider<MoodService>((ref) {
  return MoodService(FirebaseFirestore.instance, ref);
});

final moodLogsStreamProvider = StreamProvider<List<MoodLog>>((ref) {
  return ref.watch(moodProvider).getMoodLogs();
});

class MoodService {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  MoodService(this._firestore, this._ref);

  Stream<List<MoodLog>> getMoodLogs() {
    final user = _ref.watch(authProvider).currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('mood_logs')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: false) // oldest to newest for the chart
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MoodLog.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addMoodLog(String mood, int moodLevel, {String? note}) async {
    final user = _ref.read(authProvider).currentUser;
    if (user == null) throw Exception('User not logged in');

    await _firestore.collection('mood_logs').add({
      'userId': user.uid,
      'mood': mood,
      'moodLevel': moodLevel,
      if (note != null && note.isNotEmpty) 'note': note,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
