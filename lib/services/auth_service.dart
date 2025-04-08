import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Регистрация пользователя
  Future<User?> register(String email, String password, String phone) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Сохраняем данные пользователя в Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'phone': phone,
          'name': '',
          'surname': '',
          'createdAt': DateTime.now().toIso8601String(),
          'isAdmin': false,
        });

        print("Пользователь успешно создан и добавлен в Firestore: ${user.uid}");
        return user;
      } else {
        print("Ошибка: Пользователь не создан");
        return null;
      }
    } catch (e) {
      print("Ошибка при регистрации: $e");
      return null;
    }
  }

  // Вход пользователя
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Ошибка при входе: $e");
      return null;
    }
  }

  // Выход пользователя
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
