import 'package:dart_g21/models/profile.dart';
import 'package:dart_g21/repositories/profile_repository.dart';

class ProfileController {
  final ProfileRepository _profileRepository = ProfileRepository();

  Stream<List<Profile>> getProfilesStream() {
    return _profileRepository.getProfilesStream();
  }

  Future<Profile?> getProfileById(String profileId) async {
    return await _profileRepository.getProfileById(profileId);
  }

  Stream<Profile?> getProfileByUserId(String userId) {
    return _profileRepository.getProfileByUserId(userId);
  }

  Future<void> addProfile(Profile profile) async {
    await _profileRepository.addProfile(profile);
  }

  Future<void> updateProfile(Profile profile) async {
    await _profileRepository.updateProfile(profile);
  }

  Future<void> deleteProfile(String profileId) async {
    await _profileRepository.deleteProfile(profileId);
  }

  //Eliminar un evento de la lista de eventos asociados de un perfil
  Future<void> removeEventFromProfile(String profileId, String eventId) async {
    Profile? profile = await getProfileById(profileId);
    if (profile != null) {
      profile.events_associated.remove(eventId);
      await updateProfile(profile);
    }
  }

  Future<void> updateUserCategories(String userId, List<String> categoryIds) async {
    await _profileRepository.updateUserCategories(userId, categoryIds);
  }

}