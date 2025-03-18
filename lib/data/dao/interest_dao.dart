import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_g21/models/interest.dart';


class InterestDAO {
  final CollectionReference interestsCollection = FirebaseFirestore.instance.collection('interests');

  //Observer Pattern: Stream de usuarios en tiempo real
  Stream<List<Interest>> getInterestsStream() {
    return interestsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Interest.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  Future<Interest?> getInterestById(String interestId) async {
    DocumentSnapshot doc = await interestsCollection.doc(interestId).get();
    if (doc.exists) {
      return Interest.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> insertInterest(Interest interest) async {
    await interestsCollection.doc(interest.id).set(interest.toMap());
  }

  Future<void> updateInterest(Interest interest) async {
    await interestsCollection.doc(interest.id).update(interest.toMap());
  }

  Future<void> deleteInterest(String interestId) async {
    await interestsCollection.doc(interestId).delete();
  }
}