import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../controllers/user_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/user.dart';
import '../models/profile.dart';

class AuthController {
  final AuthService _authService = AuthService();
  final UserController _userController = UserController();
  final ProfileController _profileController = ProfileController();

  //method para registrar usuario y guardar en Firestore
  Future<void> signUp(String email, String name, String password, String confirmPassword, String userType) async {
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
        User newUser = User(id: id_user, name: name, email: email, userType: userType);
        await _userController.addUser(newUser);
        print("Usuario guardado en `users` en Firestore");
       
        User? user = await _userController.getUserByEmail(email).first;
        String? user_id = user?.id;

        //Crear perfil en la colección "profiles"
        Profile newProfile = Profile(
          id: id_user,
          picture: "",
          headline: "",
          description: "",
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
}
