import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';

final profileProvider = Provider<ProfileService>((ref) {
  return ProfileService(FirebaseFirestore.instance, ref);
});

final userProfileStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  return ref.watch(profileProvider).getUserProfile();
});

class ProfileService {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  ProfileService(this._firestore, this._ref);

  Stream<Map<String, dynamic>?> getUserProfile() {
    // Watch the auth state changes so this stream re-evaluates when user logs in/out
    final user = _ref.watch(authStateChangesProvider).value;
    if (user == null) return const Stream.empty();
    
    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) => doc.data());
  }

  Future<void> createUserProfile({
    required String name,
    required DateTime birthday,
    required String gender,
    required double height,
    required double weight,
  }) async {
    final user = _ref.read(authProvider).currentUser;
    if (user == null) throw Exception('User not logged in');

    // Calculate age
    final today = DateTime.now();
    int age = today.year - birthday.year;
    if (today.month < birthday.month || (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': user.email,
      'age': age,
      'birthday': birthday.toIso8601String(),
      'gender': gender,
      'height': height,
      'weight': weight,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
