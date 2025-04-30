import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dart_g21/consts.dart';
import 'package:dart_g21/controllers/category_controller.dart';
import 'package:dart_g21/controllers/event_controller.dart';
import 'package:dart_g21/data/database/app_database.dart';
import 'package:dart_g21/models/category.dart';
import 'package:dart_g21/models/event.dart';
import 'package:dart_g21/repositories/drift_repository.dart';
import 'package:dart_g21/repositories/localStorage_repository.dart';
import 'package:http/http.dart' as http;
import 'package:dart_g21/core/colors.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

const String GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY";

class ChatBotPage extends StatefulWidget {
  final String title;

  ChatBotPage({Key? key, required this.title}) : super(key: key);

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final ChatUser _currentUser = ChatUser(
    id: '1',
    firstName: 'User',
    profileImage: 'https://cdn-icons-png.flaticon.com/512/147/147144.png',
  );

  final ChatUser _gptChatUser = ChatUser(
    id: '2',
    firstName: 'Chat',
    lastName: 'Bot',
    profileImage: 'https://cdn-icons-png.flaticon.com/512/4712/4712038.png',
  );

  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUsers = <ChatUser>[];
  bool isConnected = true;
  bool _offlineMenuShown = false;
  late final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final categoryController = CategoryController();
  final EventController eventController = EventController();

  @override
  void initState() {
    super.initState();
    _setupConnectivity();
    _checkInitialConnectivity();
  }

 void _setupConnectivity() {
  _connectivity = Connectivity();
  _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
    final wasConnected = isConnected;
    setState(() => isConnected = !results.contains(ConnectivityResult.none));

    if (wasConnected && !isConnected && !_offlineMenuShown) {
      _sendOfflineMenuMessage();
      _offlineMenuShown = true;
    }
    if (!wasConnected && isConnected) {
      _sendOnlineMenuMessage();
      _offlineMenuShown = false;
    }
  });
}

  Future<void> _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {isConnected = !result.contains(ConnectivityResult.none);
   
    });

     if (!isConnected && !_offlineMenuShown) {
    _sendOfflineMenuMessage();
    _offlineMenuShown = true;
  }
  if (isConnected) {
    _WelcomeMessage();
    _offlineMenuShown = false;
    }
     
  }
  

  void _sendOfflineMenuMessage() {
  setState(() {
    _messages.insert(0, ChatMessage(
      text: """ Offline Mode Activated

  You can ask me or request:

    - Information about GrowHub
    - View available events
    - Search for events by category""",
      user: _gptChatUser,
      createdAt: DateTime.now(),
    ));
  });
}

void _sendOnlineMenuMessage() {
  setState(() {
    _messages.insert(0, ChatMessage(
      text: """ You are now online! You can ask me anything about GrowHub events and features.""",
      user: _gptChatUser,
      createdAt: DateTime.now(),
    ));
  });
}

void _WelcomeMessage() {
  setState(() {
    _messages.insert(0, ChatMessage(
      text: """ Welcome to GrowHub ChatBot!

I am here to assist you with any questions or information you need about our events and features.
You can ask me about:

    - Information about GrowHub
    - View available events
    - Events by your interests
    - Any other questions you may have""",
      user: _gptChatUser,
      createdAt: DateTime.now(),
    ));
  });
  
}
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        "ChatBot",
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 400),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 400),
              style: TextStyle(
                color: isConnected ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              child: Text(isConnected ? "Online" : "Offline"),
            ),
          ),
        ),
      ],
      
    ),


      body: DashChat(
              currentUser: _currentUser,
              typingUsers: _typingUsers,
              onSend: (ChatMessage m) async {
                if (isConnected) {
                  await getChatResponse(m);
                } else {
                  await handleOfflineInteraction(m);
                }
              },
              messages: _messages,
              inputOptions: InputOptions(
                sendButtonBuilder: (Function onSend) {
                  return IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: () => onSend(),
                  );
                },
              ),
              messageOptions: MessageOptions(
                messageRowBuilder: (ChatMessage message, ChatMessage? previousMessage, ChatMessage? nextMessage, bool isAfter, bool isBefore) {
                  bool isCurrentUser = message.user == _currentUser;
                  return Row(
                    mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 8),
                      if (!isCurrentUser)
                        CachedNetworkImage(
                          imageUrl: message.user.profileImage ?? '',
                          imageBuilder: (context, imageProvider) => CircleAvatar(
                          backgroundImage: imageProvider,
                          radius: 20,
                          ),
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.person_4, size: 40, color: Colors.grey),
                        ),
                      SizedBox(width: 4),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: isCurrentUser ? AppColors.icons : AppColors.secondary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message.text.replaceAll('*', ''),
                            style: TextStyle(fontSize: 16, color: isCurrentUser ? AppColors.textPrimary : AppColors.primary),
                          ),
                        ),
                      ),
                      if (isCurrentUser)
                        CachedNetworkImage(
                          imageUrl: message.user.profileImage ?? '',
                          imageBuilder: (context, imageProvider) => CircleAvatar(
                          backgroundImage: imageProvider,
                          radius: 20,
                          ),
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.person, size: 40, color: Colors.grey),
                        ),
                        
                      SizedBox(width: 10),
                    ],
                  );
                },
              ),
            )
    );
  }

 Future<void> getChatResponse(ChatMessage m) async {
  setState(() {
    _messages.insert(0, m);
    _typingUsers.add(_gptChatUser);
  });

  try {
    final events = await EventController().getFirstNEvents(20); 

    String eventosTexto = "";
    for (var event in events) {
      if(event.start_date.isAfter(DateTime.now())){
        eventosTexto += "- UPCOMING EVENT: ${event.name} (${event.start_date.day}/${event.start_date.month}): Description: ${event.description.substring(0, event.description.length > 100 ? 100 : event.description.length)}, cost: ${event.cost>0? event.cost:"FREE"}...\n";
      }
      else if (event.start_date.isBefore(DateTime.now())){
        eventosTexto += "- PAST EVENT: ${event.name} (${event.start_date.day}/${event.start_date.month}): Description: ${event.description.substring(0, event.description.length > 100 ? 100 : event.description.length)}, cost: ${event.cost}...\n";
      }
      
    }

  
    // 3. Construir el contexto completo
    String contexto = """
    Contexto de GrowHub:
    GrowHub es una aplicación móvil diseñada para conectar estudiantes, profesionales y organizadores con eventos de desarrollo de habilidades.
    Ofrece tanto eventos gratuitos como pagos y permite que organizadores gestionen su visibilidad y audiencia de manera efectiva.

    *Eventos actuales en GrowHub*:
    $eventosTexto


    Tipos de Usuarios:
                  - Organizadores voluntarios: crean eventos gratuitos.
                  - Organizadores pagos: pueden cobrar por la participación.
                  - Asistentes gratuitos: se registran en eventos sin costo.
                  - Asistentes pagos: acceden a eventos premium.

                   Modelo de Monetización:
                  1. Tarifa por Publicación de Eventos:
                     - Publicación básica: \$5 (solo aparece en el catálogo).
                     - Publicación premium: \$15 (más visibilidad y destacada).

                  2. Tarifa por Aumentar Visibilidad:
                     - Estándar: Incluida en la publicación.
                     - Destacada: \$10/semana (más prioridad en búsqueda).
                     - Evento destacado: \$25/semana (portada de la app).
                     - Promoción exclusiva: \$50/semana (notificaciones push y redes sociales).

                  3. Comisión por Venta de Tickets:
                     - 10% en tickets <\$10.
                     - 8% en tickets de \$10 a \$50.
                     - 5% en tickets >\$50.

                   Beneficios para Organizadores:
                  - Creación fácil de eventos con formulario simplificado.
                  - Herramientas de promoción para maximizar la asistencia.
                  - Integración con redes sociales y plataformas universitarias.
                  - Recomendaciones personalizadas para los asistentes.

    Solo responde preguntas sobre eventos, recomendación de eventos, categorías de eventos, organizadores, costos, visibilidad de eventos y fechas de eventos. No hables de cómo registrarse ni de políticas de privacidad. También puedes hablar sobre la monetización de eventos y los tipos de usuarios. Tambien puedes hablar de cualquier tema relacionado como si los usuarios tienen dudas de conceptos o quieren aprender algo nuevo.

    Si vas a mostrar listas, tienes que hacerlo si o si por marcadores (bulletpoints, guiones u otros), y si es necesario, corta la información para que no sea demasiado larga. Si no tienes información suficiente, responde con "No tengo información suficiente para responder a esa pregunta".
    Si vas a mostrar eventos, asegúrate de que sean relevantes y estén relacionados con la pregunta. Si no hay eventos disponibles, responde con "No hay eventos disponibles en este momento".
    
    Si vas recomendar eventos solo muestra los eventos que están por venir, no los pasados. Si no hay eventos disponibles, responde con "No hay eventos disponibles en este momento".
    Si no entiendes la pregunta, responde con "No entiendo la pregunta, por favor intenta de nuevo".

    Si no hay eventos disponibles, responde con "No hay eventos disponibles en este momento".

    Responde las preguntas lo mas organizado posible y en ingles.



    Usuario: ${m.text}
    """;

    // 4. Ahora sí enviamos el contexto completo a Gemini
    final response = await http.post(
      Uri.parse(GEMINI_URL),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": contexto,
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      String reply = "No response from Gemini";
      if (data.containsKey("candidates") &&
          data["candidates"] is List &&
          data["candidates"].isNotEmpty &&
          data["candidates"][0].containsKey("content") &&
          data["candidates"][0]["content"] is Map &&
          data["candidates"][0]["content"].containsKey("parts") &&
          data["candidates"][0]["content"]["parts"] is List &&
          data["candidates"][0]["content"]["parts"].isNotEmpty &&
          data["candidates"][0]["content"]["parts"][0].containsKey("text")) {
        reply = data["candidates"][0]["content"]["parts"][0]["text"];
      }

      setState(() {
        _messages.insert(0, ChatMessage(
          text: reply,
          user: _gptChatUser,
          createdAt: DateTime.now(),
        ));
      });
    } else {
      setState(() {
        _messages.insert(0, ChatMessage(
          text: "Error: ${response.statusCode} - ${response.body}",
          user: _gptChatUser,
          createdAt: DateTime.now(),
        ));
      });
    }
  } catch (e) {
    setState(() {
      _messages.insert(0, ChatMessage(
        text: "Connection error: $e",
        user: _gptChatUser,
        createdAt: DateTime.now(),
      ));
    });
  }

  setState(() {
    _typingUsers.remove(_gptChatUser);
  });
}

  Future<void> handleOfflineInteraction(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUsers.add(_gptChatUser);
    });

    String userInput = m.text.toLowerCase();
    String reply = "";

    if (userInput.contains("information") || userInput.contains("growhub") || userInput.contains("info")) {
      _showGrowHubInfo();
    } else if (userInput.contains("events")|| userInput.contains("event") || userInput.contains("avai") || userInput.contains("vie")) {
      _showLocalEvents();
    } else if (userInput.contains("category")|| userInput.contains("show") || userInput.contains("sear")|| userInput.contains("find")|| userInput.contains("cat")) {
      _showCategories();
    } else if (userInput.contains("help") || userInput.contains("menu") || userInput.contains("options")) {
      reply = """Available options in offline mode:

  - Information about GrowHub
  - View available events
  - Search for events by category""";
setState(() {
        _messages.insert(0, ChatMessage(text: reply, user: _gptChatUser, createdAt: DateTime.now()));
        _typingUsers.remove(_gptChatUser);
      });;}
    else {
      reply = """ This option is not available in offline mode!!!.
  I can't help you with that :(

  You can ask me or request:

  - Information about GrowHub
  - View available events
  - Search for events by category""";
      setState(() {
        _messages.insert(0, ChatMessage(text: reply, user: _gptChatUser, createdAt: DateTime.now()));
        _typingUsers.remove(_gptChatUser);
      });
    }

    setState(() {
      _typingUsers.remove(_gptChatUser);
    });


  }

   void _showGrowHubInfo() {
    setState(() {
      _messages.insert(0, ChatMessage(
        text: "GrowHub is a platform that connects students, professionals, and event organizers for skill development.",
        user: _gptChatUser,
        createdAt: DateTime.now(),
      ));
      //_typingUsers.remove(_gptChatUser);
    });
  }

  void _showLocalEvents() async {
    final events = LocalStorageRepository().getEvents();
    if (events.isEmpty) {
      setState(() {
        _messages.insert(0, ChatMessage(
            text: "No offline events available.",
          user: _gptChatUser,
          createdAt: DateTime.now(),
        ));
        //_typingUsers.remove(_gptChatUser);
      });
    } else {
      String eventList = events.map((e) => "- ${e.name} (${e.start_date.day}/${e.start_date.month}): ${e.description} Cost: \$${e.cost}").join("\n");
      setState(() {
        _messages.insert(0, ChatMessage(
            text: "Available offline events:\n\n$eventList",
          user: _gptChatUser,
          createdAt: DateTime.now(),
        ));
       // _typingUsers.remove(_gptChatUser);
      });
    }
  }

  void _showCategories() async {
    final _categories = await DriftRepository(AppDatabase()).getCategoriesDrift();
    List<Category_event> categories =_categories ;
    if (categories.isEmpty) {
      setState(() {
        _messages.insert(0, ChatMessage(
            text: "No offline categories available.",
          user: _gptChatUser,
          createdAt: DateTime.now(),
        ));
       // _typingUsers.remove(_gptChatUser);
      });
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView(
            children: categories.map((cat) => ListTile(
              title: Text(cat.name, style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _showEventsForCategory(cat.id);
              },
            )).toList(),
          );
        },
      );
     // _typingUsers.remove(_gptChatUser);
    }
  }

  void _showEventsForCategory(String categoryId) async {
    final events = (await LocalStorageRepository().getEventsByCategory(categoryId).first);
    if (events.isEmpty) {
      setState(() {
        _messages.insert(0, ChatMessage(
            text: "No events available in this category.",
          user: _gptChatUser,
          createdAt: DateTime.now(),
        ));
      });
    } else {
      String eventList = events.map((e) => "- ${e.name} (${e.start_date.day}/${e.start_date.month}): ${e.description} Cost: \$${e.cost}").join("\n");
      setState(() {
        _messages.insert(0, ChatMessage(
            text: "Events in this category:\n\n$eventList",
          user: _gptChatUser,
          createdAt: DateTime.now(),
        ));
      });
    }
  }

  void _showError(String error) {
    setState(() {
      _messages.insert(0, ChatMessage(text: error, user: _gptChatUser, createdAt: DateTime.now()));
     // _typingUsers.remove(_gptChatUser);
    });
  }


}
