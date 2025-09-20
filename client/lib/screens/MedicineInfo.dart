import 'dart:convert';
import 'package:flutter/material.dart';
import '../component/custom_snackbar.dart.dart';
import '../services/info.dart';
import 'Doctor_screen.dart';
import 'package:http/http.dart' as http;


class MedicalInfo extends StatefulWidget {
  final String data;
  const MedicalInfo({super.key, required this.data});

  @override
  State<MedicalInfo> createState() => _MedicalInfoState();
}

class _MedicalInfoState extends State<MedicalInfo> {
  Map<String, dynamic>? _medicalData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getUserData(widget.data);
  }

  Future<void> _getUserData(String data) async {
    try {
      const String apiUrl = 'https://codenebula-internal-round-25.onrender.com/api/getmedicine/';

      final Map<String, dynamic> requestBody = {
        'patient_token': data
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _medicalData = responseData;
          _isLoading = false;
        });
      } else {
        final errorData = jsonDecode(response.body);
        print(errorData);
        String errorMessage = "Failed to load medical information";
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        }
        setState(() {
          _errorMessage = errorMessage;
          _isLoading = false;
        });
        AwesomeSnackbar.error(context, "Error", errorMessage);
      }
    } catch (error) {
      print(error);
      setState(() {
        _errorMessage = "Network error. Please check your connection.";
        _isLoading = false;
      });
      AwesomeSnackbar.error(
        context,
        "Network Error",
        "Please check your internet connection and try again",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Information'),
        backgroundColor: const Color(0xFF153D8A),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      )
          : _medicalData == null
          ? const Center(child: Text('No medical data available'))
          : _buildMedicalInfoContent(),
    );
  }

  Widget _buildMedicalInfoContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient information
          _buildPatientInfo(),
          const SizedBox(height: 24),

          // Medicines list
          _buildMedicinesList(),
        ],
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF153D8A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Name: ${_medicalData!['patient']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Medicines: ${_medicalData!['medicines'].length}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicinesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medicines',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF153D8A),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _medicalData!['medicines'].length,
          itemBuilder: (context, index) {
            final medicine = _medicalData!['medicines'][index];
            return _buildMedicineCard(medicine, index);
          },
        ),
      ],
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medicine name and ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  medicine['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF153D8A),
                  ),
                ),
                Text(
                  'ID: ${medicine['id']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            if (medicine['description'] != null && medicine['description'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  medicine['description'],
                  style: const TextStyle(fontSize: 15),
                ),
              ),

            // Manufacturer and expiry date
            Row(
              children: [
                if (medicine['manufacturer'] != null && medicine['manufacturer'].isNotEmpty)
                  Expanded(
                    child: Text(
                      'Manufacturer: ${medicine['manufacturer']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                if (medicine['expiry_date'] != null && medicine['expiry_date'].isNotEmpty)
                  Text(
                    'Expires: ${medicine['expiry_date']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Doses section
            if (medicine['doses'] != null && medicine['doses'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dosage Instructions:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...medicine['doses'].map<Widget>((dose) {
                    return _buildDoseItem(dose);
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoseItem(Map<String, dynamic> dose) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time icon and time
          Icon(
            Icons.access_time,
            size: 18,
            color: Colors.blueGrey[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dose['dose_name'] != null && dose['dose_name'].isNotEmpty)
                  Text(
                    dose['dose_name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (dose['dose_time'] != null && dose['dose_time'].isNotEmpty)
                  Text(
                    'Time: ${_formatTime(dose['dose_time'])}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                if (dose['description'] != null && dose['description'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      dose['description'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timeString) {
    try {
      // Assuming time is in format "HH:MM:SS"
      final timeParts = timeString.split(':');
      if (timeParts.length >= 2) {
        final hour = int.parse(timeParts[0]);
        final minute = timeParts[1];

        // Convert to 12-hour format
        final period = hour >= 12 ? 'PM' : 'AM';
        final hour12 = hour % 12;
        final displayHour = hour12 == 0 ? 12 : hour12;

        return '$displayHour:$minute $period';
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }
}