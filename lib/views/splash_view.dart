import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
  super.initState();
  _checkLoginStatus();
}

Future<void> _checkLoginStatus() async {
  await Future.delayed(const Duration(seconds: 1));
  final userId = await LocalStorageService.getUserId();

  if (userId != null && userId.isNotEmpty) {
    final completed = await LocalStorageService.hasCompletedCategories(userId);
    if (completed) {
      Navigator.pushReplacementNamed(context, '/home', arguments: userId);
    } else {
      await LocalStorageService.setPendingCategoryNotice(true);
      Navigator.pushReplacementNamed(context, '/selectCategories', arguments: userId);
    }
  } else {
    Navigator.pushReplacementNamed(context, '/signin');
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "GrowHub",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Image.asset('lib/assets/logosignin.png', height: 120), 
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
