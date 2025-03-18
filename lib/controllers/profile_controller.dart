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

  Future<void> addProfile(Profile profile) async {
    await _profileRepository.addProfile(profile);
  }

  Future<void> updateProfile(Profile profile) async {
    await _profileRepository.updateProfile(profile);
  }

  Future<void> deleteProfile(String profileId) async {
    await _profileRepository.deleteProfile(profileId);
  }
}