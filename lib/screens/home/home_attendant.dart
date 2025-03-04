import 'package:dart_g21/core/colors.dart';
import 'package:dart_g21/screens/home/head.dart';
import 'package:dart_g21/widgets/navigation_bar_host.dart';
import 'package:flutter/material.dart';
import '../../widgets/navigation_bar_attendant.dart';

class HomeAttendant extends StatefulWidget {
  @override
  _HomeAttendantState createState() => _HomeAttendantState();
}

class _HomeAttendantState extends State<HomeAttendant> {
  int _selectedIndex = 0; // Estado para el índice seleccionado

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Actualiza el índice cuando se toca un botón
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column( // ✅ Usa Column para tener múltiples widgets
        children: [
          HeadHome(location: 'Bogota, Colombia'), // 🔹 Se mantiene el Header
          Expanded( // 🔹 Evita que el contenido empuje el header
            child: Center(
              child: Text("Pantalla $_selectedIndex"), // ✅ Ahora está dentro de un `Column`
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBarHost(
        selectedIndex: _selectedIndex, // Pasa el índice actual
        onItemTapped: _onItemTapped, // Pasa la función para manejar el tap
      ),
    );
  }
}
