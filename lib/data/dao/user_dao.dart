import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_g21/models/user.dart';

class UserDAO {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  //Observer Pattern: Stream de usuarios en tiempo real
  Stream<List<User>> getUsersStream() {
    return usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => User.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  Future<User?> getUserById(String userId) async {
    DocumentSnapshot doc = await usersCollection.doc(userId).get();
    if (doc.exists) {
      return User.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> insertUser(User user) async {
    await usersCollection.doc(user.id).set(user.toMap());
  }

  Future<void> updateUser(User user) async {
    await usersCollection.doc(user.id).update(user.toMap());
  }

  Future<void> deleteUser(String userId) async {
    await usersCollection.doc(userId).delete();
  }
}