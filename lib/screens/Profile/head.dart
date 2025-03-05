import 'package:dart_g21/core/colors.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String title;

  ProfilePage({Key? key, required this.title}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}
 
class _ProfilePageState extends State<ProfilePage> {
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
            Text("Profile", style: TextStyle(color: Colors.black)),
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
      bottomNavigationBar: buildBottomNavigationBar(),
        );
      }

  Widget buildBottomNavigationBar() {
        return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        setState(() {
          selectedIndex = index;
        });
      },
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 35),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map, size:35),
          label: "Map",
        ),
        BottomNavigationBarItem(
        icon: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
        child: Icon(Icons.add, size: 25, color: Colors.white),
          ),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event, size: 35),
          label: "My events",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: 35),
          label: "Profile",
        ),
      ],
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
      color: Colors.grey,
      // child: Image.network(
      //   'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRa9Qk9n8S50ofIrPoQA3m3r9UAqOJ-9t4mMQ&s',
      //   width: double.infinity,
      //   height:coverHeight,
      //   fit: BoxFit.cover,
      //),
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
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Flutter Software Engineer',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
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
                    style: TextStyle(color: Colors.grey),
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
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 20),

          // Botón Edit Profile
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.edit, color: Colors.blue),
            label: Text(
              "Edit Profile",
              style: TextStyle(color: Colors.blue),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.blue),
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
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Enjoy your favorite dish and a lovely time with friends and family. Food from local food trucks will be available for purchase. ',
            style: TextStyle(fontSize: 16, color: Colors.black),
            textAlign: TextAlign.justify,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {},
              child: Text(
                "Read More...",
                style: TextStyle(color: Colors.blue),
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
                icon: Icon(Icons.edit, size: 16, color: Colors.blue),
                label: Text("Change", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Chips de intereses
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              buildInterestChip('Programming', Colors.purple),
              buildInterestChip('Concert', Colors.red),
              buildInterestChip('Music', Colors.orange),
              buildInterestChip('Art', Colors.blue),
              buildInterestChip('Movie', Colors.green),
              buildInterestChip('Others', Colors.cyan),
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
      label: Text(label, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

 
}

