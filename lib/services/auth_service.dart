import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dart_g21/services/local_storage_service.dart';

class AuthService {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //validación de Email
  bool isValidEmail(String email) {
    //revisó si el email tiene doble @ o es inválido
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      Fluttertoast.showToast(
        msg: "That's not a valid email.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false;
    }
    return true;
  }

  //función para el sign up
  Future<String?> signUp(
     String name,
     String email,
     String password,
     String confirmPassword,
     String userType,
  ) async {
    try {

      
      //verificar si los campos están vacíos
      if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        Fluttertoast.showToast(
          msg: "All fields are required.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return null;
      }

      //validar el email
      if (!isValidEmail(email)) return null;

      //verificar si las contraseñas coinciden
      if (password != confirmPassword) {
        Fluttertoast.showToast(
          msg: "The password does not match.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return null;
      }

      print("Intentando registrar usuario en Firebase Authentication...");

/*    guardo el UID del usuario para almacenar datos en firestore
      el UID lo uso para crear los documentos en users/UID y profiles/UID en firestore
 */
      //Crear usuario en Firebase Authentication (NUEVOOO)
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String userId = userCredential.user!.uid; //Obtener UID del usuario
        await LocalStorageService.saveUserId(userId);

      print("Usuario registrado con UID: $userId");


      //mostrar mensaje de éxito
      Fluttertoast.showToast(
        msg: "Account created successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return userId;

    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      } else {
        message = "Error: ${e.message}";
      }

      print("Error en Firebase Authentication: $message");

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return null;
    }
  }

  //función para iniciar sesión 
  Future<bool> signIn({
  required String email,
  required String password,
    }) async {
      try {
        if (email.isEmpty || password.isEmpty) {
          Fluttertoast.showToast(
            msg: "All fields are required.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14.0,
          );
          return false;
        }

        if (!isValidEmail(email)) return false;

        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        //Extraer el UID
        final authUid = userCredential.user?.uid;
        
        //Usar el método del controller para encontrar el `userId`
        if (authUid != null) {
          await LocalStorageService.saveUserId(authUid);
        }

        Fluttertoast.showToast(
          msg: "Login successful!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return true;

      } on FirebaseAuthException catch (e) {
        String message = '';
        if (e.code == 'user-not-found') {
          message = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password provided for that user.';
        } else if (e.code == 'invalid-credential') {
          message = 'The password is incorrect. Please try again.';
        } else {
          message = "Error: ${e.message}";
        }

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return false;
      }
    }

  //Función para cerrar sesión
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

}