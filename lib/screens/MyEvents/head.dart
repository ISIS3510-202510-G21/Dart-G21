import 'package:flutter/material.dart';
import 'package:dart_g21/core/colors.dart';
import 'package:dart_g21/widgets/navigation_bar_host.dart';

class MyEventsPage extends StatefulWidget {
  final String title;

  MyEventsPage({Key? key, required this.title}) : super(key: key);

  @override
  _MyEventsPageState createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  int selectedIndex = 2; // Índice del ícono seleccionado (My Events)

  //  Lista de eventos de ejemplo
  final List<Map<String, String>> upcomingEvents = [
    {
      "date": "Wed, Apr 28 • 5:30 PM",
      "title": "A Virtual Evening of Smooth Jazz",
      "image": "https://st3.depositphotos.com/1297731/14775/i/450/depositphotos_147759535-stock-photo-crowd-at-concert-summer-music.jpg",
      "value": "0" 
    },
    {
      "date": "Wed, Apr 28 • 5:30 PM",
      "title": "A Virtual Evening of Smooth Jazz",
      "image": "https://st3.depositphotos.com/1297731/14775/i/450/depositphotos_147759535-stock-photo-crowd-at-concert-summer-music.jpg",
      "value": "10"
    },
  ];

  final List<Map<String, String>> previousEvents = [
    {
      "date": "Thu, Mar 6 • 1:30 PM",
      "title": "International Gala Music Festival",
      "image": "https://st3.depositphotos.com/1297731/14775/i/450/depositphotos_147759535-stock-photo-crowd-at-concert-summer-music.jpg",
      "value": "0"
    },
    {
      "date": "Wed, Feb 25 • 3:30 PM",
      "title": "Women Leadership Conference",
      "image": "https://st3.depositphotos.com/1297731/14775/i/450/depositphotos_147759535-stock-photo-crowd-at-concert-summer-music.jpg",
      "value": "0"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            BackButton(),
            Text("My Events", style: TextStyle(fontSize: 24, color: AppColors.textPrimary)),
          ],
        ),
      ),

      // Cuerpo con lista de eventos
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          //  Sección de Upcoming Events
          buildSectionTitle("Upcoming Events"),
          ...upcomingEvents.map((event) => buildEventCard(event)).toList(),

          SizedBox(height: 20),

          //  Sección de Previous Events
          buildSectionTitle("Previous Events"),
          ...previousEvents.map((event) => buildEventCard(event)).toList(),
        ],
      ),

      //  Barra de navegación inferior
      bottomNavigationBar: BottomNavBarHost(
        selectedIndex: selectedIndex,
        onItemTapped: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }

  // Widget para los títulos de sección ("Upcoming Events", "Previous Events")
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  //  Widget para cada tarjeta de evento
Widget buildEventCard(Map<String, String> event) {
  return Material(
    color: Colors.transparent, // 
    child: InkWell(
      onTap: () {
        print("Evento seleccionado: ${event['title']}");
      },
      borderRadius: BorderRadius.circular(12), 
      splashColor: Colors.blue.withOpacity(0.2), 
      highlightColor: Colors.blue.withOpacity(0.1), 
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4, 
        child: Padding(
          padding: EdgeInsets.all(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //  Imagen y pago
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        event["image"]!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (event["value"] != "0")
                      Icon(Icons.payments, color: AppColors.textPrimary),
                  ],
                ),

                SizedBox(width: 12),

                //  Detalles del evento alineados arriba
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        event["date"]!,
                        style: TextStyle(fontSize: 12, color: AppColors.secondary),
                      ),
                      SizedBox(height: 15),
                      Text(
                        event["title"]!,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                //  Botones de guardar y eliminar bien alineados
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.flag_outlined, color: AppColors.textPrimary),
                      onPressed: () {},
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: AppColors.textPrimary),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}



}
