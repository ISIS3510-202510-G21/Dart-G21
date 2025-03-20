import '../data/dao/user_dao.dart';
import '../models/user.dart';

class UserRepository {
  final UserDAO _userDao = UserDAO();

  // Exponer Observer desde DAO
  Stream<List<User>> getUsersStream() {
    return _userDao.getUsersStream();
  }

  Future<User?> getUserById(String userId) async {
    return await _userDao.getUserById(userId);
  }

  Future<void> addUser(User user) async {
    await _userDao.insertUser(user);
  }

  Future<void> updateUser(User user) async {
    await _userDao.updateUser(user);
  }

  Future<void> deleteUser(String userId) async {
    await _userDao.deleteUser(userId);
  }

  Stream<User?> getUserByEmail(String email) {
  return _userDao.getUserByEmail(email); 
}
}
