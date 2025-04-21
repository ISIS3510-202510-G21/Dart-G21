import 'package:dart_g21/models/skill.dart';
import '../database/firestore_service.dart';


class SkillDAO {
  final FirestoreService _firestore = FirestoreService();
  final String collectionPath = "skills";

  // Obtener skills en tiempo real
  Stream<List<Skill>> getSkillsStream() {
    return _firestore.getCollectionStream(collectionPath).map((data) {
      return data.map((doc) => Skill.fromMap(doc, doc["id"])).toList();
    });
  }

  // Obtener skill por ID
  Future<Skill?> getSkillById(String skillId) async {
    final doc = await _firestore.getDocumentById(collectionPath, skillId);
    if (doc.exists) {
      return Skill.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Agregar skill
  Future<void> insertSkill(Skill skill) async {
    await _firestore.addDocument(collectionPath, skill.toMap());
  }

  //Actualizar skill
  Future<void> updateSkill(Skill skill) async {
    await _firestore.updateDocument(collectionPath, skill.id, skill.toMap());
  }

  //Eliminar skill
  Future<void> deleteSkill(String skillId) async {
    await _firestore.deleteDocument(collectionPath, skillId);
  }
}