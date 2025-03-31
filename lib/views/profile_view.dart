import 'package:dart_g21/controllers/interest_controller.dart';
import 'package:dart_g21/controllers/profile_controller.dart';
import 'package:dart_g21/controllers/user_controller.dart';
import 'package:dart_g21/core/colors.dart';
import 'package:dart_g21/models/interest.dart';
import 'package:dart_g21/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:dart_g21/widgets/navigation_bar_host.dart';

class ProfilePage extends StatefulWidget {
  final String userId;


  ProfilePage({Key? key, required this.userId,}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}
 
class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _profileController = ProfileController();
  final InterestController _interestController = InterestController();
  final UserController _userController = UserController();
  final double coverHeight = 200;
  final double profileHeight = 180;
  int selectedIndex = 4; // Índice del ícono seleccionado (Profile)

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
          child: Row(
            children: const [
              Text(
                "Profile",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<Profile?>(
            stream: _profileController.getProfileByUserId(widget.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text("No se encontró el perfil"));
              }

              Profile profile = snapshot.data!;
              return ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  buildTop(profile),
                  buildContent(profile),
                ],
              );
            },
          ),
        ),
      ],
    );
  }



  Widget buildTop(Profile profile) {
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
                child:buildProfileImage(profile),
          )],
          );
  }  

// Widget para la imagen de portada
  Widget buildCoverImage() {
    return Container(
      color: AppColors.secondaryText,
    );
  }

// Widget para la imagen de perfil
  Widget buildProfileImage(Profile profile) {
    return CircleAvatar( 
      radius: profileHeight/2,
      backgroundColor: Colors.grey.shade800,
      backgroundImage: NetworkImage(
        //'https://b2472105.smushcdn.com/2472105/wp-content/uploads/2023/09/Poses-Perfil-Profesional-Mujeres-ago.-10-2023-1-819x1024.jpg?lossy=1&strip=1&webp=1',
        profile.picture,
      ),
    );
  }


 

// Widget para el contenido del perfil
  Widget buildContent(Profile profile) {
    List<Color> colors = [AppColors.buttonPurple, AppColors.buttonRed, AppColors.buttonOrange, AppColors.secondary, AppColors.buttonGreen, AppColors.buttonLightBlue];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),

          //Nombre y Profesión
          FutureBuilder(
            future: _userController.getUserById(profile.user_ref),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data!.name,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  );
                } else {
                  return Text('User not found');
                }
              }
              return Text('Loading...');
            },
          ),
          Text(
            //'Flutter Software Engineer',
            profile.headline,
            style: TextStyle(
              fontSize: 22,
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
                    profile.followers.length.toString(),
                   // '350',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Following',
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                  ),
                ],
              ),
              SizedBox(width: 40),
              Column(
                children: [
                  Text(
                    profile.following.length.toString(),
                    //'346',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Followers',
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 20),

          // Botón Edit Profile
          // ElevatedButton.icon(
          //   onPressed: () {},
          //   icon: Icon(Icons.edit, color: AppColors.secondary),
          //   label: Text(
          //     "Edit Profile",
          //     style: TextStyle(color: AppColors.secondary, fontSize: 14),
          //   ),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: AppColors.primary,
          //     side: BorderSide(color: AppColors.secondary),
          //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          //   ),
          // ),

          SizedBox(height: 20),

          //Sección "About Me"
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'About Me...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            profile.description ?? 'No description available',
            //'Enjoy your favorite dish and a lovely time with friends and family. Food from local food trucks will be available for purchase. ',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
            textAlign: TextAlign.justify,
          ),
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: TextButton(
          //     onPressed: () {},
          //     child: Text(
          //       "Read More...",
          //       style: TextStyle(color: AppColors.secondary, fontSize: 14),
          //     ),
          //   ),
          // ),

          SizedBox(height: 20),

          // Sección "Interest"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Interest',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // TextButton.icon(
              //   onPressed: () {},
              //   icon: Icon(Icons.edit, size: 16, color: AppColors.secondary),
              //   label: Text("Change", style: TextStyle(color: AppColors.secondary,fontSize: 16)),
              // ),
            ],
          ),
          SizedBox(height: 20),
          // Chips de intereses
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [

              for (var interest in profile.interests)
                FutureBuilder(
                  future: _interestController.getInterestById(interest),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return buildInterestChip(snapshot.data!.name, colors[interest.hashCode % colors.length]);
                      } else {
                        return Text('Interest not found');
                      }
                    }
                    return Text('Loading...');
                  },
                ),
              // buildInterestChip('Programming', AppColors.buttonPurple),
              // buildInterestChip('Concert', AppColors.buttonRed),
              // buildInterestChip('Music', AppColors.buttonOrange),
              // buildInterestChip('Art', AppColors.secondary),
              // buildInterestChip('Movie', AppColors.buttonGreen),
              // buildInterestChip('Others', AppColors.buttonLightBlue),
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
      label: Text(label, style: TextStyle(color: AppColors.primary, fontSize: 14)),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

 
}