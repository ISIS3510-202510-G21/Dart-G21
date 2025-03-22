import 'package:flutter/material.dart';
import 'package:dart_g21/views/signup_view.dart';
import 'package:dart_g21/views/signin_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firestore_service.dart';

//import 'package:dart_g21/screens/home/head.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /* testFirestoreWrite(); //Prueba escribir en Firestore
  testFirestoreRead();  //

  // prueba creando un evento de prueba
  createEvent(
    "Conferencia de Flutter",
    "Evento sobre desarrollo en Flutter",
    "Tecnología",
    0,
    "2025-04-01T10:00:00",
    "2025-04-01T12:00:00",
    "https://url_imagen.com",
    "Calle 123",
    "loc123",
    "user123",
  ); */

  runApp(MaterialApp(


    debugShowCheckedModeBanner: false,
    initialRoute: '/signin', // La app inicia en la pantalla de Sign In
    routes: {
      //'/signin': (context) => SignInScreen(),  // Pantalla de inicio de sesión
      //'/signup': (context) => SignUpScreen(),  // Pantalla de registro
      //'/home': (context) => HomeScreen(),      // Pantalla principal (Home)
    },
  ));

  /* initialRoute: '/',
    routes: {
      '/': (context) => SignUpScreen(),
      '/profile': (context) => SignUpScreen(),
    },
  )); */
}

//Revisarrrrrrrrrrrrr
/* void testFirestoreWrite() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print("No hay usuario autenticado, no se puede escribir en Firestore.");
    return;
  }

  try {
    await firestore.collection("events").add({
      "name": "Evento de Prueba",
      "description": "Este es un evento de prueba desde Flutter.",
      "timestamp": FieldValue.serverTimestamp(),
      "host_id": user.uid, // Ahora usa el usuario autenticado
    });

    print("Datos escritos correctamente en Firestore.");
  } catch (e) {
    print("Error al escribir en Firestore: $e");
  }
}

void testFirestoreRead() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    var snapshot = await firestore.collection("events").get();
    for (var doc in snapshot.docs) {
      print("Documento leído: ${doc.data()}");
    }
  } catch (e) {
    print("Error al leer Firestore: $e");
  }
} */


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