import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static Future<void> saveUser(String uid, String name, String phoneNumber, String email) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(uid).set({
        'name': name,
        'phone_number': phoneNumber,
        'email': email,
      });
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }
}
