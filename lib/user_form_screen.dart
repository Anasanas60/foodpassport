import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/user_profile_service.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _allergySearchController =
      TextEditingController();
  final TextEditingController _customAllergyController =
      TextEditingController();

  final FocusNode _allergySearchFocusNode = FocusNode();

  String _selectedLanguage = "English";
  List<String> _selectedAllergies = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _allergySearchController.addListener(_onSearchChanged);
  }

  void _loadUserData() {
    final profileService =
        Provider.of<UserProfileService>(context, listen: false);
    _nameController.text = profileService.name ?? "Guest";
    _ageController.text = profileService.age?.toString() ?? "25";
    _locationController.text = profileService.country ?? "Bangkok";
    _selectedLanguage = profileService.language ?? "English";
    _selectedAllergies = List.from(profileService.allergies);
  }

  void _onSearchChanged() async {
    final query = _allergySearchController.text.trim();
    if (query.isEmpty) {
      return;
    }
  }

  void _saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final profileService =
          Provider.of<UserProfileService>(context, listen: false);
      profileService.updateProfile(
        name: _nameController.text,
        age: int.tryParse(_ageController.text),
        country: _locationController.text,
        language: _selectedLanguage,
        allergies: _selectedAllergies,
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Row(children: [
          Icon(Icons.verified, color: Colors.white),
          SizedBox(width: 8),
          Text('✅ Traveler profile updated successfully!')
        ]),
        backgroundColor: Color(0xFF1a237e),
      ));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildPassportHeader(),
            const SizedBox(height: 20),
            _buildTravelerSectionHeader('Personal Information'),
            _buildPassportFormField(
              controller: _nameController,
              label: 'Name',
              icon: Icons.person,
              hint: 'Enter your name',
            ),
            const SizedBox(height: 16),
            _buildPassportFormField(
              controller: _ageController,
              label: 'Age',
              icon: Icons.cake,
              hint: 'Enter your age',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildPassportFormField(
              controller: _locationController,
              label: 'Location',
              icon: Icons.location_on,
              hint: 'Enter your location',
            ),
            const SizedBox(height: 20),
            _buildTravelerSectionHeader('Language'),
            _buildPassportDropdown(
              initialValue: _selectedLanguage,
              label: 'Language',
              icon: Icons.language,
              items: ['English', 'Spanish', 'French', 'German', 'Chinese'],
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildTravelerSectionHeader('Allergies'),
            _buildAllergySelection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPassportHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFffd700), width: 2)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1a237e), Color(0xFF283593)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFFffd700), width: 2)),
                  child: const Icon(Icons.airplane_ticket,
                      color: Colors.white, size: 30)),
              const SizedBox(width: 16),
              const Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('TRAVELER PROFILE PASSPORT',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1)),
                    SizedBox(height: 4),
                    Text(
                        'Manage your travel preferences and safety advisories',
                        style: TextStyle(fontSize: 12, color: Colors.white70))
                  ]))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTravelerSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: const Color(0xFF1a237e),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFffd700))),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1)),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPassportFormField(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      required String hint,
      String? Function(String?)? validator,
      TextInputType keyboardType = TextInputType.text,
      Widget? suffixIcon}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF1a237e)),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFffd700), width: 2))),
      validator: validator,
    );
  }

  Widget _buildPassportDropdown(
      {required String initialValue,
      required String label,
      required IconData icon,
      required List<String> items,
      required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      initialValue: initialValue,
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1a237e)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFffd700), width: 2))),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildAllergySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ... allergy search and display widgets ...
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _allergySearchController.dispose();
    _customAllergyController.dispose();
    _allergySearchFocusNode.dispose();
    super.dispose();
  }
}
