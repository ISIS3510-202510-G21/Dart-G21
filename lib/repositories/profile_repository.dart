import 'package:dart_g21/data/dao/profile_dao.dart';
import 'package:dart_g21/models/profile.dart';

class ProfileRepository {

  final ProfileDAO _profileDao = ProfileDAO();

  // Exponer Observer desde DAO
  Stream<List<Profile>> getProfilesStream() {
    return _profileDao.getProfilesStream();
  }

  Future<Profile?> getProfileById(String profileId) async {
    return await _profileDao.getProfileById(profileId);
  }

 Stream<Profile?> getProfileByUserId(String userId) {
  return _profileDao.getProfileByUserId(userId); 
}

  Future<void> addProfile(Profile profile) async {
    await _profileDao.insertProfile(profile);
  }

  Future<void> updateProfile(Profile profile) async {
    await _profileDao.updateProfile(profile);
  }

  Future<void> deleteProfile(String profileId) async {
    await _profileDao.deleteProfile(profileId);
  }

  Future<void> updateCategoriesByUserId(String userId, List<String> categoryIds) {
    return _profileDao.updateCategoriesByUserId(userId, categoryIds);
  }

}