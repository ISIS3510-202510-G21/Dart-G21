import 'package:dart_g21/controllers/category_controller.dart';
import 'package:dart_g21/controllers/skill_controller.dart';
import 'package:dart_g21/models/skill.dart';
import 'package:flutter/material.dart';
import 'package:dart_g21/core/colors.dart';
import 'package:flutter/services.dart';
import 'package:dart_g21/controllers/event_controller.dart';
import 'package:dart_g21/controllers/location_controller.dart';
import 'package:dart_g21/models/event.dart';
import 'package:dart_g21/models/category.dart';
import 'package:dart_g21/models/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;



class CreateEventScreen extends StatefulWidget {
  final String userId; // ID del usuario que crea el evento
 
  const CreateEventScreen({Key? key, required this.userId}) : super(key: key);


  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final EventController _eventController = EventController();
  final CategoryController _categoryController = CategoryController();
  final LocationController _locationController = LocationController();
  final SkillController _skillController = SkillController(); //controller de skills
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();


  List<String> selectedSkills = [];
  final int maxSkillSelection = 3;
  
  String? selectedCategory;
  String? categoryId; 
  DateTime? fromDate;
  DateTime? toDate;
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  String? selectedCity;
  bool? isUniversity;
  bool _isAddressValid = true;
  bool _isCheckingAddress = false;


  //Metodo para mostrar el listado de skills
  void toggleSkillSelection(String skillId) {
  setState(() {
    if (selectedSkills.contains(skillId)) {
      selectedSkills.remove(skillId);
    } else if (selectedSkills.length < maxSkillSelection) {
      selectedSkills.add(skillId);
    }
  });
  }

  //Crear el evento y enviarlo al Controller
  void _saveEvent() async {

    DateTime startDateTime = DateTime(
      fromDate?.year ?? DateTime.now().year,
      fromDate?.month ?? DateTime.now().month,
      fromDate?.day ?? DateTime.now().day,
      fromTime?.hour ?? 0,
      fromTime?.minute ?? 0,
    );

    DateTime endDateTime = DateTime(
      toDate?.year ?? DateTime.now().year,
      toDate?.month ?? DateTime.now().month,
      toDate?.day ?? DateTime.now().day,
      toTime?.hour ?? 0,
      toTime?.minute ?? 0,
    );
    if (_isCheckingAddress) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please wait while we verify the address...")),
      );
      return;
    }

    if (!_isAddressValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid address.")),
      );
      return;
    }

    if (selectedCategory == null || _nameController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    //Crear la ubicación
    final coordinates = await getCoordinatesFromAddress(_addressController.text.trim());

    if (coordinates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("The address is invalid. Please enter a valid address.")),
      );
      return;
    }
    String? locationId = await _locationController.addLocationAndReturnId(Location(
      id: "", // Firestore generará el ID
      address: _addressController.text.trim(),
      details: _detailsController.text.trim(),
      city: selectedCity!,          // ya fue validado
      university: isUniversity!,    // ya fue validado
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
    ));

    //Obtener la ubicación para referenciarla en el evento
    Location? location = await _locationController.getLocationByAddress(_addressController.text.trim()).first;
    String? id_location = location?.id;


    //Crear el objeto Event
    Event newEvent = Event(
      id: "", //Firestore generará el ID automáticamente
      name: _nameController.text,
      cost: int.tryParse(_costController.text) ?? 0,
      category: categoryId ?? "", //Guardar la referencia de categoría
      description: _descriptionController.text,
      start_date: startDateTime,
      end_date: endDateTime,
      location_id: id_location ?? "", //Guardar la referencia de location
      image: _imageUrlController.text,
      attendees: [], //Lista vacía al inicio
      skills: selectedSkills, //Guardar la lista de skills seleccionadas
      creator_id: widget.userId, // ID del creador del evento
    );


    await _eventController.addEvent(newEvent);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Event created successfully")),
    );
    Navigator.pop(context); // Volver a la pantalla anterior
  }

  /* @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _detailsController.dispose();
    super.dispose();
  } */

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Invalid Selection"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }


  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
          if (toDate != null && picked.isAfter(toDate!)) {
            _showErrorDialog("The end date must be after the start date.");
            fromDate = null; //reiniciar el campo si es inválido
          }
        } else {
          if (fromDate != null && picked.isBefore(fromDate!)) {
            _showErrorDialog("The end date must be after the start date.");
          } else {
            toDate = picked;
          }
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isFromTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isFromTime) {
          fromTime = picked;
          if (toTime != null && _isTimeBeforeOrEqual(picked, toTime!)) {
            _showErrorDialog("The end time must be after the start time.");
            fromTime = null; // reiniciar el campo si es inválido
          }
        } else {
          if (fromTime != null && _isTimeBeforeOrEqual(picked, fromTime!)) {
            _showErrorDialog("The end time must be after the start time.");
          } else {
            toTime = picked;
          }
        }
      });
    }
  }

  bool _isTimeBeforeOrEqual(TimeOfDay first, TimeOfDay second) {
    final int firstMinutes = first.hour * 60 + first.minute;
    final int secondMinutes = second.hour * 60 + second.minute;
    return firstMinutes <= secondMinutes;
  }
  

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: screenWidth > 500 ? 400 : screenWidth * 0.9,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  _buildLabeledInputField("Name", _nameController, 'Write the name of the event', Icons.event),
                  const SizedBox(height: 15),
                  _buildLabeledCostField(), // restricciones numéricas en el campo de cost, para que solo se valga como input nums
                  const SizedBox(height: 15),
                  _buildLabeledDropdown("Category"),
                  const SizedBox(height: 15),
                  _buildLabeledInputField("Description", _descriptionController, 'Write the description of your event...', Icons.description),
                  const SizedBox(height: 15),
                  _buildLabeledDatePickers(),
                  const SizedBox(height: 15),
                  _buildLabeledTimePickers(),
                  const SizedBox(height: 15),
                  _buildLabeledAddressField(),
                  const SizedBox(height: 15),
                  _buildLabeledCityDropdown("City"),
                  const SizedBox(height: 15),
                  _buildLabeledUniversityDropdown("Is this a university event?"),
                  const SizedBox(height: 15),
                  _buildLabeledInputField("Details", _detailsController, 'Write the details of the address', Icons.info),
                  const SizedBox(height: 30),
                  _buildLabeledInputField("Image URL", _imageUrlController, 'URL of the image', Icons.image),
                  const SizedBox(height: 30),
                  Text("Skills (max 3)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    child: StreamBuilder<List<Skill>>(
                      stream: _skillController.getSkillsStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return CircularProgressIndicator();
                        final skills = snapshot.data!;
                        return GridView.builder(
                          itemCount: skills.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 3.5,
                          ),
                          itemBuilder: (context, index) {
                            final skill = skills[index];
                            final isSelected = selectedSkills.contains(skill.id);
                            return FilterChip(
                              label: Text(skill.name),
                              selected: isSelected,
                              selectedColor: AppColors.secondary.withOpacity(0.2),
                              checkmarkColor: Colors.white,
                              onSelected: (_) => toggleSkillSelection(skill.id),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildCreateEventButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 10), 
        const Text(
          'Create Event',
          style: TextStyle(
            fontSize: 24,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, bool isFromDate) {
  return GestureDetector(
    onTap: () => _selectDate(context, isFromDate),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE6E6E6), width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date != null ? "${date.day}/${date.month}/${date.year}" : "Select date",
            style: const TextStyle(color: Color(0xFF8D8D8D), fontSize: 16),
          ),
          const Icon(Icons.calendar_today, color: Color(0xFF8D8D8D)), // calendario
        ],
      ),
    ),
  );
}
  
Widget _buildTimeField(String label, TimeOfDay? time, bool isFromTime) {
  return GestureDetector(
    onTap: () => _selectTime(context, isFromTime),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE6E6E6), width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time != null ? time.format(context) : "Select time",
            style: const TextStyle(color: Color(0xFF8D8D8D), fontSize: 16),
          ),
          const Icon(Icons.access_time, color: Color(0xFF8D8D8D)), // reloj
        ],
      ),
    ),
  );
}

  // mostrar un campo con un título en negro antes de la barra de entrada
  Widget _buildLabeledInputField(String label, TextEditingController controller, String hintText, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 5),
        _buildInputField(controller, hintText, icon),
      ],
    );
  }

  Widget _buildInputField(TextEditingController controller, String hintText, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFFE6E6E6)),
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF8D8D8D)),
        border: _buildInputBorder(),
      ),
    );
  }

  // mostrar un dropdown con un título en negro antes
  Widget _buildLabeledDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 5),
        _buildCategoryDropdown(),
      ],
    );
  }


  Widget _buildCategoryDropdown() {
  return StreamBuilder<List<Category_event>>(
    stream: _categoryController.getCategoriesStream(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return CircularProgressIndicator(); //Muestra un loader mientras se carga
      }

      final categoryList = snapshot.data!;

      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.category, color: Color(0xFFE6E6E6)),
          border: _buildInputBorder(),
        ),
        value: selectedCategory,
        hint: const Text("Choose the category", style: TextStyle(color: Color(0xFF8D8D8D), fontSize: 16)),
        items: categoryList.map((category) {
          return DropdownMenuItem<String>(
            value: category.id, //Guardas el ID directamente
            child: Text(category.name),
          );
        }).toList(),
        onChanged: (String? newValue) {
            setState(() {
              selectedCategory = newValue!;
              print(" Usuario seleccionó: $newValue");
              print(" Categorías disponibles: ${categoryList.map((c) => c.name).toList()}");
              categoryId = newValue; // el ID ya viene del value del dropdown
            });

        /* onChanged: (String? newValue) {
          setState(() {
            selectedCategory = newValue!;
            print(" Usuario seleccionó: $newValue");
            print(" Categorías disponibles: ${categoryList.map((c) => c.name).toList()}");
            categoryId = snapshot.data!
            .firstWhere((c) => c.name == newValue, orElse: () => Category_event(id: '', name: ''))
            .id;
          }); */
        },
      );
    },
  );
}

  Widget _buildLabeledDatePickers() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
      const SizedBox(height: 5),
      Row(
        children: [
          Expanded(child: _buildDateField("From", fromDate, true)),
          const SizedBox(width: 10),
          Expanded(child: _buildDateField("To", toDate, false)),
        ],
      ),
    ],
  );
}

  Widget _buildLabeledTimePickers() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Hour", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
      const SizedBox(height: 5),
      Row(
        children: [
          Expanded(child: _buildTimeField("From", fromTime, true)),
          const SizedBox(width: 10),
          Expanded(child: _buildTimeField("To", toTime, false)),
        ],
      ),
    ],
  );
}

  Widget _buildUploadImageButton() {
    return SizedBox(
      width: double.infinity, 
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.upload, color: AppColors.secondary),
        label: const Text("Upload Image of the event", style: TextStyle(color: AppColors.secondary)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.secondary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }


  Widget _buildCreateEventButton() {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: _saveEvent, // Ahora llama a `_saveEvent()`
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
      child: const Text("Create Event", style: TextStyle(color: Colors.white, fontSize: 16)),
    ),
  );
}

//Navigator.pushNamed(context, '/home'); // habilitar cuando este todooo
        
  Widget _buildLabeledCostField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Cost", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
      const SizedBox(height: 5),
      _buildCostField(),
    ],
  );
}

Widget _buildCostField() {
  return TextField(
    controller: _costController,
    keyboardType: TextInputType.number, // mostrar solo el teclado numérico
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly, // retricción a solo números enteros
    ],
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.attach_money, color: Color(0xFFE6E6E6)), // Ícono de dinero 💲
      hintText: 'Write the cost of your event',
      hintStyle: const TextStyle(color: Color(0xFF8D8D8D)),
      border: _buildInputBorder(),
    ),
  );
}

  OutlineInputBorder _buildInputBorder() {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFFE6E6E6), width: 2),
    );
  }

  Widget _buildCityDropdown() {
    final cities = [
      "Bogotá", "Medellín", "Cali", "Barranquilla", "Cartagena",
      "Bucaramanga", "Pereira", "Manizales", "Cúcuta", "Santa Marta",
      "Ibagué", "Villavicencio", "Neiva", "Pasto", "Armenia",
      "Montería", "Sincelejo", "Valledupar", "Tunja", "Popayán",
      "Florencia", "Quibdó", "Yopal", "Leticia"
    ];

  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.location_city, color: Color(0xFFE6E6E6)),
      border: _buildInputBorder(),
      ),
      value: selectedCity,
      hint: const Text("Choose a city", style: TextStyle(color: AppColors.secondaryText)),
      items: cities.map((city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedCity = newValue!;
        });
      },
    );
}
  
  Widget _buildLabeledCityDropdown(String label) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
      const SizedBox(height: 5),
      _buildCityDropdown(),
    ],
  );
}

  Widget _buildUniversityDropdown() {
  return DropdownButtonFormField<bool>(
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.school, color: Color(0xFFE6E6E6)),
      border: _buildInputBorder(),
    ),
    value: isUniversity,
    hint: const Text("Is it a university event?", style: TextStyle(color: AppColors.secondaryText)),
    items: const [
      DropdownMenuItem(value: true, child: Text("Yes")),
      DropdownMenuItem(value: false, child: Text("No")),
    ],
    onChanged: (bool? newValue) {
      setState(() {
        isUniversity = newValue!;
      });
    },
  );
}

Widget _buildLabeledUniversityDropdown(String label) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
      const SizedBox(height: 5),
      _buildUniversityDropdown(),
    ],
  );
}

  Widget _buildLabeledAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 5),
        TextField(
          controller: _addressController,
          onChanged: (value) => _validateAddressRealtime(value),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_on, color: Color(0xFFE6E6E6)),
            suffixIcon: _addressController.text.trim().isEmpty
                ? null
                : _isCheckingAddress
                ? const Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
                : Icon(
              _isAddressValid ? Icons.check_circle : Icons.error,
              color: _isAddressValid ? Colors.green : Colors.red,
            ),
            hintText: "Write the address",
            hintStyle: const TextStyle(color: Color(0xFF8D8D8D)),
            border: _buildInputBorder(),
          ),
        ),
      ],
    );
  }

  Future<void> _validateAddressRealtime(String address) async {
    if (address.trim().isEmpty) {
      setState(() {
        _isCheckingAddress = false;
        _isAddressValid = false;
      });
      return;
    }

    setState(() {
      _isCheckingAddress = true;
      _isAddressValid = false;
    });

    try {
      List<geo.Location> locations = await geo.locationFromAddress(address);
      setState(() {
        _isCheckingAddress = false;
        _isAddressValid = locations.isNotEmpty;
      });
    } catch (e) {
      print("Address validation error: $e");
      setState(() {
        _isCheckingAddress = false;
        _isAddressValid = false;
      });
    }
  }


  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      List<geo.Location> locations = await geo.locationFromAddress(address);

      if (locations.isNotEmpty) {
        final location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
    } catch (e) {
      print("Error getting coordinates: $e");
    }

    return null;
  }


}
