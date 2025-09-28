import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_profile_service.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _locationController;

  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    final profileService = Provider.of<UserProfileService>(context, listen: false);
    _nameController = TextEditingController(text: profileService.name ?? '');
    _ageController = TextEditingController(text: profileService.age?.toString() ?? '');
    _locationController = TextEditingController(text: profileService.country ?? '');
    _selectedLanguage = profileService.language ?? 'English';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final profileService = Provider.of<UserProfileService>(context, listen: false);
      profileService.updateProfile(
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text),
        country: _locationController.text.trim(),
        language: _selectedLanguage,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(icon: Icon(Icons.save, color: theme.colorScheme.onPrimary), onPressed: _saveForm),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  hintText: 'Enter your age',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your age';
                  }
                  final age = int.tryParse(val);
                  if (age == null || age <= 0 || age > 120) {
                    return 'Enter a valid age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                items: ['English', 'Spanish', 'French', 'German', 'Chinese']
                    .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Language',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (val) => setState(() => _selectedLanguage = val ?? 'English'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
