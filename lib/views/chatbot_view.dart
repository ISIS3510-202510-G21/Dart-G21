import 'dart:convert';
import 'package:dart_g21/consts.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size:28 ,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("ChatBot", style: TextStyle(color: AppColors.textPrimary, fontSize: 24)),
      ),
      body: DashChat(
        currentUser: _currentUser,
        typingUsers: _typingUsers,
        onSend: (ChatMessage m) {
          getChatResponse(m);
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
                  CircleAvatar(
                    backgroundImage: NetworkImage(message.user.profileImage ?? ''),
                    radius: 20,
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
                  CircleAvatar(
                    backgroundImage: NetworkImage(message.user.profileImage ?? ''),
                    radius: 20,
                  ),
                SizedBox(width: 10),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUsers.add(_gptChatUser);
    });

    try {
      final response = await http.post(
        Uri.parse(GEMINI_URL),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": """
                  Contexto de GrowHub:
                  GrowHub es una aplicación móvil diseñada para conectar estudiantes, profesionales y organizadores con eventos de desarrollo de habilidades.
                  Ofrece tanto eventos gratuitos como pagos y permite que organizadores gestionen su visibilidad y audiencia de manera efectiva.
                  
                   **Tipos de Usuarios**:
                  - Organizadores voluntarios: crean eventos gratuitos.
                  - Organizadores pagos: pueden cobrar por la participación.
                  - Asistentes gratuitos: se registran en eventos sin costo.
                  - Asistentes pagos: acceden a eventos premium.

                   **Modelo de Monetización**:
                  1. **Tarifa por Publicación de Eventos**:
                     - Publicación básica: \$5 (solo aparece en el catálogo).
                     - Publicación premium: \$15 (más visibilidad y destacada).
                  
                  2. **Tarifa por Aumentar Visibilidad**:
                     - Estándar: Incluida en la publicación.
                     - Destacada: \$10/semana (más prioridad en búsqueda).
                     - Evento destacado: \$25/semana (portada de la app).
                     - Promoción exclusiva: \$50/semana (notificaciones push y redes sociales).
                  
                  3. **Comisión por Venta de Tickets**:
                     - 10% en tickets <\$10.
                     - 8% en tickets de \$10 a \$50.
                     - 5% en tickets >\$50.

                   **Beneficios para Organizadores**:
                  - Creación fácil de eventos con formulario simplificado.
                  - Herramientas de promoción para maximizar la asistencia.
                  - Integración con redes sociales y plataformas universitarias.
                  - Recomendaciones personalizadas para los asistentes.

                  🔹 Solo responde preguntas sobre todo lo relacionado a eventos, recomendación de eventos según intereses y gustos de los usuarios que te escriban, organizadores, costos y visibilidad de eventos. 
                  🔹 No respondas sobre búsqueda de eventos ni registro.

                  Usuario: ${m.text}
                  """
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
          text: "Error en la conexión: $e",
          user: _gptChatUser,
          createdAt: DateTime.now(),
        ));
      });
    }

    setState(() {
      _typingUsers.remove(_gptChatUser);
    });
  }
}
