import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/user_profile_service.dart';
import 'services/allergy_service.dart';
import 'models/allergy.dart';

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
  final TextEditingController _allergySearchController = TextEditingController();
  final TextEditingController _customAllergyController = TextEditingController();
  
  final AllergyService _allergyService = AllergyService();
  final FocusNode _allergySearchFocusNode = FocusNode();
  
  String _selectedLanguage = "English";
  List<String> _selectedAllergies = [];
  List<Allergy> _allergySuggestions = [];
  bool _isLoadingAllergies = false;
  bool _showCustomAllergyInput = false;
  String _customAllergyCategory = 'other';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAllergySuggestions();
    _allergySearchController.addListener(_onSearchChanged);
  }

  void _loadUserData() {
    final profileService = Provider.of<UserProfileService>(context, listen: false);
    
    _nameController.text = profileService.name ?? "Guest";
    _ageController.text = profileService.age?.toString() ?? "25";
    _locationController.text = profileService.country ?? "Bangkok";
    _selectedLanguage = profileService.language ?? "English";
    _selectedAllergies = List.from(profileService.allergies);
  }

  void _loadAllergySuggestions() async {
    setState(() => _isLoadingAllergies = true);
    final allergies = await _allergyService.getCommonAllergies();
    setState(() {
      _allergySuggestions = allergies;
      _isLoadingAllergies = false;
    });
  }

  void _onSearchChanged() async {
    final query = _allergySearchController.text.trim();
    
    if (query.isEmpty) {
      _loadAllergySuggestions();
      return;
    }

    setState(() => _isLoadingAllergies = true);
    final results = await _allergyService.searchAllergies(query);
    setState(() {
      _allergySuggestions = results;
      _isLoadingAllergies = false;
    });
  }

  void _saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final profileService = Provider.of<UserProfileService>(context, listen: false);
      
      profileService.updateProfile(
        name: _nameController.text,
        age: int.tryParse(_ageController.text),
        country: _locationController.text,
        language: _selectedLanguage,
        allergies: _selectedAllergies,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Profile saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  void _addAllergy(String allergyName) {
    final allergy = allergyName.trim().toLowerCase();
    if (allergy.isNotEmpty && !_selectedAllergies.contains(allergy)) {
      setState(() {
        _selectedAllergies.add(allergy);
        _allergySearchController.clear();
        _showCustomAllergyInput = false;
      });
      _loadAllergySuggestions(); // Reset suggestions
    }
  }

  void _addCustomAllergy() async {
    final allergyName = _customAllergyController.text.trim();
    if (allergyName.isEmpty) return;

    setState(() => _isLoadingAllergies = true);
    
    try {
      // Validate if allergy exists in database
      final exists = await _allergyService.validateAllergy(allergyName);
      
      if (!exists) {
        // Add as custom allergy
        final customAllergy = await _allergyService.addCustomAllergy(
          allergyName, 
          category: _customAllergyCategory
        );
        _addAllergy(customAllergy.name);
      } else {
        _addAllergy(allergyName);
      }
    } catch (e) {
      // Fallback: add directly
      _addAllergy(allergyName);
    } finally {
      setState(() {
        _isLoadingAllergies = false;
        _customAllergyController.clear();
        _showCustomAllergyInput = false;
      });
    }
  }

  void _removeAllergy(String allergy) {
    setState(() {
      _selectedAllergies.remove(allergy);
    });
  }

  void _showAllergyInfo(Allergy allergy) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(allergy.name.toUpperCase()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${_allergyService.getCategoryDisplayName(allergy.category)}'),
            Text('Severity: ${allergy.severity}'),
            const SizedBox(height: 8),
            Text(allergy.description),
            const SizedBox(height: 8),
            Text(
              _allergyService.getSeverityDescription(allergy.severity),
              style: TextStyle(
                color: allergy.severity == 'severe' ? Colors.red : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              _addAllergy(allergy.name);
              Navigator.pop(context);
            },
            child: const Text('Add to My Allergies'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
            tooltip: 'Save Profile',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Personal Info Section
              _buildSectionHeader('Personal Information'),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name', 
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Enter your full name'
                ),
                validator: (v) => v!.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age', 
                  prefixIcon: Icon(Icons.calendar_today),
                  hintText: 'Enter your age'
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return "Age is required";
                  final age = int.tryParse(v);
                  if (age == null || age < 1 || age > 120) return "Enter valid age (1-120)";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location & Language Section
              _buildSectionHeader('Location & Preferences'),
              
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Current City/Country', 
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'e.g., Bangkok, Thailand'
                ),
                validator: (v) => v!.isEmpty ? "Location is required" : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: const InputDecoration(
                  labelText: 'Preferred Language', 
                  prefixIcon: Icon(Icons.translate)
                ),
                items: [
                  "English", "Spanish", "French", "Chinese", 
                  "Japanese", "Thai", "Korean", "German", "Italian"
                ].map((lang) {
                  return DropdownMenuItem(value: lang, child: Text(lang));
                }).toList(),
                onChanged: (v) => setState(() => _selectedLanguage = v!),
              ),
              const SizedBox(height: 24),

              // Dynamic Allergy Management Section
              _buildSectionHeader('Food Allergies & Restrictions'),
              
              Text(
                'Search and add your food allergies. The AI will warn you about unsafe foods.',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 12),

              // Allergy Search
              TextFormField(
                controller: _allergySearchController,
                focusNode: _allergySearchFocusNode,
                decoration: InputDecoration(
                  labelText: 'Search Allergies',
                  hintText: 'e.g., nuts, dairy, gluten',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _isLoadingAllergies 
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() => _showCustomAllergyInput = true),
                        ),
                ),
              ),
              const SizedBox(height: 8),

              // Custom Allergy Input
              if (_showCustomAllergyInput) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _customAllergyController,
                        decoration: const InputDecoration(
                          labelText: 'Custom Allergy',
                          hintText: 'Enter allergy name'
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _customAllergyCategory,
                      items: _allergyService.getAllergyCategories().map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(_allergyService.getCategoryDisplayName(category)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _customAllergyCategory = v!),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: _addCustomAllergy,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => setState(() => _showCustomAllergyInput = false),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Allergy Suggestions
              if (_allergySuggestions.isNotEmpty) ...[
                Text(
                  'Suggestions:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allergySuggestions.take(10).map((allergy) {
                    return FilterChip(
                      label: Text(allergy.name),
                      selected: _selectedAllergies.contains(allergy.name),
                      onSelected: (selected) {
                        if (selected) {
                          _addAllergy(allergy.name);
                        } else {
                          _removeAllergy(allergy.name);
                        }
                      },
                    );
                  }).toList(),
                ),
                if (_allergySuggestions.length > 10) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${_allergySuggestions.length - 10} more suggestions...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
                const SizedBox(height: 16),
              ],

              // Selected Allergies
              if (_selectedAllergies.isNotEmpty) ...[
                Text(
                  'Your Allergies:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedAllergies.map((allergy) {
                    return Chip(
                      label: Text(allergy),
                      onDeleted: () => _removeAllergy(allergy),
                      deleteIconColor: Colors.red,
                      backgroundColor: Colors.teal[50],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ] else ...[
                Text(
                  'No allergies added. Search above to add your food restrictions.',
                  style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
              ],

              // Common Allergies Quick Section
              FutureBuilder<Map<String, List<Allergy>>>(
                future: _allergyService.getAllergiesByCategory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Text('Error loading allergy categories');
                  }

                  final categorizedAllergies = snapshot.data!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Common by Category:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ...categorizedAllergies.entries.map((entry) {
                        if (entry.value.isEmpty) return const SizedBox();
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _allergyService.getCategoryDisplayName(entry.key),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: entry.value.map((allergy) {
                                return ActionChip(
                                  label: Text(allergy.name),
                                  onPressed: () => _showAllergyInfo(allergy),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }).toList(),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Profile Status
              Consumer<UserProfileService>(
                builder: (context, profileService, child) {
                  return Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profile Status: ${profileService.isProfileComplete ? "Complete" : "Incomplete"}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                  ),
                                ),
                                Text(
                                  'Allergies: ${_selectedAllergies.length} registered',
                                  style: TextStyle(color: Colors.green[700]),
                                ),
                                if (_selectedAllergies.isNotEmpty) ...[
                                  Text(
                                    'Security Level: ${_getSecurityLevel()}',
                                    style: TextStyle(color: Colors.green[700]),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSecurityLevel() {
    if (_selectedAllergies.isEmpty) return 'Basic';
    return 'Enhanced Protection';
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 16),
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