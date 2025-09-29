import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_profile_service.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _avoidNuts = false;
  bool _avoidDairy = false;
  bool _avoidGluten = false;
  bool _isVegetarian = false;
  bool _isVegan = false;
  List<String> _additionalAllergies = [];
  final TextEditingController _customAllergyController = TextEditingController();

  String _allergyAlertSensitivity = 'moderate';
  String _selectedLanguage = 'English';
  String _selectedCuisine = 'All Cuisines';

  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Italian', 'Japanese'];
  final List<String> _cuisines = ['All Cuisines', 'Italian', 'Japanese', 'Mexican', 'Thai', 'Indian', 'Chinese', 'French'];

  @override
  void initState() {
    super.initState();
    final profileService = Provider.of<UserProfileService>(context, listen: false);
    final allergies = profileService.allergies;
    final sensitivity = profileService.allergyAlertSensitivity;
    _mapAllergiesToPrefs(allergies);
    _allergyAlertSensitivity = sensitivity;
  }

  void _mapAllergiesToPrefs(List<String> allergies) {
    setState(() {
      _avoidNuts = allergies.any((e) => e.contains('nut') || e.contains('peanut'));
      _avoidDairy = allergies.any((e) => e.contains('dairy') || e.contains('milk'));
      _avoidGluten = allergies.any((e) => e.contains('gluten') || e.contains('wheat'));
      _isVegan = allergies.any((e) => e.contains('vegan'));
      _isVegetarian = allergies.any((e) => e.contains('vegetarian'));
      _additionalAllergies = allergies.where((e) =>
          !_avoidNuts && !_avoidDairy && !_avoidGluten && !_isVegan && !_isVegetarian
              ? true
              : false).toList();
    });
  }

  Future<void> _savePreferences() async {
    final profileService = Provider.of<UserProfileService>(context, listen: false);
    List<String> newAllergies = [];
    if (_avoidNuts) newAllergies.addAll(['nuts', 'peanuts']);
    if (_avoidDairy) newAllergies.addAll(['dairy', 'milk']);
    if (_avoidGluten) newAllergies.addAll(['gluten', 'wheat']);
    if (_isVegan) newAllergies.addAll(['vegan', 'meat', 'egg', 'dairy', 'fish']);
    if (_isVegetarian) newAllergies.addAll(['vegetarian', 'meat', 'fish']);
    newAllergies.addAll(_additionalAllergies);

    await profileService.updateAllergies(newAllergies.toSet().toList());
    await profileService.updateAllergyAlertSensitivity(_allergyAlertSensitivity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 8),
            const Text('Preferences saved successfully!'),
          ],
        ),
        backgroundColor: const Color(0xFFE8F5E8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _customAllergyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dietary Preferences'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePreferences,
            tooltip: 'Save Preferences',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDietaryRestrictionsCard(theme, colorScheme),
            const SizedBox(height: 20),
            _buildAllergySensitivityCard(theme, colorScheme),
            const SizedBox(height: 20),
            _buildAdditionalAllergiesCard(theme, colorScheme),
            const SizedBox(height: 20),
            _buildPreferencesCard(theme, colorScheme),
            const SizedBox(height: 30),
            _buildSaveButton(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildDietaryRestrictionsCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Dietary Restrictions',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPreferenceSwitch(
              title: 'Avoid Nuts & Peanuts',
              subtitle: 'Tree nuts, peanuts, and related products',
              value: _avoidNuts,
              onChanged: (val) => setState(() => _avoidNuts = val ?? false),
              colorScheme: colorScheme,
            ),
            _buildPreferenceSwitch(
              title: 'Avoid Dairy',
              subtitle: 'Milk, cheese, yogurt, and dairy products',
              value: _avoidDairy,
              onChanged: (val) => setState(() => _avoidDairy = val ?? false),
              colorScheme: colorScheme,
            ),
            _buildPreferenceSwitch(
              title: 'Avoid Gluten',
              subtitle: 'Wheat, barley, rye, and gluten-containing products',
              value: _avoidGluten,
              onChanged: (val) => setState(() => _avoidGluten = val ?? false),
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 8),
            _buildPreferenceSwitch(
              title: 'Vegetarian',
              subtitle: 'No meat or fish',
              value: _isVegetarian,
              onChanged: (val) {
                setState(() {
                  _isVegetarian = val ?? false;
                  if (_isVegetarian) _isVegan = false;
                });
              },
              colorScheme: colorScheme,
            ),
            _buildPreferenceSwitch(
              title: 'Vegan',
              subtitle: 'No animal products including dairy and eggs',
              value: _isVegan,
              onChanged: (val) {
                setState(() {
                  _isVegan = val ?? false;
                  if (_isVegan) {
                    _isVegetarian = false;
                    _avoidDairy = true;
                  }
                });
              },
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withAlpha(100),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergySensitivityCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text('Allergy Alert Sensitivity',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Choose how sensitive you want allergy alerts to be:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            RadioGroup<String>(
              groupValue: _allergyAlertSensitivity,
              onChanged: (val) {
                if (val != null) setState(() => _allergyAlertSensitivity = val);
              },
              child: Column(
                children: [
                  _buildSensitivityOption(
                    title: 'All Alerts',
                    subtitle: 'Get notified about all potential allergens',
                    value: 'all',
                    groupValue: _allergyAlertSensitivity,
                    color: Colors.blue,
                    onChanged: (val) {
                      if (val != null) setState(() => _allergyAlertSensitivity = val);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSensitivityOption(
                    title: 'Moderate & Severe',
                    subtitle: 'Only moderate and severe allergy risks',
                    value: 'moderate',
                    groupValue: _allergyAlertSensitivity,
                    color: Colors.orange,
                    onChanged: (val) {
                      if (val != null) setState(() => _allergyAlertSensitivity = val);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSensitivityOption(
                    title: 'Severe Only',
                    subtitle: 'Only life-threatening allergy risks',
                    value: 'severe',
                    groupValue: _allergyAlertSensitivity,
                    color: Colors.red,
                    onChanged: (val) {
                      if (val != null) setState(() => _allergyAlertSensitivity = val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensitivityOption({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required Color color,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(20) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle,
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
      ),
    );
  }

  Widget _buildAdditionalAllergiesCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text('Additional Allergies',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Add any other allergies (comma separated):',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customAllergyController,
              decoration: InputDecoration(
                hintText: 'e.g., Sesame, Shellfish, Mustard',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add, color: colorScheme.primary),
                  onPressed: () {
                    final value = _customAllergyController.text.trim();
                    if (value.isNotEmpty) {
                      setState(() {
                        _additionalAllergies.addAll(
                          value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
                        );
                        _customAllergyController.clear();
                      });
                    }
                  },
                ),
              ),
              onSubmitted: (val) {
                if (val.isNotEmpty) {
                  setState(() {
                    _additionalAllergies.addAll(
                      val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
                    );
                    _customAllergyController.clear();
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            if (_additionalAllergies.isNotEmpty) ...[
              Text('Your additional allergies:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF333333)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _additionalAllergies
                    .map((allergy) => Chip(
                          label: Text(allergy),
                          onDeleted: () => setState(() => _additionalAllergies.remove(allergy)),
                          deleteIconColor: colorScheme.primary,
                          backgroundColor: colorScheme.primary.withAlpha(30),
                          labelStyle: TextStyle(color: colorScheme.primary),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text('App Preferences',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDropdownPreference(
              title: 'Preferred Language',
              value: _selectedLanguage,
              items: _languages,
              onChanged: (val) => setState(() => _selectedLanguage = val!),
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16),
            _buildDropdownPreference(
              title: 'Favorite Cuisine',
              value: _selectedCuisine,
              items: _cuisines,
              onChanged: (val) => setState(() => _selectedCuisine = val!),
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownPreference({
    required String title,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _savePreferences,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        child: const Text('Save Preferences',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
