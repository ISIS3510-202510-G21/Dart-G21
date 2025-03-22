import 'package:dart_g21/data/dao/interest_dao.dart';
import 'package:dart_g21/models/interest.dart';

class InterestRepository {

  final InterestDAO _interestDao = InterestDAO();

  // Exponer Observer desde DAO
  Stream<List<Interest>> getInterestsStream() {
    return _interestDao.getInterestsStream();
  }

  Future<Interest?> getInterestById(String interestId) async {
    return await _interestDao.getInterestById(interestId);
  }

  Future<void> addInterest(Interest interest) async {
    await _interestDao.insertInterest(interest);
  }

  Future<void> updateInterest(Interest interest) async {
    await _interestDao.updateInterest(interest);
  }

  Future<void> deleteInterest(String interestId) async {
    await _interestDao.deleteInterest(interestId);
  }

}