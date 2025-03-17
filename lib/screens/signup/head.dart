import 'package:flutter/material.dart';
import 'package:dart_g21/core/colors.dart';
import 'package:dart_g21/widgets/custom_input_field.dart';
import 'package:dart_g21/widgets/social_login_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  print("SignUpScreen cargado"); // Esto nos ayudará a verificar si la pantalla se está ejecutando

  double screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    backgroundColor: AppColors.primary,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth > 500 ? 400 : screenWidth * 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(context),
                const SizedBox(height: 30),
                _buildTitle(),
                const SizedBox(height: 40),
                _buildFormFields(),
                const SizedBox(height: 38),
                _buildSignUpButton(),
                const SizedBox(height: 38),
                _buildDivider(),
                const SizedBox(height: 38),
                _buildSocialLoginButtons(),
                const SizedBox(height: 20),
                _buildSignInText(context),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}



  /* @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Detecta el ancho de la pantalla

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center( // Asegura que el contenido esté centrado
          child: SingleChildScrollView(
            child: Container(
              width: screenWidth > 500 ? 400 : screenWidth * 0.9, // Evita expansión en pantallas grandes
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBackButton(context),
                  const SizedBox(height: 30),
                  _buildTitle(),
                  const SizedBox(height: 40),
                  _buildFormFields(),
                  const SizedBox(height: 38),
                  _buildSignUpButton(),
                  const SizedBox(height: 38),
                  _buildDivider(),
                  const SizedBox(height: 38),
                  _buildSocialLoginButtons(),
                  const SizedBox(height: 20),
                  _buildSignInText(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
 */
  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: const Icon(Icons.arrow_back, size: 24),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.only(left: 14),
      child: Text(
        'Sign Up',
        style: TextStyle(
          fontSize: 28,
          height: 36 / 28,
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        CustomInputField(
          controller: _nameController,
          placeholder: 'Full name',
          iconPath: 'lib/assets/email.png',
        ),
        const SizedBox(height: 23),
        CustomInputField(
          controller: _emailController,
          placeholder: 'abc@email.com',
          iconPath: 'lib/assets/email.png',
        ),
        const SizedBox(height: 23),
        CustomInputField(
          controller: _passwordController,
          placeholder: 'Your password',
          iconPath: 'lib/assets/password.png',
          isPassword: true,
          isPasswordVisible: _isPasswordVisible,
          onToggleVisibility: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        const SizedBox(height: 23),
        CustomInputField(
          controller: _confirmPasswordController,
          placeholder: 'Confirm password',
          iconPath: 'lib/assets/password.png',
          isPassword: true,
          isPasswordVisible: _isConfirmPasswordVisible,
          onToggleVisibility: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () async {
          /* AuthService().SignUpScreen(
            name: _nameController.text, 
            email:_emailController.text, 
            password:_passwordController.text
            ); */
          // ACAAAAA TODO: Implementar la lógica de registro
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'SIGN UP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Center(
      child: Text(
        'OR',
        style: TextStyle(
          color: AppColors.secondaryText,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        SocialLoginButton(
          text: 'Login with Google',
          iconPath: 'lib/assets/google.png',
          onPressed: () {},
        ),
        SocialLoginButton(
          text: 'Login with Facebook',
          iconPath: 'lib/assets/facebook.png',
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSignInText(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(fontSize: 16, letterSpacing: 0.5),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Vuelve a la pantalla anterior (Sign In)
          },
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}


