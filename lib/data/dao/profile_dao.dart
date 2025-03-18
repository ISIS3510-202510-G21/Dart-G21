import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_g21/models/profile.dart';

class ProfileDAO {
  final CollectionReference profilesCollection = FirebaseFirestore.instance.collection('profiles');

  // Observer Pattern: Stream de usuarios en tiempo real
  Stream<List<Profile>> getProfilesStream() {
    return profilesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Profile.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  Future<Profile?> getProfileById(String profileId) async {
    DocumentSnapshot doc = await profilesCollection.doc(profileId).get();
    if (doc.exists) {
      return Profile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> insertProfile(Profile profile) async {
    await profilesCollection.doc(profile.id).set(profile.toMap());
  }

  Future<void> updateProfile(Profile profile) async {
    await profilesCollection.doc(profile.id).update(profile.toMap());
  }

  Future<void> deleteProfile(String profileId) async {
    await profilesCollection.doc(profileId).delete();
  }
}
