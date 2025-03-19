import 'package:cloud_firestore/cloud_firestore.dart';

// 🔹 Función para crear un evento en Firestore
Future<void> createEvent(String name, String description, String category, double cost, String startDate, String endDate, String image, String address, String locationId, String hostId) async {
  try {
    await FirebaseFirestore.instance.collection("events").add({
      "name": name,
      "description": description,
      "category": category,
      "cost": cost,
      "start_date": startDate,
      "end_date": endDate,
      "image": image,
      "address": address,
      "location_id": locationId,
      "host_id": hostId,
      "attendees": [], // 🔥 Lista vacía de asistentes al crear un evento
    });
    print("✅ Evento creado correctamente");
  } catch (e) {
    print("❌ Error al crear el evento: $e");
  }
}
