import 'package:dart_g21/data/dao/skill_dao.dart';
import 'package:dart_g21/models/skill.dart';

class SkillRepository {

  final SkillDAO _skillDao = SkillDAO();

  // Exponer Observer desde DAO
  Stream<List<Skill>> getSkillsStream() {
    return _skillDao.getSkillsStream();
  }

  Future<Skill?> getSkillById(String skillId) async {
    return await _skillDao.getSkillById(skillId);
  }

  Future<void> addSkill(Skill interest) async {
    await _skillDao.insertSkill(interest);
  }

  Future<void> updateSkill(Skill interest) async {
    await _skillDao.updateSkill(interest);
  }

  Future<void> deleteSkill(String skillId) async {
    await _skillDao.deleteSkill(skillId);
  }

}