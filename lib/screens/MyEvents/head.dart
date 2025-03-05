import 'package:dart_g21/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:dart_g21/widgets/navigation_bar_host.dart';

class MyEventsPage extends StatefulWidget {
  final String title;

  MyEventsPage({Key? key, required this.title}) : super(key: key);

  @override
  _MyEventsPageState createState() => _MyEventsPageState();
}
 
class _MyEventsPageState extends State<MyEventsPage> {
  final double coverHeight = 200;
  final double profileHeight = 180;
  int selectedIndex = 4; // Índice del ícono seleccionado (Profile)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            BackButton(),
            Text("My Events", style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          buildTop(),
          buildContent(),
        ],
     
      ),
      //bottomNavigationBar: buildBottomNavigationBar(),
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

  

 Widget buildTop() {
   final bottom = 200.0;
   final top = 20.0;
   return Stack (
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children:[
              Container(margin: EdgeInsets.only(bottom: bottom),
              child:buildCoverImage() ),
              Positioned(
                top: top,
                child:buildProfileImage(),
          )],
          );
  }  

// Widget para la imagen de portada
  Widget buildCoverImage() {
    return Container(
      color: AppColors.primary,
    );
  }

// Widget para la imagen de perfil
  Widget buildProfileImage(){
    return CircleAvatar( 
      radius: profileHeight/2,
      backgroundColor: Colors.grey.shade800,
      backgroundImage: NetworkImage(
        'https://b2472105.smushcdn.com/2472105/wp-content/uploads/2023/09/Poses-Perfil-Profesional-Mujeres-ago.-10-2023-1-819x1024.jpg?lossy=1&strip=1&webp=1',
      ),
    );
  }


 

// Widget para el contenido del perfil
  Widget buildContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),

          //Nombre y Profesión
          Text(
            'James Summer',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Flutter Software Engineer',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16),

          //Seguidores y Seguidos
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    '350',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Following',
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                ],
              ),
              SizedBox(width: 40),
              Column(
                children: [
                  Text(
                    '346',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Followers',
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 20),

          // Botón Edit Profile
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.edit, color: AppColors.secondary),
            label: Text(
              "Edit Profile",
              style: TextStyle(color: AppColors.secondary),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.secondary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          SizedBox(height: 20),

          //Sección "About Me"
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'About Me...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Enjoy your favorite dish and a lovely time with friends and family. Food from local food trucks will be available for purchase. ',
            style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
            textAlign: TextAlign.justify,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {},
              child: Text(
                "Read More...",
                style: TextStyle(color: AppColors.secondary),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Sección "Interest"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Interest',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.edit, size: 16, color: AppColors.secondary),
                label: Text("Change", style: TextStyle(color: AppColors.secondary)),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Chips de intereses
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              buildInterestChip('Programming', AppColors.buttonPurple),
              buildInterestChip('Concert', AppColors.buttonRed),
              buildInterestChip('Music', AppColors.buttonOrange),
              buildInterestChip('Art', AppColors.secondary),
              buildInterestChip('Movie', AppColors.buttonGreen),
              buildInterestChip('Others', AppColors.buttonLightBlue),
            ],
          ),

          SizedBox(height: 40), // Espaciado final
        ],
      ),
    );
  }


  // Widget para cada chip de intereses
  Widget buildInterestChip(String label, Color color) {
    return Chip(
      label: Text(label, style: TextStyle(color: AppColors.primary)),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

 
}

