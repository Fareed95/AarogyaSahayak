import 'dart:convert';
import 'package:client/services/secure_storage_service.dart';
import '../component/custom_snackbar.dart.dart';
import '../services/info.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../screens/notification_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isDoctor = false;
  bool _isMedical = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Mock ASHA / community health worker data
  final List<Map<String, dynamic>> _mockAshaWorkers = [
    {
      "id": 1,
      "name": "ASHA Worker - Meera Patel",
      "region": "Wadala",
      "distance_km": 1.2,
      "phone": "+91-98765-43210",
      "available": true,
    },
    {
      "id": 2,
      "name": "ASHA Worker - Rekha Sharma",
      "region": "Kurla",
      "distance_km": 2.8,
      "phone": "+91-91234-56789",
      "available": true,
    },
    {
      "id": 3,
      "name": "ASHA Worker - S. Kumar",
      "region": "Ghatkopar",
      "distance_km": 4.6,
      "phone": "+91-99887-66554",
      "available": false,
    },
    {
      "id": 4,
      "name": "ASHA Worker - Anita Rao",
      "region": "Andheri",
      "distance_km": 6.0,
      "phone": "+91-90123-45678",
      "available": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _getUserData();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _getUserData() async {
    try {
      const String apiUrl = 'https://codenebula-internal-round-25.onrender.com/api/authentication/user';

      var token = await SecureStorageService().getJwtToken();

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        bool doctor = responseData['is_doctor'];
        bool medical = responseData['is_medical_store'];

        setState(() {
          _isDoctor = doctor;
          _isMedical = medical;
        });

        Info().setDoctor(doctor);
        Info().setMedical(medical);
      } else {
        final errorData = jsonDecode(response.body);
        print(errorData);
        String errorMessage = "Registration failed";
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        }
        AwesomeSnackbar.error(
          context,
          "Error",
          errorMessage,
        );
      }
    } catch (error) {
      print(error);
      AwesomeSnackbar.error(
        context,
        "Network Error",
        "Please check your internet connection and try again",
      );
    }
  }

  Future<void> _handleFileUpload() async {
    try {
      // 1. Pick PDF file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) {
        AwesomeSnackbar.error(
          context,
          "Cancelled",
          "No file selected",
        );
        return;
      }

      File file = File(result.files.single.path!);

      // 2. Ask user for Title
      String? title = await showDialog<String>(
        context: context,
        builder: (context) {
          final TextEditingController _titleController = TextEditingController();
          return AlertDialog(
            title: const Text("Enter Document Title"),
            content: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "e.g. Blood Report",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, _titleController.text.trim()),
                child: const Text("Upload"),
              ),
            ],
          );
        },
      );

      if (title == null || title.isEmpty) {
        AwesomeSnackbar.error(
          context,
          "Missing",
          "Title is required",
        );
        return;
      }

      // 3. Get JWT Token
      String? token = await SecureStorageService().getJwtToken();
      if (token == null) {
        AwesomeSnackbar.error(
          context,
          "Error",
          "Not logged in. Please login again.",
        );
        return;
      }

      // 4. Create Multipart Request
      var uri = Uri.parse("http://192.168.0.107:8000/api/reports/report/");
      var request = http.MultipartRequest("POST", uri);

      request.headers["Authorization"] = "$token";
      request.files.add(await http.MultipartFile.fromPath("file", file.path));
      request.fields["title"] = title;

      // 5. Send Request
      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AwesomeSnackbar.success(
          context,
          "Success",
          "Document uploaded successfully!",
        );
      } else {
        final responseBody = await response.stream.bytesToString();
        AwesomeSnackbar.error(
          context,
          "Upload Failed",
          responseBody,
        );
      }
    } catch (e) {
      print("Upload error: $e");
      AwesomeSnackbar.error(
        context,
        "Error",
        "Something went wrong while uploading.",
      );
    }
  }

  void _showNearestAshaBottomSheet() {
    String selectedRegion = "All";
    List<Map<String, dynamic>> filtered = List.from(_mockAshaWorkers);
    final TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            void _filterResults() {
              final query = searchController.text.trim().toLowerCase();
              setStateSB(() {
                filtered = _mockAshaWorkers.where((w) {
                  final matchesRegion = selectedRegion == "All" || w['region'] == selectedRegion;
                  final matchesQuery = query.isEmpty ||
                      w['name'].toString().toLowerCase().contains(query) ||
                      w['region'].toString().toLowerCase().contains(query);
                  return matchesRegion && matchesQuery;
                }).toList()
                  ..sort((a, b) => (a['distance_km'] as double).compareTo(b['distance_km'] as double));
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Nearest ASHA / Regional Workers",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.my_location_outlined),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Use my location: (stub) — add geolocation integration.")),
                          );
                        },
                        tooltip: "Use my location",
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Region filter + search
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedRegion,
                          items: <String>["All", "Wadala", "Kurla", "Ghatkopar", "Andheri"]
                              .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                              .toList(),
                          onChanged: (v) {
                            selectedRegion = v ?? "All";
                            _filterResults();
                          },
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            labelText: "Region",
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: searchController,
                          onChanged: (val) => _filterResults(),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.search),
                            labelText: "Search name or region",
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ASHA Foundation Link
                  GestureDetector(
                    onTap: () async {
                      final url = Uri.parse('https://nhm.gov.in/index1.php?lang=1&level=1&sublinkid=150&lid=226');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not launch $url')),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            "Learn more about ASHA foundation",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Results list
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                    child: filtered.isEmpty
                        ? const Center(child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text("No workers found in this area."),
                          ))
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (_, i) {
                              final w = filtered[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: w['available'] ? const Color(0xFFFCA311) : Colors.grey,
                                  child: Text(w['name'].toString().split(' ').last[0]),
                                ),
                                title: Text(w['name']),
                                subtitle: Text('${w['region']} • ${w['distance_km']} km'),
                                trailing: Wrap(
                                  spacing: 8,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.call),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Call ${w['phone']} (stub)")),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.map_outlined),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Open map for ${w['name']} (stub)")),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  showDialog(
                                    context: ctx,
                                    builder: (dCtx) {
                                      return AlertDialog(
                                        title: Text(w['name']),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Region: ${w['region']}"),
                                            Text("Distance: ${w['distance_km']} km"),
                                            Text("Phone: ${w['phone']}"),
                                            const SizedBox(height: 8),
                                            Text(w['available'] ? "Available now" : "Currently unavailable"),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text("Close")),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(dCtx);
                                              Navigator.pop(ctx);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("Request sent to ${w['name']} (stub)")),
                                              );
                                            },
                                            child: const Text("Request Visit"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNearestAshaSection(bool isDark) {
    return InkWell(
      onTap: _showNearestAshaBottomSheet,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDark ? const Color(0xFF0F1724).withOpacity(0.3) : Colors.white,
              isDark ? const Color(0xFF0F1724).withOpacity(0.1) : const Color(0xFFF8F9FA),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFEDEDED),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFFCA311).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_hospital_outlined, size: 34, color: Color(0xFFFCA311)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Find Nearest ASHA / Regional Worker",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF14213D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Locate nearby community health workers for home visits and local support.",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white.withOpacity(0.8) : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final url = Uri.parse('https://nhm.gov.in/index1.php?lang=1&level=1&sublinkid=150&lid=226');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not launch $url')),
                        );
                      }
                    },
                    child: Text(
                      "Learn more about ASHA foundation",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _showNearestAshaBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFCA311),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Find"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFAFAFA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              children: [
                // Aesthetic Banner
                _buildTopBanner(isDark),
                
                SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        
                        // ASHA Worker Section
                        _buildNearestAshaSection(isDark),
                        const SizedBox(height: 32),
                        
                        // Upload Section
                        _buildUploadSection(isDark),
                        const SizedBox(height: 32),

                        // Quick Access Section
                        _buildQuickAccessSection(isDark),
                        const SizedBox(height: 32),

                        // Features & Offers Section
                        _buildFeaturesSection(isDark),
                        const SizedBox(height: 32),

                        // Assurance Section
                        _buildAssuranceSection(isDark),
                        const SizedBox(height: 32),

                        // Footer
                        _buildFooter(isDark),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBanner(bool isDark) {
    return Container(
      width: double.infinity,
      height: 280,
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark
                ? const Color(0xFF14213D)
                : const Color(0xFF14213D).withOpacity(0.9),
            isDark
                ? const Color(0xFF14213D).withOpacity(0.8)
                : const Color(0xFF14213D).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Doctor Image
          Positioned(
            right: 5,
            bottom: 0,
            child: Container(
              height: 260,
              width: 200,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(24),
                ),
                child: Image.asset(
                  'assets/doctor.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Text Content
          Positioned(
            left: 28,
            top: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.48,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.health_and_safety,
                        color: const Color(0xFFFCA311),
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Get Medical',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  const Padding(
                    padding: EdgeInsets.only(left: 38),
                    child: Text(
                      'Assistance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.only(left: 38),
                    child: Text(
                      'in Seconds',
                      style: TextStyle(
                        color: Color(0xFFFCA311),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(bool isDark) {
    return InkWell(
      onTap: _handleFileUpload,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDark
                  ? const Color(0xFF14213D).withOpacity(0.3)
                  : Colors.white,
              isDark
                  ? const Color(0xFF14213D).withOpacity(0.1)
                  : const Color(0xFFF8F9FA),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? const Color(0xFF14213D).withOpacity(0.5)
                : const Color(0xFFE5E5E5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFCA311).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                size: 40,
                color: Color(0xFFFCA311),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Upload Your Medical Documents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF14213D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'PDF format for a consolidated health record',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFFE5E5E5).withOpacity(0.8)
                    : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFCA311),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFCA311).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upload_file, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Upload Document',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(bool isDark) {
    final features = [
      {
        'icon': Icons.medical_services_outlined,
        'label': 'Immediate\nDiagnosis',
        'color': const Color(0xFFFCA311),
      },
      {
        'icon': Icons.people_outline,
        'label': 'Communities',
        'color': const Color(0xFFFCA311),
      },
      {
        'icon': Icons.smart_toy_outlined,
        'label': 'AI Chat',
        'color': const Color(0xFFFCA311),
      },
      {
        'icon': Icons.restaurant_outlined,
        'label': 'Nutrition',
        'color': const Color(0xFFFCA311),
      },
      {
        'icon': Icons.summarize_outlined,
        'label': 'Report\nSummary',
        'color': const Color(0xFFFCA311),
      },
      {
        'icon': Icons.medication_outlined,
        'label': 'Medicines',
        'color': const Color(0xFFFCA311),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF14213D),
          ),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return _buildFeatureButton(
              icon: feature['icon'] as IconData,
              label: feature['label'] as String,
              color: feature['color'] as Color,
              isDark: isDark,
              index: index,
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required int index,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF14213D).withOpacity(0.3)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFE5E5E5)
                          : const Color(0xFF14213D),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesSection(bool isDark) {
    final offers = [
      {
        'title': '24/7 AI Support',
        'subtitle': 'Get instant health guidance',
        'icon': Icons.support_agent,
      },
      {
        'title': 'Expert Consultation',
        'subtitle': 'Connect with certified doctors',
        'icon': Icons.medical_services,
      },
      {
        'title': 'Smart Health Tracking',
        'subtitle': 'Monitor your wellness journey',
        'icon': Icons.trending_up,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Best Features & Offers',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF14213D),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return Container(
                width: 280,
                margin: EdgeInsets.only(
                  right: 16,
                  left: index == 0 ? 4 : 0,
                ),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFCA311).withOpacity(0.8),
                      const Color(0xFFFCA311).withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFCA311).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        offer['icon'] as IconData,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      offer['title'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      offer['subtitle'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAssuranceSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF14213D).withOpacity(0.2)
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF14213D).withOpacity(0.3)
              : const Color(0xFFE5E5E5),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFCA311).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              color: Color(0xFFFCA311),
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No more medical worries',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? const Color(0xFFFCA311)
                  : const Color(0xFF14213D),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We simplify your health journey, connecting you with top-tier care and answers you can trust, all at your fingertips. Focus on living, we\'ll handle the rest.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: isDark
                  ? const Color(0xFFE5E5E5).withOpacity(0.8)
                  : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Designed with ',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? const Color(0xFFE5E5E5).withOpacity(0.6)
                  : Colors.grey[500],
            ),
          ),
          const Text(
            '❤️',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            ' for your well-being',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? const Color(0xFFE5E5E5).withOpacity(0.6)
                  : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}