import 'package:dart_g21/models/profile.dart';
import 'package:dart_g21/repositories/localStorage_repository.dart';
import 'package:dart_g21/repositories/profile_repository.dart';

class ProfileController {
  final ProfileRepository _profileRepository = ProfileRepository();
  final LocalStorageRepository _localStorageRepository = LocalStorageRepository();

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
    print("Saving categories for userId: $userId");
    print("Selected categories: $categoryIds");
    try {
      await _profileRepository.updateCategoriesByUserId(userId, categoryIds);
      print("Categorías actualizadas correctamente");
    } catch (e) {
      print("Error saving categories: $e");
      rethrow;
    }
  }

  // Agregar un evento a la lista de eventos asociados de un perfil
  Future<void> registerEventToProfile(String profileId, String eventId) async {
    await _profileRepository.registerEventToProfile(profileId, eventId);
  }

  Future<String?> getProfileIdFromUserId(String userId) async {
  return await _profileRepository.getProfileIdByUserId(userId);
  }

  Future<void> saveProfileToLocal(String userId, Profile profile) async {
    try {
      await _localStorageRepository.saveProfile(userId, profile);
    } catch (e) {
      print("Error al guardar el perfil en el almacenamiento local: $e");
    }
  }

  Future<Profile?> getProfileFromLocal(String userId) async {
    try {
      return _localStorageRepository.getProfileByUserId(userId);
    } catch (e) {
      print("Error al obtener el perfil desde el almacenamiento local: $e");
      return null;
    }
  }

  Future<void> saveFollowersAndFollowingToLocal(String userId, List<String> followers, List<String> following) async {
    try {
      await _localStorageRepository.saveFollowersAndFollowing(userId, followers, following);
    } catch (e) {
      print("Error al guardar seguidores y seguidos en el almacenamiento local: $e");
    }
  }


  Future<Map<String, List<String>>> getFollowersAndFollowingFromLocal(String userId) async {
    try {
      return _localStorageRepository.getFollowersAndFollowing(userId);
    } catch (e) {
      print("Error al obtener seguidores y seguidos desde el almacenamiento local: $e");
      return {'followers': [], 'following':[]};
}
}

  Future<void> saveUserNameToLocal(String userId, String userName) async {
    try {
      await _localStorageRepository.saveUserName(userId, userName);
    } catch (e) {
      print("Error al guardar el nombre de usuario en el almacenamiento local: $e");
    }
  }

  Future<String?> getUserNameFromLocal(String userId) async {
    try {
      return await _localStorageRepository.getUserName(userId);
    } catch (e) {
      print("Error al obtener el nombre de usuario desde el almacenamiento local: $e");
      return null;
    }
  }

  /// devuelve los ids (de user) de los seguidores de un usuario
  Stream<List<String>> getFollowersStream(String profileId) {
    return _profileRepository.getFollowers(profileId);
  }

  Stream<List<String>> getFollowingsStream(String profileId) {
    return _profileRepository.getFollowing(profileId);
  }

  Future<void> followUser(String currentUserId, String targetUserId) async {
    return await _profileRepository.followUser(currentUserId, targetUserId);
  }

  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    return await _profileRepository.unfollowUser(currentUserId, targetUserId);
  }

}