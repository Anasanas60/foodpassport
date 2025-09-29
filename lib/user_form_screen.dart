import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_profile_service.dart';
import '../services/food_state_service.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _locationController;
  late TextEditingController _dietaryController;

  String _selectedLanguage = 'English';
  List<String> _selectedAllergies = [];
  final List<String> _availableAllergies = [
    'nuts', 'peanuts', 'shellfish', 'dairy', 'eggs',
    'soy', 'wheat', 'fish', 'gluten', 'sesame'
  ];

  @override
  void initState() {
    super.initState();
    final profileService = Provider.of<UserProfileService>(context, listen: false);
    _nameController = TextEditingController(text: profileService.name ?? '');
    _ageController = TextEditingController(text: profileService.age?.toString() ?? '');
    _locationController = TextEditingController(text: profileService.country ?? '');
    _dietaryController = TextEditingController(text: profileService.dietaryPreference ?? '');
    _selectedLanguage = profileService.language ?? 'English';
    _selectedAllergies = profileService.allergies;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _dietaryController.dispose();
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
        allergies: _selectedAllergies,
        dietaryPreference: _dietaryController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      setState(() {
        _isEditing = false;
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profileService = Provider.of<UserProfileService>(context);
    final foodState = Provider.of<FoodStateService>(context);
    final userProfile = profileService.userProfile;

    // Calculate statistics
    final totalDishes = foodState.foodHistory.length;
    final completedChallenges = 7; // Placeholder
    

    if (_isEditing) {
      return _buildEditForm(theme, colorScheme);
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: colorScheme.onPrimary),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Info Card
            _buildUserInfoCard(userProfile, colorScheme, totalDishes, completedChallenges),
            
            const SizedBox(height: 24),
            
            // Settings/Preferences Section
            _buildSettingsSection(theme, colorScheme, userProfile),
            
            const SizedBox(height: 24),
            
            // My Journal Access
            _buildJournalAccess(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(userProfile, ColorScheme colorScheme, int totalDishes, int completedChallenges) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar and Basic Info
            Row(
              children: [
                // User Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getUserInitials(userProfile?.name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile?.name ?? 'Traveler',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Food Adventurer',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Level ${_calculateLevel(totalDishes)} Explorer',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  totalDishes.toString(),
                  'Dishes Identified',
                  Icons.restaurant,
                  colorScheme.primary,
                ),
                _buildStatItem(
                  completedChallenges.toString(),
                  'Challenges Completed',
                  Icons.emoji_events,
                  colorScheme.secondary,
                ),
                _buildStatItem(
                  '5', // Countries explored
                  'Countries',
                  Icons.flag,
                  Colors.amber[700]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSettingsSection(ThemeData theme, ColorScheme colorScheme, userProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferences',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF333333),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Dietary Preferences
        _buildPreferenceCard(
          icon: Icons.restaurant_menu,
          title: 'Dietary Preferences',
          value: userProfile?.dietaryPreference ?? 'Not set',
          color: colorScheme.primary,
        ),
        
        const SizedBox(height: 12),
        
        // Allergies
        _buildPreferenceCard(
          icon: Icons.shield,
          title: 'Food Allergies',
          value: userProfile?.allergies.isEmpty ?? true 
              ? 'None set' 
              : userProfile!.allergies.join(', '),
          color: Colors.orange[700]!,
        ),
        
        const SizedBox(height: 12),
        
        // Language
        _buildPreferenceCard(
          icon: Icons.language,
          title: 'Language',
          value: userProfile?.language ?? 'English',
          color: colorScheme.secondary,
        ),
        
        const SizedBox(height: 12),
        
        // Location
        _buildPreferenceCard(
          icon: Icons.location_on,
          title: 'Location',
          value: userProfile?.country ?? 'Not set',
          color: Colors.green[700]!,
        ),
      ],
    );
  }

  Widget _buildPreferenceCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalAccess(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.menu_book,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'My Food Journal',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your culinary adventures and discoveries',
              style: TextStyle(
                color: Colors.white.withAlpha(204),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to journal screen
                // Navigator.pushNamed(context, '/journal');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Open Journal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(ThemeData theme, ColorScheme colorScheme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: colorScheme.onPrimary),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
              ),
              
              const SizedBox(height: 16),
              
              // Age
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
              
              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Dietary Preference
              TextFormField(
                controller: _dietaryController,
                decoration: InputDecoration(
                  labelText: 'Dietary Preference',
                  hintText: 'e.g., Vegetarian, Vegan, etc.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Allergies
              _buildAllergiesSection(),
              
              const SizedBox(height: 16),
              
              // Language
              DropdownButtonFormField<String>(
                initialValue: _selectedLanguage,
                items: ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese', 'Thai']
                    .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Language',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (val) => setState(() => _selectedLanguage = val ?? 'English'),
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleEditMode,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllergiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Food Allergies',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableAllergies.map((allergy) {
            final isSelected = _selectedAllergies.contains(allergy);
            return FilterChip(
              label: Text(allergy),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedAllergies.add(allergy);
                  } else {
                    _selectedAllergies.remove(allergy);
                  }
                });
              },
              selectedColor: Theme.of(context).colorScheme.primary.withAlpha(100),
              checkmarkColor: Theme.of(context).colorScheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getUserInitials(String? name) {
    if (name == null || name.isEmpty) return 'FP';
    final names = name.split(' ');
    if (names.length == 1) return name.substring(0, 2).toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  int _calculateLevel(int dishes) {
    return (dishes / 10).floor() + 1;
  }
}