import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

//agregar un nuevo servicio: storage_service.dart con una función que sube la imagen original + thumbnail

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  Future<String> uploadProfileImage(String userId, File imageFile) async {
    final ref = _storage.ref().child('profile_pictures/$userId/original.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }
  /* // Función que sube imagen original y thumbnail
  Future<Map<String, String>> uploadProfileImageAndThumbnail(String userId, File imageFile) async {
    // Subir imagen original
    final originalRef = _storage.ref().child('profile_pictures/$userId/original.jpg');
    await originalRef.putFile(imageFile);
    final originalUrl = await originalRef.getDownloadURL();

    // Crear y subir thumbnail
    final thumbnailBytes = await _generateThumbnailBytes(imageFile);
    final thumbnailRef = _storage.ref().child('profile_pictures/$userId/thumbnail.jpg');
    await thumbnailRef.putData(thumbnailBytes, SettableMetadata(contentType: 'image/jpeg'));
    final thumbnailUrl = await thumbnailRef.getDownloadURL();

    return {
      'original': originalUrl,
      //'thumbnail': thumbnailUrl,
    };
  }

  // Redimensiona la imagen a 100x100 y la convierte en bytes
  Future<Uint8List> _generateThumbnailBytes(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(bytes);
    final thumbnail = img.copyResize(decodedImage!, width: 100, height: 100);
    return Uint8List.fromList(img.encodeJpg(thumbnail));
  } */
}
