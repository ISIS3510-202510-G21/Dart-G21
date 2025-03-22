import 'package:dart_g21/models/interest.dart';
import 'package:dart_g21/repositories/interest_repository.dart';

class InterestController {
  final InterestRepository _interestRepository = InterestRepository();

  Stream<List<Interest>> getInterestsStream() {
    return _interestRepository.getInterestsStream();
  }

  Future<Interest?> getInterestById(String interestId) async {
    return await _interestRepository.getInterestById(interestId);
  }

  Future<void> addInterest(Interest interest) async {
    await _interestRepository.addInterest(interest);
  }

  Future<void> updateInterest(Interest interest) async {
    await _interestRepository.updateInterest(interest);
  }

  Future<void> deleteInterest(String interestId) async {
    await _interestRepository.deleteInterest(interestId);
  }


}