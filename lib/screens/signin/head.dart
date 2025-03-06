import 'package:flutter/material.dart';
import 'package:dart_g21/core/colors.dart';
import 'text_styles.dart';
import 'package:flutter/gestures.dart';


class SignInScreen extends StatefulWidget {
  final String title;
  SignInScreen({Key? key, required this.title}): super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(maxWidth: 480),
          margin: EdgeInsets.symmetric(horizontal: 20.0), //ACA HABIA UN AUTO
          padding: EdgeInsets.fromLTRB(24, 9, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildStatusBar(),
              SizedBox(height: 53),
              _buildLogo(),
              SizedBox(height: 14),
              Text('GrowHub', style: AppTextStyles.appNameStyle),
              SizedBox(height: 17),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text('Sign in', style: AppTextStyles.titleStyle),
                ),
              ),
              SizedBox(height: 34),
              _buildEmailField(),
              SizedBox(height: 50),
              _buildPasswordSection(),
              SizedBox(height: 10),
              _buildRememberMeAndForgotPassword(), // Agrega esta línea aquí
              SizedBox(height: 31),
              _buildSignInButton(),
              SizedBox(height: 31),
              Text('OR', style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16,
                letterSpacing: 0.5,
              )),
              SizedBox(height: 30),
              _buildSocialLoginButtons(),
              SizedBox(height: 40),
              _buildSignUpText(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('9:30', style: AppTextStyles.timeStyle),
      ],
    );
  }

  Widget _buildLogo() {
  return Image.asset(
    'lib/assets/logosignin.png',
    width: 128,
    height: 128,
    fit: BoxFit.contain,
    semanticLabel: "Logo de la aplicación",
  );
}


  Widget _buildEmailField() {
    return Container(
      constraints: BoxConstraints(maxWidth: 354), // Ajusta el ancho máximo del campo
      padding: EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/assets/field.png'), // Usa la imagen como fondo del campo
          fit: BoxFit.cover, // Asegura que la imagen cubra todo el contenedor
        ),
        borderRadius: BorderRadius.circular(10), // Bordes redondeados si la imagen lo permite
      ),
      child: TextField(
        keyboardType: TextInputType.emailAddress, // Tipo de teclado para emails
        style: AppTextStyles.inputStyle, // Usa tu estilo definido
        decoration: InputDecoration(
          border: InputBorder.none, // Elimina la línea por defecto
          prefixIcon: Padding(
            padding: EdgeInsets.all(10), // Espaciado del ícono
            child: Image.asset('lib/assets/email.png', width: 24, height: 24), // Ícono de email
          ),
          hintText: 'Enter your email', // Texto de ayuda dentro del campo
          hintStyle: TextStyle(color: Colors.grey), // Color del hint text
        ),
      ),
    );
  }

bool _obscureText = true; // Controla si la contraseña es visible o no

Widget _buildPasswordSection() {
  return Container(
    constraints: BoxConstraints(maxWidth: 354), // Ajusta el ancho máximo del campo
    padding: EdgeInsets.symmetric(horizontal: 30),
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('lib/assets/field.png'), // Usa la imagen como fondo del campo
        fit: BoxFit.cover,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextField(
      obscureText: _obscureText, // Oculta o muestra la contraseña
      keyboardType: TextInputType.visiblePassword,
      style: AppTextStyles.inputStyle,
      decoration: InputDecoration(
        border: InputBorder.none, // Elimina el borde por defecto
        prefixIcon: Padding(
          padding: EdgeInsets.all(10),
          child: Image.asset('lib/assets/password.png', width: 24, height: 24), // Ícono de candado
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            // Cambia el estado de la visibilidad de la contraseña
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Image.asset(
              _obscureText ? 'lib/assets/visibility.png' : 'lib/assets/visibility_off.png',
              width: 24,
              height: 24,
            ),
          ),
        ),
        hintText: 'Enter your password',
        hintStyle: TextStyle(color: Colors.grey),
      ),
    ),
  );
}

Widget _buildRememberMeAndForgotPassword() {
  return Container(
    constraints: BoxConstraints(maxWidth: 354), // Mantiene alineado con el campo de contraseña
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Checkbox de "Remember Me"
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (bool? newValue) {
                setState(() {
                  _rememberMe = newValue!;
                });
              },
              activeColor: AppColors.secondary, // Color del checkbox cuando está activado
            ),
            Text(
              'Remember Me',
              style: AppTextStyles.inputStyle.copyWith(color: Colors.grey),
            ),
          ],
        ),
        // Texto "Forgot Password?" clickeable
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/forgot-password'); // Aquí debes definir la ruta
          },
          child: Text(
            'Forgot Password?',
            style: AppTextStyles.inputStyle.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSignInButton() {
  return Container(
    constraints: BoxConstraints(
      maxWidth: 354,
      maxHeight: 60,
    ),
    child: ElevatedButton(
      onPressed: () {
        // Aquí puedes agregar la lógica de navegación o autenticación
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Centra los elementos dentro del Row
        children: [
          Expanded(
            child: Text(
              'SIGN IN',
              textAlign: TextAlign.center, // Asegura que el texto esté centrado
              style: AppTextStyles.buttonTextStyle,
            ),
          ),
          Image.asset(
            'lib/assets/arrow.png',
            width: 30,
            height: 30,
          ), // Flecha alineada a la derecha
        ],
      ),
    ),
  );
}

Widget _buildSocialLoginButtons() {
  return Column(
    children: [
      // Botón de Google
      Container(
        constraints: BoxConstraints(maxWidth: 354),
        child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.icons),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/google.png', // Logo de Google
                width: 24,
                height: 24,
              ),
              SizedBox(width: 12), // Espacio entre el logo y el texto
              Text(
                'Login with Google',
                style: AppTextStyles.socialLoginStyle,
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: 20),

      // Botón de Facebook
      Container(
        constraints: BoxConstraints(maxWidth: 354),
        child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.icons),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/facebook.png', // Logo de Facebook
                width: 24,
                height: 24,
              ),
              SizedBox(width: 12), // Espacio entre el logo y el texto
              Text(
                'Login with Facebook',
                style: AppTextStyles.socialLoginStyle,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _buildSignUpText(BuildContext context) {
  return RichText(
    text: TextSpan(
      style: AppTextStyles.footerStyle,
      children: [
        TextSpan(text: 'Don’t have an account? '),
        TextSpan(
          text: 'Sign Up',
          style: AppTextStyles.footerStyle.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold, // Hace que se vea más resaltado
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              // Aquí puedes conectar con la vista de Sign Up
              Navigator.pushNamed(context, '/signup'); 
            },
        ),
      ],
    ),
  );
}}