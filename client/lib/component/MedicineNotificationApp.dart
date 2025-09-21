import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
// import 'package:flutter_timezone/flutter_timezone.dart';

void main() {
  runApp(MedicineNotificationApp());
}

class MedicineNotificationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Notifications',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MedicineNotificationScheduler(),
    );
  }
}

class MedicineNotificationScheduler extends StatefulWidget {
  @override
  _MedicineNotificationSchedulerState createState() =>
      _MedicineNotificationSchedulerState();
}

class _MedicineNotificationSchedulerState
    extends State<MedicineNotificationScheduler> {
  final String baseUrl = "http://127.0.0.1:8000";
  final String patientToken = "your_patient_token"; // Replace with actual token
  final String email = "patient@example.com"; // Replace with actual email
  final String jwtToken = "your_jwt_token"; // Replace with actual JWT token

  List<dynamic> medicines = [];
  bool isLoading = false;
  String statusMessage = "";
  List<Timer> scheduledTimers = [];

  @override
  void initState() {
    super.initState();
    // Initialize timezone if needed
  }

  @override
  void dispose() {
    // Cancel all timers when the widget is disposed
    for (var timer in scheduledTimers) {
      timer.cancel();
    }
    super.dispose();
  }

  Future<void> fetchMedicines() async {
    setState(() {
      isLoading = true;
      statusMessage = "Fetching medicine data...";
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/getmedicine/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patient_token': patientToken,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          medicines = data['medicines'];
          statusMessage = "Fetched ${medicines.length} medicines successfully!";
        });

        // Schedule notifications for all medicines
        scheduleAllMedicineNotifications();
      } else {
        setState(() {
          statusMessage = "Failed to fetch medicines: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "Error: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void scheduleAllMedicineNotifications() {
    // Clear any existing timers
    for (var timer in scheduledTimers) {
      timer.cancel();
    }
    scheduledTimers.clear();

    // Schedule notifications for each medicine and dose
    for (var medicine in medicines) {
      for (var dose in medicine['doses']) {
        scheduleNotification(medicine, dose);
      }
    }
  }

  void scheduleNotification(Map<String, dynamic> medicine, Map<String, dynamic> dose) {
    // Parse the dose time
    final timeParts = dose['dose_time'].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Calculate the time until the next dose
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    // If the time has already passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final durationUntilDose = scheduledTime.difference(now);

    // Set a timer to send the notification at the appropriate time
    final timer = Timer(durationUntilDose, () {
      sendNotificationToServer(medicine, dose);

      // Schedule the next notification for the following day (recurring)
      scheduleNotification(medicine, dose);
    });

    scheduledTimers.add(timer);

    // Also send an immediate notification for testing purposes
    // sendNotificationToServer(medicine, dose);
  }

  Future<void> sendNotificationToServer(Map<String, dynamic> medicine, Map<String, dynamic> dose) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/medicineNotificationViewset/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: json.encode({
          'title': 'Medicine Reminder: ${medicine['name']} - ${dose['dose_name']}',
          'body': 'Time to take ${medicine['name']}. ${dose['description']}',
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent to server successfully');
        // Update UI to show notification was sent
        setState(() {
          statusMessage = "Notification sent for ${medicine['name']} - ${dose['dose_name']}";
        });
      } else {
        print('Failed to send notification to server: ${response.statusCode}');
        setState(() {
          statusMessage = "Failed to send notification: ${response.statusCode}";
        });
      }
    } catch (e) {
      print('Error sending notification to server: $e');
      setState(() {
        statusMessage = "Error sending notification: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Notification Scheduler'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medicine Notification System',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'This component will fetch medicine data and schedule API calls to your server for each dose time.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : fetchMedicines,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Start Notification Scheduling'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Status: $statusMessage',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 24),
            if (medicines.isNotEmpty) ...[
              Text(
                'Medicines Found:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    final medicine = medicines[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicine['name'],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text('Manufacturer: ${medicine['manufacturer']}'),
                            Text('Description: ${medicine['description']}'),
                            Text('Expiry: ${medicine['expiry_date']}'),
                            SizedBox(height: 8),
                            Text(
                              'Doses:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...medicine['doses'].map<Widget>((dose) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0, top: 4),
                                child: Text(
                                    '- ${dose['dose_name']} at ${dose['dose_time']}'),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}