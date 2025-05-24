import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/storage_service.dart'; 
import '../services/auth_service.dart';
import '../controllers/user_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/user.dart';
import '../models/profile.dart';
import '../models/signup_draft.dart'; // Ensure this file contains the SignUpDraft class definition
import 'package:dart_g21/repositories/localStorage_repository.dart';
import 'dart:io';

class AuthController {
  final AuthService _authService = AuthService();
  final UserController _userController = UserController();
  final ProfileController _profileController = ProfileController();

  //method para registrar usuario y guardar en Firestore
  Future<void> signUp(
    String email, 
    String name, 
    String password, 
    String confirmPassword, 
    String userType,
    String headline,
    String description,
    String profileImagePath,
    ) async {
    try {
      print("Iniciando autenticación...");

      //Registrar usuario en Firebase Authentication y obtener UID
      final String? id_user = await _authService.signUp(
        name,              
        email,             
        password,          
        confirmPassword,   
        userType,          
      );
      
      if (id_user != null) {
        print("Usuario autenticado con UID: $id_user");
        //Crear usuario en la colección "users"
        User newUser = User(id: id_user, name: name, email: email, userType: userType, recommendedEvents: []);
        await _userController.addUser(newUser);
        print("Usuario guardado en `users` en Firestore");
       
        User? user = await _userController.getUserByEmail(email).first;
        String? user_id = user?.id;

        // SUBIR IMAGEN Y THUMBNAIL SI HAY IMAGEN
        String profilePicUrl = '';
        //String? thumbnailUrl;
        if (profileImagePath.isNotEmpty) {
          final File imageFile = File(profileImagePath);
          final storageService = StorageService();
          try {
              final url = await storageService.uploadProfileImage(id_user, imageFile);
              profilePicUrl = url;
            } catch (e) {
              print("Error uploading image: $e");
              profilePicUrl = ''; // fallback para evitar que rompa
            }
          //thumbnailUrl = urls['thumbnail'];
        } 

        //Crear perfil en la colección "profiles"
        Profile newProfile = Profile(
          id: id_user,
          picture: profilePicUrl,
          //thumbnail: thumbnailUrl,
          headline: headline,
          description: description,
          events_associated: [],
          user_ref: user_id!,
          followers: [],
          following: [],
          interests: [],
        );

        await _profileController.addProfile(newProfile);
        print("Perfil guardado en `profiles` en Firestore");

      } else {
        throw Exception("Error en la autenticación con Firebase");
      }
    } catch (e) {
      
      throw Exception("Error en el registro del usuario");
    }
  }

  //Método para salir de la sesión
  Future<void> signOut() async {
    await _authService.signOut();
  }

 // Guarda los datos del último usuario logueado localmente (en Hive)
  Future<void> saveUserLocally(String userId, String email, String name) async {
    final localStorage = LocalStorageRepository();
    await localStorage.saveLastLoggedInUser(userId: userId, email: email, name: name);
  }

  // Recupera el último usuario logueado desde Hive
  Future<Map<String, String>?> getLastLoggedInUser() async {
    final localStorage = LocalStorageRepository();
    return await localStorage.getLastLoggedInUser();
  }

  Future<void> saveSignUpDraftLocally(SignUpDraft draft) async {
    final localStorage = LocalStorageRepository();
    await localStorage.saveSignUpDraft(draft);
  }

  Future<SignUpDraft?> getSignUpDraftLocally() async {
    final localStorage = LocalStorageRepository();
    return await localStorage.getSignUpDraft();
  }

  Future<void> deleteSignUpDraftLocally() async {
    final localStorage = LocalStorageRepository();
    await localStorage.deleteSignUpDraft();
  }

}
