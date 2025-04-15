import 'package:dart_g21/models/skill.dart';
import 'package:dart_g21/repositories/skill_repository.dart';

class SkillController {
  final SkillRepository _skillRepository = SkillRepository();

  Stream<List<Skill>> getSkillsStream() {
    return _skillRepository.getSkillsStream();
  }

  Future<Skill?> getSkillById(String skillId) async {
    return await _skillRepository.getSkillById(skillId);
  }

  Future<void> addSkill(Skill skill) async {
    await _skillRepository.addSkill(skill);
  }

  Future<void> updateSkill(Skill skill) async {
    await _skillRepository.updateSkill(skill);
  }

  Future<void> deleteSkill(String interestId) async {
    await _skillRepository.deleteSkill(interestId);
  }

  Future<List<String>> getSkillsByIds(List<String> skillIds) async {
    return await _skillRepository.getSkillsByIds(skillIds);
  }

}