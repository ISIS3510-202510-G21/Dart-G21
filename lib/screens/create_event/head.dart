import 'package:flutter/material.dart';
import 'package:dart_g21/core/colors.dart';
import 'package:flutter/services.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  
  String? selectedCategory;
  DateTime? fromDate;
  DateTime? toDate;
  TimeOfDay? fromTime;
  TimeOfDay? toTime;

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

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
            fromDate = null; // reiniciar el campo si es inválido
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
                  _buildLabeledInputField("Address", _addressController, 'Write the address of your event', Icons.location_on),
                  const SizedBox(height: 15),
                  _buildLabeledInputField("Details", _detailsController, 'Write the details of your event', Icons.info),
                  const SizedBox(height: 30),
                  _buildUploadImageButton(),
                  const SizedBox(height: 30),
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
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 10), 
        const Text(
          'Create Event',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
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
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.category, color: Color(0xFFE6E6E6)),
        border: _buildInputBorder(),
      ),
      value: selectedCategory,
      hint: const Text("Choose the category of your event"),
      items: ["Workshop", "Networking", "Hackathon", "Sports"].map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedCategory = newValue!;
        });
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
        onPressed: () {
          //Navigator.pushNamed(context, '/home'); // habilitar cuando este todooo
        },
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
        child: const Text("Create Event", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

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
}
