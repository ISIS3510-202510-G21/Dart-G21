
import 'package:dart_g21/repositories/localStorage_repository.dart';
import 'package:dart_g21/views/categoriesfilter_view.dart';
import 'package:dart_g21/views/eventdetail_view.dart';
import 'package:dart_g21/views/chatbot_view.dart';
import 'package:dart_g21/views/createevents_view.dart';
import 'package:dart_g21/views/map_view.dart';
import 'package:dart_g21/views/myevents_view.dart';
import 'package:dart_g21/views/profile_view.dart';
import 'package:dart_g21/views/searchevent_view.dart';
import 'package:dart_g21/views/selectcategories_view.dart';
import 'package:flutter/material.dart';
import 'package:dart_g21/views/signup_view.dart';
import 'package:dart_g21/views/signin_view.dart';
import 'package:dart_g21/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dart_g21/views/splash_view.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, // opcional: también permite girar el celular boca abajo
  ]);
 final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  //await Hive.initFlutter();
  await Hive.openBox('profileBox');


  await LocalStorageRepository().init();

  runApp(MaterialApp(


    debugShowCheckedModeBanner: false,
    initialRoute: '/splash', // La app inicia en la pantalla de Sign In
    routes: {
      '/signin': (context) => SignInScreen(),  // Pantalla de inicio de sesión
      '/signup': (context) => SignUpScreen(),  // Pantalla de registro
      '/splash': (context) => const SplashScreen(),
      '/home': (context) {
      final args = ModalRoute.of(context)!.settings.arguments as String;
      return HomePage(userId: args);
      },      // Pantalla principal (Home)
      '/profile': (context){
      final args = ModalRoute.of(context)!.settings.arguments as String;
      return ProfilePage(userId: args);
      },  // Pantalla de perfil
      '/myEvents': (context) {
      final args = ModalRoute.of(context)!.settings.arguments as String;
      return MyEventsPage(userId: args);
      },  // Pantalla de eventos
      '/chatBot': (context) => ChatBotPage(title:"ChatBot"),  // Pantalla de chatbot
      '/mapa': (context) => MapView(),  // Pantalla de mapa
      '/createEvent': (context) {
      final args = ModalRoute.of(context)!.settings.arguments as String;
      return CreateEventScreen(userId: args);
      },  // Pantalla de creación de evento
      '/searchEvents': (context) => SearchEventView(),  // Pantalla de búsqueda de eventos
      '/filterCategory': (context) {
      final args = ModalRoute.of(context)!.settings.arguments as String;
      return CategoriesFilter(categoryId: args);
      },  // Pantalla de filtro por categoría
      'selectCategories': (context)  {
      final args = ModalRoute.of(context)!.settings.arguments as String;
      return SelectCategoriesScreen(userId: args);
      },
      '/eventDetail': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
        return EventDetailScreen(
          eventId: args['eventId']!,
          userId: args['userId']!,
        );
      },  // Pantalla de detalles del evento,
    },
  ));

  /* initialRoute: '/',
    routes: 
      '/': (context) => SignUpScreen(),
      '/profile': (context) => SignUpScreen(),
    },
  )); */

}



class AppInitializer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()), //  Muestra un loader mientras Firebase carga
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text("Error al cargar Firebase: ${snapshot.error}")),
            ),
          );
        } else {
          return MaterialApp(
            initialRoute: '/',
            routes: {
              '/': (context) => SignUpScreen(), //  Mantenemos la pantalla inicial que ya te funcionaba
              '/profile': (context) => SignUpScreen(),
            },
          );
        }
      },
    );
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}