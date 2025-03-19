import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
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
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
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
        return;
      }

      //validar el email
      if (!isValidEmail(email)) return;

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
        return;
      }

      //intentar crear el usuario en FirebaseAuth
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //mostrar mensaje de éxito
      Fluttertoast.showToast(
        msg: "Account created successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0,
      );

    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
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
    }
  }

  //función para iniciar sesión 
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      //verificar si los campos están vacíos
      if (email.isEmpty || password.isEmpty) {
        Fluttertoast.showToast(
          msg: "All fields are required.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return;
      }

      //validar el email
      if (!isValidEmail(email)) return;

      //intentar iniciar sesión con FirebaseAuth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      //mensaje cuando se inicia sesión correctamente
      Fluttertoast.showToast(
        msg: "Login successful!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0,
      );

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

      //msstrar error específico con Fluttertoast
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }
}