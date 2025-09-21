import 'dart:convert';
import 'package:flutter/material.dart';
import '../component/QRGenerator.dart';
import '../component/custom_snackbar.dart.dart';
import '../services/info.dart';
import '../services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

// --- MODELS ---
class UserProfile {
  final int id;
  final String name;
  final String email;
  final bool isStaff;
  final String aadharNumber;
  final bool isDoctor;
  final bool isMedicalStore;
  final List<Medicine> medicines;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.isStaff,
    required this.aadharNumber,
    required this.isDoctor,
    required this.isMedicalStore,
    required this.medicines,
  });

  // Default constructor for placeholder
  factory UserProfile.placeholder() {
    return UserProfile(
      id: 0,
      name: "Loading...",
      email: "",
      isStaff: false,
      aadharNumber: "",
      isDoctor: false,
      isMedicalStore: false,
      medicines: [],
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      isStaff: json['is_staff'],
      aadharNumber: json['aadhar_number'],
      isDoctor: json['is_doctor'],
      isMedicalStore: json['is_medical_store'],
      medicines: (json['medicines'] as List?)
          ?.map((medicine) => Medicine.fromJson(medicine))
          .toList() ??
          [],
    );
  }
}

class Medicine {
  final int id;
  final String name;
  final String description;
  final String manufacturer;
  final String expiryDate;
  final List<Dose> doses;

  Medicine({
    required this.id,
    required this.name,
    required this.description,
    required this.manufacturer,
    required this.expiryDate,
    required this.doses,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? 'No description',
      manufacturer: json['manufacturer'] ?? 'Unknown',
      expiryDate: json['expiry_date'] ?? 'N/A',
      doses: (json['doses'] as List?)
          ?.map((dose) => Dose.fromJson(dose))
          .toList() ?? [],
    );
  }

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

  factory Dose.fromJson(Map<String, dynamic> json) {
    return Dose(
      doseName: json['dose_name'],
      description: json['description'],
      doseTime: json['dose_time'],
    );
  }
}

// --- PROFILE SCREEN WIDGET ---
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late UserProfile userProfile = UserProfile.placeholder();
  bool isLoading = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _getUserData();
    _initAnimations();
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
        setState(() {
          userProfile = UserProfile.fromJson(responseData);
          isLoading = false;
        });
      } else {
        final errorData = jsonDecode(response.body);
        print(errorData);
        String errorMessage = "Failed to fetch user data";
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        }
        AwesomeSnackbar.error(context, "Error", errorMessage);
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print(error);
      AwesomeSnackbar.error(
        context,
        "Network Error",
        "Please check your internet connection and try again",
      );
      setState(() {
        isLoading = false;
      });
    }
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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
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

  Future<void> _logout() async {
    var jwt = await SecureStorageService().getJwtToken();
    try {
      const String apiUrl = 'https://codenebula-internal-round-25.onrender.com/api/authentication/logout';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$jwt',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print("Logged out successfully");
        AwesomeSnackbar.success(
            context,
            "Logged out successfully",
            "Please login to get your details again"
        );
        Info().setLoggedIn(false);
      } else {
        final errorData = jsonDecode(response.body);
        print(errorData);
        String errorMessage = "Logout failed";
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        }
        AwesomeSnackbar.error(context, "Logout Failed", errorMessage);
      }
    } catch (error) {
      print(error);
      AwesomeSnackbar.error(
          context,
          "Network Error",
          "Please check your internet connection and try again"
      );
    }
  }

  void _showEditProfileModal() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final TextEditingController nameController = TextEditingController(text: userProfile.name);
    final TextEditingController emailController = TextEditingController(text: userProfile.email);
    final TextEditingController aadharController = TextEditingController(text: userProfile.aadharNumber);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF14213D) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: _buildEditForm(nameController, emailController, aadharController, isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateUserProfile(String newName, String newEmail, String newAadhar) {
    setState(() {
      userProfile = UserProfile(
        id: userProfile.id,
        name: newName,
        email: newEmail,
        isStaff: userProfile.isStaff,
        aadharNumber: newAadhar,
        isDoctor: userProfile.isDoctor,
        isMedicalStore: userProfile.isMedicalStore,
        medicines: userProfile.medicines,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFAFAFA),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? const Color(0xFFFCA311) : const Color(0xFF2E7D8F),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFAFAFA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildProfileHeaderWithQR(isDark),
                const SizedBox(height: 24),
                _buildAccountInfoSection(isDark),
                const SizedBox(height: 24),
                _buildMedicinesSection(isDark),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildProfileHeaderWithQR(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14213D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isDark ? const Color(0xFFFCA311) : const Color(0xFF2E7D8F),
                        isDark ? const Color(0xFFFFD166) : const Color(0xFF4A9FB8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      userProfile.name.isNotEmpty ? userProfile.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF14213D) : Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userProfile.name.isNotEmpty ? userProfile.name : 'User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2E7D8F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  userProfile.email.isNotEmpty ? userProfile.email : 'No email',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.8) : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _showEditProfileModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFFFCA311) : const Color(0xFF2E7D8F),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit,
                          color: isDark ? const Color(0xFF14213D) : Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF14213D) : Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: isDark ? Colors.grey[700] : Colors.grey[200],
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Profile QR Code',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF2E7D8F),
                  ),
                ),
                const SizedBox(height: 8),
                QRGenerator(
                  data: userProfile.email.isNotEmpty ? userProfile.email : 'user@example.com',
                  size: 140,
                  backgroundColor: isDark ? const Color(0xFF14213D) : Colors.white,
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  errorText: 'Could not generate QR',
                  padding: const EdgeInsets.all(12),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scan to share profile',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.8) : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14213D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2E7D8F),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('User ID', userProfile.id.toString(), Icons.fingerprint, isDark),
          const SizedBox(height: 12),
          _buildInfoRow('Aadhar Number', userProfile.aadharNumber.isNotEmpty ? userProfile.aadharNumber : 'Not provided', Icons.credit_card, isDark),
          const SizedBox(height: 16),
          Text(
            'Account Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF2E7D8F),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildStatusBadge('Staff', userProfile.isStaff, isDark),
              _buildStatusBadge('Doctor', userProfile.isDoctor, isDark),
              _buildStatusBadge('Medical Store', userProfile.isMedicalStore, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? const Color(0xFFFCA311) : const Color(0xFF2E7D8F),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.8) : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF2E7D8F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, bool isActive, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? (isDark ? const Color(0xFFFCA311).withOpacity(0.2) : const Color(0xFF2E7D8F).withOpacity(0.1))
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? (isDark ? const Color(0xFFFCA311).withOpacity(0.5) : const Color(0xFF2E7D8F).withOpacity(0.3))
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: isActive
                ? (isDark ? const Color(0xFFFCA311) : const Color(0xFF2E7D8F))
                : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? (isDark ? const Color(0xFFFCA311) : const Color(0xFF2E7D8F))
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicinesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Medications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF2E7D8F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          userProfile.medicines.isNotEmpty
              ? '${userProfile.medicines.length} medications found'
              : 'No medications found',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.8) : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        userProfile.medicines.isNotEmpty
            ? ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: userProfile.medicines.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildMedicineCard(userProfile.medicines[index], isDark);
          },
        )
            : Center(
          child: Text(
            'No medications available',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicineCard(Medicine medicine, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14213D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFFFCA311).withOpacity(0.2) : const Color(0xFF2E7D8F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medication,
                  size: 20,
                  color: isDark ? const Color(0xFFFCA311) : const Color(0xFF2E7D8F),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF2E7D8F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medicine.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.8) : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMedicineDetail('Manufacturer', medicine.manufacturer, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMedicineDetail('Expires', medicine.expiryDate, isDark),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Dosage Schedule',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF2E7D8F),
            ),
          ),
          const SizedBox(height: 8),
          ...medicine.doses.map((dose) => _buildDoseItem(dose, isDark)),
        ],
      ),
    );
  }

  Widget _buildMedicineDetail(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.8) : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF2E7D8F),
          ),
        ),
      ],
    );
  }

  Widget _buildDoseItem(Dose dose, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFFFCA311).withOpacity(0.1) : const Color(0xFF2E7D8F).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFFFCA311).withOpacity(0.2) : const Color(0xFF2E7D8F).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 16,
            color: isDark ? const Color(0xFFFCA311) : const Color(0xFF2E7D8F),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      dose.doseName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFFCA311) : const Color(0xFF2E7D8F),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dose.doseTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.8) : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  dose.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFFE5E5E5).withOpacity(0.8) : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(TextEditingController nameController, TextEditingController emailController, TextEditingController aadharController, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF2E7D8F),
          ),
        ),
        const SizedBox(height: 20),
        _buildEditField('Name', nameController, Icons.person, isDark),
        const SizedBox(height: 16),
        _buildEditField('Email', emailController, Icons.email, isDark),
        const SizedBox(height: 16),
        _buildEditField('Aadhar Number', aadharController, Icons.credit_card, isDark),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lock,
                    size: 16,
                    color: isDark ? const Color(0xFFE5E5E5) : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Account permissions (cannot be changed)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF2E7D8F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildStatusBadge('Staff', userProfile.isStaff, isDark),
                  _buildStatusBadge('Doctor', userProfile.isDoctor, isDark),
                  _buildStatusBadge('Medical Store', userProfile.isMedicalStore, isDark),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _updateUserProfile(
                nameController.text,
                emailController.text,
                aadharController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Profile updated successfully!'),
                  backgroundColor: isDark ? const Color(0xFFFCA311) : const Color(0xFF2E7D8F),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFFFCA311) : const Color(0xFF2E7D8F),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Save Changes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF14213D) : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF2E7D8F),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: isDark ? const Color(0xFFFCA311) : const Color(0xFF2E7D8F),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFFFCA311) : const Color(0xFF2E7D8F),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.3),
              ),
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF14213D).withOpacity(0.5) : Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
