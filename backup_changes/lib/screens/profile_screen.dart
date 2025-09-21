import 'package:flutter/material.dart';

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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      isStaff: json['is_staff'],
      aadharNumber: json['aadhar_number'],
      isDoctor: json['is_doctor'],
      isMedicalStore: json['is_medical_store'],
      medicines: (json['medicines'] as List)
          .map((medicine) => Medicine.fromJson(medicine))
          .toList(),
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
      id: json['id'],
      name: json['name'],
      description: json['description'],
      manufacturer: json['manufacturer'],
      expiryDate: json['expiry_date'],
      doses: (json['doses'] as List)
          .map((dose) => Dose.fromJson(dose))
          .toList(),
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

final Map<String, dynamic> mockUserData = {
  "id": 13,
  "name": "rehbar",
  "email": "rehbar@eng.rizvi.edu.in",
  "is_staff": false,
  "aadhar_number": "False",
  "is_doctor": false,
  "is_medical_store": false,
  "medicines": [
    {
      "id": 2,
      "name": "Paracetamol",
      "description": "Pain relief",
      "manufacturer": "ABC Pharma",
      "expiry_date": "2025-12-31",
      "doses": [
        {
          "dose_name": "Morning",
          "description": "After breakfast",
          "dose_time": "08:00:00"
        },
        {
          "dose_name": "Evening",
          "description": "After dinner",
          "dose_time": "20:00:00"
        }
      ]
    },
    {
      "id": 3,
      "name": "Amoxicillin",
      "description": "Antibiotic for bacterial infections",
      "manufacturer": "HealthCare Labs",
      "expiry_date": "2026-05-15",
      "doses": [
        {
          "dose_name": "Morning",
          "description": "Take after breakfast with water",
          "dose_time": "07:30:00"
        },
        {
          "dose_name": "Afternoon",
          "description": "Take after lunch",
          "dose_time": "13:30:00"
        },
        {
          "dose_name": "Night",
          "description": "Take after dinner",
          "dose_time": "21:00:00"
        }
      ]
    }
  ]
};

class profile_screen extends StatefulWidget {
  const profile_screen({super.key});

  @override
  State<profile_screen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<profile_screen> {
  late UserProfile userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        userProfile = UserProfile.fromJson(mockUserData);
        isLoading = false;
      });
    });
  }

  void _showEditProfileModal() {
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [

              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: _buildEditForm(nameController, emailController, aadharController),
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
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFA),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color(0xFF2E7D8F),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            _buildProfileHeader(),
            
            const SizedBox(height: 24),
            
            _buildAccountInfoSection(),
            
            const SizedBox(height: 24),
            
            _buildMedicinesSection(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2E7D8F),
                  const Color(0xFF4A9FB8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                userProfile.name.isNotEmpty ? userProfile.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            userProfile.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D8F),
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            userProfile.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 16),
          
          GestureDetector(
            onTap: _showEditProfileModal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D8F),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  Widget _buildAccountInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              color: const Color(0xFF2E7D8F),
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoRow('User ID', userProfile.id.toString(), Icons.fingerprint),
          
          const SizedBox(height: 12),
          
          _buildInfoRow('Aadhar Number', userProfile.aadharNumber, Icons.credit_card),
          
          const SizedBox(height: 16),
          
          Text(
            'Account Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            children: [
              _buildStatusBadge('Staff', userProfile.isStaff),
              _buildStatusBadge('Doctor', userProfile.isDoctor),
              _buildStatusBadge('Medical Store', userProfile.isMedicalStore),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF2E7D8F),
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
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D8F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive 
            ? const Color(0xFF2E7D8F).withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive 
              ? const Color(0xFF2E7D8F).withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: isActive ? const Color(0xFF2E7D8F) : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? const Color(0xFF2E7D8F) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Medications (${userProfile.medicines.length})',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D8F),
          ),
        ),
        
        const SizedBox(height: 16),
        
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: userProfile.medicines.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildMedicineCard(userProfile.medicines[index]);
          },
        ),
      ],
    );
  }

  Widget _buildMedicineCard(Medicine medicine) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                  color: const Color(0xFF2E7D8F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medication,
                  size: 20,
                  color: Color(0xFF2E7D8F),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D8F),
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      medicine.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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
                child: _buildMedicineDetail('Manufacturer', medicine.manufacturer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMedicineDetail('Expires', medicine.expiryDate),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Dosage Schedule',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          
          const SizedBox(height: 8),
          
          ...medicine.doses.map((dose) => _buildDoseItem(dose)),
        ],
      ),
    );
  }

  Widget _buildMedicineDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDoseItem(Dose dose) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D8F).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF2E7D8F).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 16,
            color: const Color(0xFF2E7D8F),
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D8F),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dose.doseTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                Text(
                  dose.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(TextEditingController nameController, TextEditingController emailController, TextEditingController aadharController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D8F),
          ),
        ),
        
        const SizedBox(height: 20),
        
        _buildEditField('Name', nameController, Icons.person),
        const SizedBox(height: 16),
        
        _buildEditField('Email', emailController, Icons.email),
        const SizedBox(height: 16),
        
        _buildEditField('Aadhar Number', aadharController, Icons.credit_card),
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
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
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Account permissions (cannot be changed)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                children: [
                  _buildStatusBadge('Staff', userProfile.isStaff),
                  _buildStatusBadge('Doctor', userProfile.isDoctor),
                  _buildStatusBadge('Medical Store', userProfile.isMedicalStore),
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
                  backgroundColor: const Color(0xFF2E7D8F),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D8F),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        
        const SizedBox(height: 8),
        
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF2E7D8F),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2E7D8F),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}