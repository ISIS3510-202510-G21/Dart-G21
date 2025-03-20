import '../repositories/user_repository.dart';
import '../models/user.dart';

class UserController {
  final UserRepository _userRepo = UserRepository();

  // Expone el Observer a la Vista
  Stream<List<User>> getUsersStream() {
    return _userRepo.getUsersStream();
  }

  Future<User?> getUserById(String userId) async {
    return await _userRepo.getUserById(userId);
  }

  Future<void> addUser(User user) async {
    await _userRepo.addUser(user);
  }

  Future<void> updateUser(User user) async {
    await _userRepo.updateUser(user);
  }

  Future<void> deleteUser(String userId) async {
    await _userRepo.deleteUser(userId);
  }
}
