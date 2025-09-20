import 'dart:convert';
import 'package:flutter/material.dart';
import '../component/custom_snackbar.dart.dart';
import '../services/info.dart';
import 'Doctor_screen.dart';
import 'package:http/http.dart' as http;

class Doctorinfo extends StatefulWidget {
  final String data;
  const Doctorinfo({super.key, required this.data});

  @override
  State<Doctorinfo> createState() => _DoctorinfoState();
}

class _DoctorinfoState extends State<Doctorinfo> {
  final _formKey = GlobalKey<FormState>();
  final List<Medicine> _medicines = [];
  bool _isSubmitting = false;

  // Medicine form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();

  // Dose form controllers
  final TextEditingController _doseNameController = TextEditingController();
  final TextEditingController _doseDescriptionController = TextEditingController();
  final TextEditingController _doseTimeController = TextEditingController();

  List<Dose> _currentDoses = [];

  @override
  void initState() {
    super.initState();
    // Initialize with one empty medicine
    _medicines.add(Medicine(
      name: '',
      description: '',
      manufacturer: '',
      expiryDate: '',
      doses: [],
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _manufacturerController.dispose();
    _expiryDateController.dispose();
    _doseNameController.dispose();
    _doseDescriptionController.dispose();
    _doseTimeController.dispose();
    super.dispose();
  }

  Future<void> _submitMedicines() async {
    if (!_formKey.currentState!.validate()) {
      AwesomeSnackbar.error(context, "Validation Error", "Please fill all required fields correctly");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      const String apiUrl = 'https://codenebula-internal-round-25.onrender.com/api/postmedicine/';

      // Prepare the list of medicines to submit
      for (final medicine in _medicines) {
        if (medicine.name.isEmpty) continue; // Skip empty medicines

        final Map<String, dynamic> requestBody = {
          'patient_token': widget.data,
          'name': medicine.name,
          'description': medicine.description,
          'manufacturer': medicine.manufacturer,
          'expiry_date': medicine.expiryDate,
          'doses': medicine.doses.map((dose) => {
            'dose_name': dose.doseName,
            'description': dose.description,
            'dose_time': dose.doseTime,
          }).toList(),
        };

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Success
          AwesomeSnackbar.success(context, "Success", "Medicine ${medicine.name} added successfully");
        } else {
          final errorData = jsonDecode(response.body);
          String errorMessage = "Failed to add medicine";
          if (errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else if (errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }
          AwesomeSnackbar.error(context, "Error", errorMessage);
          break; // Stop on first error
        }
      }

      // Clear form after successful submission
      _medicines.clear();
      _medicines.add(Medicine(
        name: '',
        description: '',
        manufacturer: '',
        expiryDate: '',
        doses: [],
      ));
      _formKey.currentState!.reset();

    } catch (error) {
      print(error);
      AwesomeSnackbar.error(
        context,
        "Network Error",
        "Please check your internet connection and try again",
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _addMedicine() {
    setState(() {
      _medicines.add(Medicine(
        name: _nameController.text,
        description: _descriptionController.text,
        manufacturer: _manufacturerController.text,
        expiryDate: _expiryDateController.text,
        doses: List.from(_currentDoses),
      ));

      // Clear form for next medicine
      _nameController.clear();
      _descriptionController.clear();
      _manufacturerController.clear();
      _expiryDateController.clear();
      _currentDoses.clear();
    });
  }

  void _addDose() {
    if (_doseNameController.text.isNotEmpty && _doseTimeController.text.isNotEmpty) {
      setState(() {
        _currentDoses.add(Dose(
          doseName: _doseNameController.text,
          description: _doseDescriptionController.text,
          doseTime: _doseTimeController.text,
        ));

        // Clear dose form
        _doseNameController.clear();
        _doseDescriptionController.clear();
        _doseTimeController.clear();
      });
    }
  }

  void _removeDose(int index) {
    setState(() {
      _currentDoses.removeAt(index);
    });
  }

  void _removeMedicine(int index) {
    setState(() {
      _medicines.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Patient Medicines'),
        backgroundColor: const Color(0xFF153D8A),
        foregroundColor: Colors.white,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient token info
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Color(0xFF153D8A)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Patient: ${widget.data}',
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Medicine form
                const Text(
                  'Add New Medicine',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter medicine name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _manufacturerController,
                  decoration: const InputDecoration(
                    labelText: 'Manufacturer',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _expiryDateController,
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date (YYYY-MM-DD) *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter expiry date';
                    }
                    // Simple date format validation
                    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                    if (!regex.hasMatch(value)) {
                      return 'Please use YYYY-MM-DD format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Dose form
                const Text(
                  'Add Doses',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _doseNameController,
                        decoration: const InputDecoration(
                          labelText: 'Dose Name *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _doseTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Time (HH:MM:SS) *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _doseDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Dose Instructions',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: _addDose,
                  child: const Text('Add Dose'),
                ),
                const SizedBox(height: 16),

                // Current doses list
                if (_currentDoses.isNotEmpty) ...[
                  const Text(
                    'Current Doses:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._currentDoses.asMap().entries.map((entry) {
                    final index = entry.key;
                    final dose = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(dose.doseName),
                        subtitle: Text('${dose.doseTime} - ${dose.description}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeDose(index),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],

                // Add medicine button
                Center(
                  child: ElevatedButton(
                    onPressed: _addMedicine,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Medicine to List'),
                  ),
                ),
                const SizedBox(height: 24),

                // Medicines list
                if (_medicines.any((m) => m.name.isNotEmpty)) ...[
                  const Text(
                    'Medicines to Submit:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._medicines.asMap().entries.map((entry) {
                    final index = entry.key;
                    final medicine = entry.value;
                    if (medicine.name.isEmpty) return const SizedBox.shrink();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  medicine.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeMedicine(index),
                                ),
                              ],
                            ),
                            if (medicine.description.isNotEmpty)
                              Text('Description: ${medicine.description}'),
                            if (medicine.manufacturer.isNotEmpty)
                              Text('Manufacturer: ${medicine.manufacturer}'),
                            if (medicine.expiryDate.isNotEmpty)
                              Text('Expiry: ${medicine.expiryDate}'),
                            if (medicine.doses.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text('Doses:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...medicine.doses.map((dose) => Padding(
                                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                child: Text('• ${dose.doseName} at ${dose.doseTime}'),
                              )),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // Submit button
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitMedicines,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF153D8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text('Submit All Medicines'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Medicine {
  final String name;
  final String description;
  final String manufacturer;
  final String expiryDate;
  final List<Dose> doses;

  Medicine({
    required this.name,
    required this.description,
    required this.manufacturer,
    required this.expiryDate,
    required this.doses,
  });
}

class Dose {
  final String doseName;
  final String description;
  final String doseTime;

  Dose({
    required this.doseName,
    required this.description,
    required this.doseTime,
  });
}