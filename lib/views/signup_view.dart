import 'package:flutter/material.dart';
import 'package:dart_g21/core/colors.dart';
import 'package:dart_g21/services/auth_service.dart';

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
  
  String? selectedUserType;
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
        _buildInputField(_nameController, 'Full name', Icons.person),
        const SizedBox(height: 23),
        _buildInputField(_emailController, 'abc@email.com', Icons.email),
        const SizedBox(height: 23),
        _buildUserTypeDropdown(),
        const SizedBox(height: 23),
        _buildPasswordField(_passwordController, 'Your password', _isPasswordVisible, (value) {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        }),
        const SizedBox(height: 23),
        _buildPasswordField(_confirmPasswordController, 'Confirm password', _isConfirmPasswordVisible, (value) {
          setState(() {
            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
          });
        }),
      ],
    );
  }

  Widget _buildInputField(TextEditingController controller, String hintText, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFFE6E6E6)),
        hintText: hintText,
        border: _buildInputBorder(),
        enabledBorder: _buildInputBorder(),
        focusedBorder: _buildInputBorder(),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hintText, bool isVisible, Function(bool) onToggle) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: Color(0xFFE6E6E6)),
        hintText: hintText,
        border: _buildInputBorder(),
        enabledBorder: _buildInputBorder(),
        focusedBorder: _buildInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Color(0xFFE6E6E6)),
          onPressed: () => onToggle(isVisible),
        ),
      ),
    );
  }

  Widget _buildUserTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFE6E6E6)),
        border: _buildInputBorder(),
        enabledBorder: _buildInputBorder(),
        focusedBorder: _buildInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      value: selectedUserType,
      hint: const Text("Select user type"),
      items: ["Host", "Attendee"].map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedUserType = newValue!;
        });
      },
    );
  }

  OutlineInputBorder _buildInputBorder() {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)), 
      borderSide: BorderSide(color: Color(0xFFE6E6E6), width: 2), 
    );
  }

  Widget _buildSignUpButton() {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: () async {
        //signUp con validaciones
        await AuthService().signUp(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );
        //Navigator.pushNamed(context, '/home'); // HABILITARLOOO PARA ir a Home después de registrarse
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
          const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
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
          Navigator.pushNamed(context, '/signin'); // HABILITARLO DESPUES PARA Ir a Sign In
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
