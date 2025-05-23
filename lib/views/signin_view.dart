import 'package:dart_g21/controllers/user_controller.dart';
import 'package:dart_g21/controllers/auth_controller.dart';
import 'package:dart_g21/models/user.dart';
import 'package:dart_g21/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:dart_g21/core/colors.dart';
import 'package:dart_g21/services/auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dart_g21/services/local_storage_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';


class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _dialogShown = false;
  final _userController = UserController(); 
  final authController = AuthController();

  bool isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late final Connectivity _connectivity;

  @override
  void initState() {
    super.initState();
     setUpConnectivity(); // comienza a escuchar cambios en red
     _checkInitialConnectivity(); // verifica la conectividad inicial
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForSavedUser(); // ahora es seguro mostrar banners
      }); 
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
      if (prev && !currentlyConnected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForSavedUser();
    
    });
      };
      
      

    });
  }

   Future<void> _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {isConnected = !result.contains(ConnectivityResult.none);
   
    });
    if (!isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForSavedUser();
      });
    }

  }



void _checkForSavedUser() async {
  if (!isConnected && !_dialogShown) {
    final savedUser = await authController.getLastLoggedInUser();
    if (savedUser != null && mounted) {
      setState(() {
      _dialogShown = true;
    });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline, size: 48, color: Colors.blueAccent),
                  const SizedBox(height: 16),
                  Text(
                    "Offline Login Detected",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Do you want to continue as ${savedUser['name']}?",
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Connect to the internet to log in with another user."),
                            ),
                          );
                        },
                        child: const Text("Other user"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HomePage(userId: savedUser['userId']!),
                            ),
                          );
                        },
                        child: const Text("Yes, continue", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
    _connectivitySubscription.cancel();
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
                  _buildLogo(),
                  const SizedBox(height: 30),
                  _buildTitle(),
                  const SizedBox(height: 40),
                  _buildFormFields(),
                  const SizedBox(height: 10),
                  _buildRememberMe(),
                  const SizedBox(height: 30),
                  _buildSignInButton(),
                  const SizedBox(height: 38),
                  _buildDivider(),
                  const SizedBox(height: 30),
                  _buildSignUpText(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        'lib/assets/logosignin.png', 
        width: 128,
        height: 128,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.only(left: 14),
      child: Text(
        'Sign In',
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
        _buildInputField(_emailController, 'Enter your email', Icons.email),
        const SizedBox(height: 23),
        _buildPasswordField(_passwordController, 'Enter your password', _isPasswordVisible, (value) {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
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
        hintStyle: const TextStyle(color: Color(0xFF8D8D8D)),
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
        hintStyle: const TextStyle(color: Color(0xFF8D8D8D)), 
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

  Widget _buildRememberMe() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (bool? newValue) {
            setState(() {
              _rememberMe = newValue!;
            });
          },
          activeColor: AppColors.secondary,
        ),
        const Text(
          'Remember Me',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: () async {
         bool loginSuccess = await AuthService().signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
           );

        if (loginSuccess) {
            User? user = await _userController.getUserByEmail(_emailController.text).first;
            String? user_id = user?.id;

        if (user_id != null && user != null) {
          //Guardar en local storage para mantener sesión
            await LocalStorageService.saveUserId(user_id);
            print("Guardado en SharedPreferences: $user_id");
          //Guardar en Hive 
            await authController.saveUserLocally(user_id, user.email, user.name);


          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(userId: user_id),
            ),
          );
        } else {
            Fluttertoast.showToast(
            msg: "User not found in database.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14.0,
          );
        }
        }
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
            'SIGN IN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.login, color: Colors.white, size: 20),
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

  Widget _buildSignUpText(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(fontSize: 16, letterSpacing: 0.5, color: Colors.black),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup'); //HABILITARLO PARA IR A SIGN UP
          },
          child: const Text(
            'Sign Up',
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

  OutlineInputBorder _buildInputBorder() {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)), 
      borderSide: BorderSide(color: Color(0xFFE6E6E6), width: 2),
    );
  }
}