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

      //Registrar usuario en Firebase Authentication y obtener UID
      String? userId = await _authService.signUp(
        name,              
        email,             
        password,          
        confirmPassword,   
        userType,          
      );

      if (userId != null) {
        //Crear usuario en la colección "users"
        User newUser = User(id: userId, name: name, email: email, userType: userType);
        await _userController.addUser(newUser);
       
        //Crear perfil en la colección "profiles"
        Profile newProfile = Profile(
          id: userId,
          picture: "",
          headline: "",
          description: "",
          events_associated: [],
          user_ref: userId,
          followers: [],
          following: [],
          interests: [],
        );
        
        await _profileController.addProfile(newProfile);
        
      } else {
        throw Exception("Error en la autenticación con Firebase");
      }
    } catch (e) {
      
      throw Exception("Error en el registro del usuario");
    }
  }
}
