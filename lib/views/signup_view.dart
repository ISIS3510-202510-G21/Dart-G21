import 'dart:io';
import 'dart:async';
import 'package:dart_g21/controllers/user_controller.dart';
import 'package:dart_g21/controllers/auth_controller.dart';
import 'package:dart_g21/models/user.dart';
import 'package:dart_g21/models/signup_draft.dart';
import 'package:dart_g21/views/home_view.dart';
import 'package:dart_g21/views/selectcategories_view.dart';
import 'package:flutter/material.dart';
import 'package:dart_g21/core/colors.dart';
import 'package:dart_g21/services/auth_service.dart';
import 'package:dart_g21/services/local_storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthController _authController = AuthController();
  final UserController _userController = UserController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _headlineController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String? _selectedUserType;
  String _profileImagePath = '';

  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery); // o ImageSource.camera
  if (image != null) {
    setState(() {
      _profileImage = image;
    });
  }
}


//para hacer dinamico cuando el usuario este creando su password hy le muestre que falta
  bool hasUpper = false;
  bool hasLower = false;
  bool hasDigit = false;
  bool hasSpecial = false;
  bool hasMinLength = false;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  bool isTrustedEmailProvider(String email) {
    final trustedDomains = ['gmail.com', 'hotmail.com', 'outlook.com', 'yahoo.com', 'uniandes.edu.co'];
    final parts = email.split('@');
    if (parts.length != 2) return false;
    return trustedDomains.contains(parts[1].toLowerCase());
  }

  bool isStrongPassword(String password) {
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return password.length >= 8 && hasUpper && hasLower && hasDigit && hasSpecial;
  }

  void validatePassword(String password) {
    setState(() {
      hasUpper = password.contains(RegExp(r'[A-Z]'));
      hasLower = password.contains(RegExp(r'[a-z]'));
      hasDigit = password.contains(RegExp(r'[0-9]'));
      hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      hasMinLength = password.length >= 8;
    });
  }

  void showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  //nuevo
  String userType = "attendee";

  String? selectedUserType;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late final Connectivity _connectivity;

  @override
  void initState() {
    super.initState();
    setUpConnectivity();
    _checkInitialConnectivity();
    _loadDraftIfAvailable(); 

  }

   void setUpConnectivity() {
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
        List<ConnectivityResult> results) async {
      final prev = isConnected;
      final currentlyConnected = !results.contains(ConnectivityResult.none);
      if (prev != currentlyConnected) {
        setState(() {
          isConnected = currentlyConnected;
        });
      };
      if (!prev && currentlyConnected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDraftIfAvailable();
    
    });
      };
      

    });
  }

   Future<void> _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {isConnected = !result.contains(ConnectivityResult.none);
   
    });
    if (isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadDraftIfAvailable();
      });
    }

  }
 
  void _populateFormFields(SignUpDraft draft) {
      setState(() {
        _emailController.text = draft.email;
        _nameController.text = draft.name;
        _passwordController.text = draft.password;
        _headlineController.text = draft.headline;
        _descriptionController.text = draft.description;
        _selectedUserType = draft.userType;
        _profileImagePath = draft.profileImagePath;
      });
    }

    Future<void> _loadDraftIfAvailable() async {
    final draft = await _authController.getSignUpDraftLocally();
    if (draft != null && mounted) {
      _populateFormFields(draft);

      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: const Text(
            "We've recovered your previous registration. Do you want to continue with that data?",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber.shade100,
          actions: [
            TextButton(
              child: const Text("Discard", style: TextStyle(color: Colors.black)),
              onPressed: () async {
                await _authController.deleteSignUpDraftLocally();
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                _clearFormFields(); // nuevo método
              },
            ),
            TextButton(
              child: const Text("Continue", style: TextStyle(color: Colors.blue)),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
            ),
          ],
        ),
      );
    }
  }

  void _clearFormFields() {
    setState(() {
      _emailController.clear();
      _nameController.clear();
      _passwordController.clear();
      _headlineController.clear();
      _descriptionController.clear();
      _selectedUserType = null;
      _profileImagePath = '';
    });
  }

  void _onFieldChanged() {
    final draft = SignUpDraft(
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
      password: _passwordController.text.trim(),
      userType: _selectedUserType ?? '',
      headline: _headlineController.text.trim(),
      description: _descriptionController.text.trim(),
      profileImagePath: _profileImagePath ?? '',
    );
    _authController.saveSignUpDraftLocally(draft);
  }

/*   Future<void> _loadDraftIfAvailable() async {
    final draft = await _authController.getSignUpDraftLocally();
    if (draft != null && mounted) {
      setState(() {
        _emailController.text = draft.email;
        _nameController.text = draft.name;
        _passwordController.text = draft.password;
        _headlineController.text = draft.headline;
        _descriptionController.text = draft.description;
        _selectedUserType = draft.userType;
        _profileImagePath = draft.profileImagePath;
      });

      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: const Text(
            "We've recovered your previous registration. Do you want to continue with that data?",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber.shade100,
          actions: [
            TextButton(
              child: const Text("Discard", style: TextStyle(color: Colors.black)),
              onPressed: () async {
                await _authController.deleteSignUpDraftLocally();
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                setState(() {
                  _emailController.clear();
                  _nameController.clear();
                  _passwordController.clear();
                  _headlineController.clear();
                  _descriptionController.clear();
                  _selectedUserType = null;
                  _profileImagePath = '';
                });
              },
            ),
            TextButton(
              child: const Text("Continue", style: TextStyle(color: Colors.blue)),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
            ),
          ],
        ),
      );
    }
  }

  Future<void> _saveDraft() async {
    final draft = SignUpDraft(
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
      password: _passwordController.text.trim(),
      userType: _selectedUserType ?? '',
      headline: _headlineController.text.trim(),
      description: _descriptionController.text.trim(),
      profileImagePath: _profileImagePath ?? '',
    );
    await _authController.saveSignUpDraftLocally(draft);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("You're offline. We're saving your registration so you can complete it later.")),
    );
  } */

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _headlineController.dispose(); // nuevo
    _descriptionController.dispose(); // nuevo
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
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _profileImage != null ? FileImage(File(_profileImage!.path)) : null,
                        child: _profileImage == null
                            ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
        const SizedBox(height: 10),
        _passwordCriteria(), // validador visual
        const SizedBox(height: 23),
        _buildPasswordField(_confirmPasswordController, 'Confirm password', _isConfirmPasswordVisible, (value) {
          setState(() {
            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
          });
        }),
        const SizedBox(height: 23),
        _buildInputField(_headlineController, 'Your headline (e.g. Marketing Student)', Icons.title),
        const SizedBox(height: 23),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.description, color: Color(0xFFE6E6E6)),
            hintText: 'Short bio or description...',
            border: _buildInputBorder(),
            enabledBorder: _buildInputBorder(),
            focusedBorder: _buildInputBorder(),
          ),
        ),
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
      onChanged: (value) {
        //Solo activa la validación en el campo "Your password"
        if (hintText == "Your password") {
          validatePassword(value);
        }
      },
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

  Widget _passwordCriteria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCriteriaRow("At least 8 characters", hasMinLength),
        _buildCriteriaRow("One uppercase letter", hasUpper),
        _buildCriteriaRow("One lowercase letter", hasLower),
        _buildCriteriaRow("One number", hasDigit),
        _buildCriteriaRow("One special character (!@#...)", hasSpecial),
      ],
    );
  }

  Widget _buildCriteriaRow(String text, bool condition) {
    return Row(
      children: [
        Icon(
          condition ? Icons.check_circle : Icons.cancel,
          color: condition ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: condition ? Colors.green : Colors.red,
          ),
        ),
      ],
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
  return isConnected
    ? SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: () async {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      //Validaciones de campos vacíos
      if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || selectedUserType == null) {
        showToast("All fields are required.");
        return;
      }

      //Validación de email
      if (!isValidEmail(email)) {
        showToast("That's not a valid email format.");
        return;
      }
      if (!isTrustedEmailProvider(email)) {
        showToast("Please use a trusted email provider (gmail, outlook, etc).");
        return;
      }

      //Validación de contraseña segura
      if (!isStrongPassword(password)) {
        showToast("Password must include uppercase, lowercase, number and special character (min 8 characters).");
        return;
      }

      // ⚠ Confirmación de contraseña
      if (password != confirmPassword) {
        showToast("The passwords do not match.");
        return;
      }

      //  Si todo pasa, continuar con el registro
      await _authController.signUp(
        email,
        name,
        password,
        confirmPassword,
        selectedUserType!,
        _headlineController.text.trim(),
        _descriptionController.text.trim(),
        _profileImage?.path ?? "", //si no hay imagen seleccionada, queda vacío
      );

      // Borrar draft porque ya se registró
      await _authController.deleteSignUpDraftLocally();

      User? user = await _userController.getUserByEmail(email).first;
      String? user_id = user?.id;
      
      await LocalStorageService.saveUserId(user_id!);

      //Cambie esto sprint 3!!!!
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SelectCategoriesScreen(userId: user_id!),
            ),
          );


       
        /* await _authController.signUp(
          _emailController.text,
          _nameController.text,
          _passwordController.text,
          _confirmPasswordController.text,
          selectedUserType ?? "attendee",
        );
      User? user = await _userController.getUserByEmail(_emailController.text.trim()).first;
        String? user_id = user?.id;
        Navigator.push(
        context,
        MaterialPageRoute(

          builder: (context) => HomePage(userId: user_id!),
        ),
      );
 */
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
  ): 
  Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "You cannot complete the registration without an internet connection.",
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
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
