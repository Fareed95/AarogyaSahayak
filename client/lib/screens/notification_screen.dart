// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../../services/secure_storage_service.dart';
// import '../component/custom_snackbar.dart.dart';

// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({super.key});

//   @override
//   State<NotificationScreen> createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _bodyController = TextEditingController();

//   bool _isLoading = false;
//   bool _isSent = false;

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _bodyController.dispose();
//     super.dispose();
//   }

//   Future<void> _sendNotification() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//         _isSent = false;
//       });

//       try {
//         // Get JWT token for authentication
//         String? jwtToken = await SecureStorageService().getJwtToken();

//         if (jwtToken == null) {
//           return;
//         }

//         // Prepare the request body
//         final Map<String, dynamic> requestBody = {
//           'title': _titleController.text.trim(),
//           'body': _bodyController.text.trim(),
//         };

//         // Make POST request
//         final response = await http.post(
//           Uri.parse('https://flutter-demo-c7cg.onrender.com/api/notification/'),
//           headers: <String, String>{
//             'Content-Type': 'application/json; charset=UTF-8',
//             'Authorization': jwtToken,
//           },
//           body: jsonEncode(requestBody),
//         );

//         // Handle response
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           // Success
//           final responseData = jsonDecode(response.body);
//           print('Notification sent successfully: $responseData');

//           setState(() {
//             _isSent = true;
//           });

//           AwesomeSnackbar.success(
//               context,
//               "Notification Sent",
//               "All users will get notifications"
//           );

//           // Clear form after successful send
//           _titleController.clear();
//           _bodyController.clear();
//         } else {
//           // Error
//           final errorData = jsonDecode(response.body);
//           print('Error sending notification: $errorData');

//           String errorMessage = 'Failed to send notification';
//           if (errorData.containsKey('message')) {
//             errorMessage = errorData['message'];
//           } else if (errorData.containsKey('error')) {
//             errorMessage = errorData['error'];
//           }

//         }
//       } catch (error) {
//         // Network or other errors
//         print('Exception sending notification: $error');
//         AwesomeSnackbar.error(context, "Didn't send Notification", 'Network error. Please check your connection and try again.');
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }





//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Send Notification'),
//         backgroundColor: Colors.blue.shade700,
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Success message
//               if (_isSent)
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   margin: const EdgeInsets.only(bottom: 20),
//                   decoration: BoxDecoration(
//                     color: Colors.green.shade50,
//                     border: Border.all(color: Colors.green.shade200),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.check_circle, color: Colors.green.shade600),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           'Notification sent successfully!',
//                           style: TextStyle(
//                             color: Colors.green.shade800,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//               // Title Field
//               TextFormField(
//                 controller: _titleController,
//                 decoration: InputDecoration(
//                   labelText: 'Notification Title',
//                   prefixIcon: Icon(Icons.title, color: Colors.blue.shade600),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a title';
//                   }
//                   if (value.length < 3) {
//                     return 'Title must be at least 3 characters';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),

//               // Body Field
//               TextFormField(
//                 controller: _bodyController,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   labelText: 'Notification Message',
//                   alignLabelWithHint: true,
//                   prefixIcon: Icon(Icons.message, color: Colors.blue.shade600),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a message';
//                   }
//                   if (value.length < 5) {
//                     return 'Message must be at least 5 characters';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 30),

//               // Send Button
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _sendNotification,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue.shade700,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: _isLoading
//                     ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation(Colors.white),
//                   ),
//                 )
//                     : const Text(
//                   'Send Notification to All Users',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Information Card
//               Card(
//                 color: Colors.blue.shade50,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.info, color: Colors.blue.shade700),
//                           const SizedBox(width: 10),
//                           Text(
//                             'About This Feature',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blue.shade800,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         'This notification will be sent to all users who have enabled push notifications in your app. '
//                             'The message will appear on their devices even if the app is closed.',
//                         style: TextStyle(
//                           color: Colors.blue.shade700,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }