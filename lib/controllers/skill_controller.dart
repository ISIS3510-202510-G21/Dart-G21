import 'package:dart_g21/data/database/app_database.dart';
import 'package:dart_g21/models/skill.dart' as model;
import 'package:dart_g21/repositories/drift_repository.dart';
import 'package:dart_g21/repositories/skill_repository.dart';
import '../repositories/localStorage_repository.dart';

class SkillController {
  final SkillRepository _skillRepository = SkillRepository();
  final LocalStorageRepository _localStorageRepository = LocalStorageRepository();
  final DriftRepository _driftRepository = DriftRepository(AppDatabase());

  Stream<List<model.Skill>> getSkillsStream() {
    return _skillRepository.getSkillsStream();
  }

  Future<model.Skill?> getSkillById(String skillId) async {
    return await _skillRepository.getSkillById(skillId);
  }

  Future<void> addSkill(model.Skill skill) async {
    await _skillRepository.addSkill(skill);
  }

  Future<void> updateSkill(model.Skill skill) async {

    await _skillRepository.updateSkill(skill);
  }

  Future<void> deleteSkill(String interestId) async {
    await _skillRepository.deleteSkill(interestId);
  }

/* Future<List<String>> getSkillsByIds(List<String> skillIds) async {
    return await _skillRepository.getSkillsByIds(skillIds);
  }
 */
  Future<List<String>> getSkillsByIds(List<String> skillIds) async {
    List<String> skillNames = [];
    for (String id in skillIds) {
      model.Skill? skill = await getSkillById(id);

      if (skill != null) {
        skillNames.add(skill.name);
      }
    }
    return skillNames;
  }

  Future<List<model.Skill>> getCachedSkills() async {
    return _localStorageRepository.getSkills();
  }

  Future<void> saveSkillsToCache(List<model.Skill> skills) async {
    await _localStorageRepository.saveSkills(skills);
  }

  Future<List<model.Skill>> getCachedSkillsDrift() async {
    return _driftRepository.getSkillsDrift();
  }

  Future<void> saveSkillsToCacheDrift(List<model.Skill> skills) async {
    await _driftRepository.saveSkillsDrift(skills);
  }

}