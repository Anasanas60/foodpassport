import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/user_profile_service.dart';
import 'user_form_screen.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  bool _avoidNuts = false;
  bool _avoidDairy = false;
  bool _avoidGluten = false;
  bool _isVegan = false;
  List<String> _additionalAllergies = [];

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  void _loadUserPreferences() {
    final profileService =
        Provider.of<UserProfileService>(context, listen: false);

    _nameController.text = profileService.name ?? "Guest";
    final allergies = profileService.allergies;
    _updatePreferencesFromAllergies(allergies);
  }

  void _updatePreferencesFromAllergies(List<String> allergies) {
    setState(() {
      _avoidNuts =
          allergies.any((allergy) => _matchesAllergy(allergy, ['nut', 'peanut']));
      _avoidDairy = allergies
          .any((allergy) => _matchesAllergy(allergy, ['dairy', 'milk', 'cheese']));
      _avoidGluten = allergies.any(
          (allergy) => _matchesAllergy(allergy, ['gluten', 'wheat', 'barley']));
      _isVegan = allergies.any((allergy) =>
          _matchesAllergy(allergy, ['vegan', 'meat', 'fish', 'egg', 'dairy']));
      _additionalAllergies = allergies
          .where((allergy) => !_matchesAllergy(allergy, [
                'nut',
                'peanut',
                'dairy',
                'milk',
                'cheese',
                'gluten',
                'wheat',
                'barley',
                'vegan'
              ]))
          .toList();
    });
  }

  bool _matchesAllergy(String allergy, List<String> keywords) {
    return keywords.any((keyword) => allergy.toLowerCase().contains(keyword));
  }

  void _savePreferences() {
    if (_formKey.currentState?.validate() ?? false) {
      final profileService =
          Provider.of<UserProfileService>(context, listen: false);
      final List<String> newAllergies = [];
      if (_avoidNuts) newAllergies.addAll(['nuts', 'peanuts']);
      if (_avoidDairy) newAllergies.addAll(['dairy', 'milk']);
      if (_avoidGluten) newAllergies.addAll(['gluten', 'wheat']);
      if (_isVegan) newAllergies.addAll(['vegan', 'meat', 'fish', 'eggs', 'dairy']);
      newAllergies.addAll(_additionalAllergies);
      final uniqueAllergies = newAllergies.toSet().toList();

      profileService.updateProfile(
        name: _nameController.text,
        allergies: uniqueAllergies,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Preferences saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  void _navigateToFullProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserFormScreen()),
    ).then((_) {
      _loadUserPreferences();
    });
  }

  void _showAllergyManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Additional Allergies'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Add custom allergies not covered by the main categories:'),
              const SizedBox(height: 16),
              if (_additionalAllergies.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _additionalAllergies.map((allergy) {
                    return Chip(
                      label: Text(allergy),
                      onDeleted: () {
                        setState(() {
                          _additionalAllergies.remove(allergy);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                decoration: const InputDecoration(
                    labelText: 'New Allergy',
                    hintText: 'e.g., sesame, mustard'),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty &&
                      !_additionalAllergies
                          .contains(value.trim().toLowerCase())) {
                    setState(() {
                      _additionalAllergies.add(value.trim().toLowerCase());
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dietary Settings'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _navigateToFullProfile,
            tooltip: 'Edit Full Profile',
          ),
        ],
      ),
      body: Consumer<UserProfileService>(
        builder: (context, profileService, child) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.person_outline, size: 20),
                              SizedBox(width: 8),
                              Text('Profile Summary',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('👤 Name: ${profileService.name ?? "Not set"}'),
                          Text('🎂 Age: ${profileService.age ?? "Not set"}'),
                          Text(
                              '📍 Location: ${profileService.country ?? "Not set"}'),
                          Text(
                              '⚠️ Allergies: ${profileService.allergies.length} registered'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _navigateToFullProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                            child: const Text('📝 Edit Full Profile'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Icon(Icons.settings, size: 20),
                      SizedBox(width: 8),
                      Text('Quick Dietary Restrictions',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildPreferenceCheckbox(
                    '🚫 Avoid Nuts & Peanuts',
                    'Prevents foods containing nuts, peanuts, and tree nuts',
                    _avoidNuts,
                    (value) => setState(() => _avoidNuts = value ?? false),
                  ),
                  _buildPreferenceCheckbox(
                    '🥛 Avoid Dairy Products',
                    'Prevents milk, cheese, yogurt, butter, and other dairy',
                    _avoidDairy,
                    (value) => setState(() => _avoidDairy = value ?? false),
                  ),
                  _buildPreferenceCheckbox(
                    '🌾 Avoid Gluten',
                    'Prevents wheat, barley, rye, and gluten-containing products',
                    _avoidGluten,
                    (value) => setState(() => _avoidGluten = value ?? false),
                  ),
                  _buildPreferenceCheckbox(
                    '🌱 Vegan Diet',
                    'Avoid all animal products including meat, fish, eggs, dairy',
                    _isVegan,
                    (value) => setState(() => _isVegan = value ?? false),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: ListTile(
                      leading: const Icon(Icons.add_circle_outline,
                          color: Colors.orange),
                      title: const Text('Additional Allergies'),
                      subtitle: Text(_additionalAllergies.isEmpty
                          ? 'No additional allergies'
                          : '${_additionalAllergies.length} custom allergies'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: _showAllergyManagementDialog,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (profileService.allergies.isNotEmpty) ...[
                    const Text('📋 Your Current Allergies:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: profileService.allergies.map((allergy) {
                        return Chip(
                          label: Text(allergy),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Card(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📊 Allergy Statistics',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                              '• Main categories: ${[_avoidNuts, _avoidDairy, _avoidGluten, _isVegan].where((e) => e).length} active'),
                          Text(
                              '• Additional allergies: ${_additionalAllergies.length}'),
                          Text(
                              '• Total restrictions: ${profileService.allergies.length}'),
                          Text(
                              '• Protection level: ${_getProtectionLevel(profileService.allergies.length)}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _savePreferences,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('💾 Save Preferences',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _avoidNuts = false;
                        _avoidDairy = false;
                        _avoidGluten = false;
                        _isVegan = false;
                        _additionalAllergies.clear();
                      });
                    },
                    child: const Text('🔄 Reset to Default'),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('💡 How it works:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          '• Your name syncs across all app sections\n'
                          '• Checkboxes automatically manage allergy detection\n'
                          '• Use "Additional Allergies" for custom restrictions\n'
                          '• AI food scanning will warn you about unsafe foods\n'
                          '• Changes here update your main profile automatically',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getProtectionLevel(int allergyCount) {
    if (allergyCount == 0) return 'Basic';
    if (allergyCount <= 3) return 'Standard';
    if (allergyCount <= 6) return 'Enhanced';
    return 'Maximum';
  }

  Widget _buildPreferenceCheckbox(
      String title, String subtitle, bool value, Function(bool?) onChanged) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: CheckboxListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle:
            Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        value: value,
        onChanged: onChanged,
        secondary: Icon(
          value ? Icons.check_circle : Icons.radio_button_unchecked,
          color: value ? Theme.of(context).colorScheme.primary : Colors.grey,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}