import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(String uid, String email, String phone) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'phone': phone,
      });
      print("Пользователь успешно сохранен в Firestore");
    } catch (e) {
      print("Ошибка при сохранении пользователя в Firestore: $e");
    }
  }
}
