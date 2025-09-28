import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_profile_service.dart';
import '../services/allergy_service.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _avoidNuts = false;
  bool _avoidDairy = false;
  bool _avoidGluten = false;
  bool _isVegan = false;
  List<String> _additionalAllergies = [];
  final TextEditingController _customAllergyController = TextEditingController();

  String _allergyAlertSensitivity = 'moderate+';

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
      _isVegan = allergies.any((e) => e.contains('vegan') || e.contains('meat') || e.contains('egg'));
      _additionalAllergies = allergies.where((e) =>
          !_avoidNuts && !_avoidDairy && !_avoidGluten && !_isVegan
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
    if (_isVegan) newAllergies.addAll(['vegan', 'meat', 'egg', 'dairy']);
    newAllergies.addAll(_additionalAllergies);

    await profileService.updateAllergies(newAllergies.toSet().toList());
    await profileService.updateAllergyAlertSensitivity(_allergyAlertSensitivity);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences saved successfully!')),
    );
  }

  @override
  void dispose() {
    _customAllergyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allergyService = Provider.of<AllergyService>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dietary Preferences'),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: theme.colorScheme.onPrimary),
            onPressed: _savePreferences,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CheckboxListTile(
            title: const Text('Avoid Nuts & Peanuts'),
            value: _avoidNuts,
            activeColor: theme.colorScheme.primary,
            onChanged: (val) => setState(() => _avoidNuts = val ?? false),
          ),
          CheckboxListTile(
            title: const Text('Avoid Dairy'),
            value: _avoidDairy,
            activeColor: theme.colorScheme.primary,
            onChanged: (val) => setState(() => _avoidDairy = val ?? false),
          ),
          CheckboxListTile(
            title: const Text('Avoid Gluten'),
            value: _avoidGluten,
            activeColor: theme.colorScheme.primary,
            onChanged: (val) => setState(() => _avoidGluten = val ?? false),
          ),
          CheckboxListTile(
            title: const Text('Vegan Diet'),
            value: _isVegan,
            activeColor: theme.colorScheme.primary,
            onChanged: (val) => setState(() => _isVegan = val ?? false),
          ),
          const Divider(),
          Text('Allergy Alert Sensitivity', style: theme.textTheme.headlineSmall),
          ListTile(
            title: const Text('All Alerts'),
            leading: Radio<String>(
              value: 'all',
              groupValue: _allergyAlertSensitivity,
              activeColor: theme.colorScheme.secondary,
              onChanged: (val) => setState(() => _allergyAlertSensitivity = val ?? 'moderate+'),
            ),
            trailing: Tooltip(
              message: 'See all allergy alerts regardless of severity.',
              child: const Icon(Icons.info_outline),
            ),
          ),
          ListTile(
            title: const Text('Moderate and Severe Alerts'),
            leading: Radio<String>(
              value: 'moderate+',
              groupValue: _allergyAlertSensitivity,
              activeColor: theme.colorScheme.secondary,
              onChanged: (val) => setState(() => _allergyAlertSensitivity = val ?? 'moderate+'),
            ),
            trailing: Tooltip(
              message: allergyService.getSeverityDescription('moderate'),
              child: const Icon(Icons.info_outline),
            ),
          ),
          ListTile(
            title: const Text('Severe Alerts Only'),
            leading: Radio<String>(
              value: 'severe+',
              groupValue: _allergyAlertSensitivity,
              activeColor: theme.colorScheme.secondary,
              onChanged: (val) => setState(() => _allergyAlertSensitivity = val ?? 'moderate+'),
            ),
            trailing: Tooltip(
              message: allergyService.getSeverityDescription('severe'),
              child: const Icon(Icons.info_outline),
            ),
          ),
          const Divider(),
          Text('Additional Allergies (comma separated)', style: theme.textTheme.headlineSmall),
          TextField(
            controller: _customAllergyController,
            decoration: InputDecoration(
              hintText: 'Sesame, Mustard etc.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(8),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _additionalAllergies
                .map((a) => Chip(
                      label: Text(a),
                      onDeleted: () => setState(() => _additionalAllergies.remove(a)),
                      deleteIconColor: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.primary.withAlpha((0.5 * 255).round()),
                      labelStyle: TextStyle(color: theme.colorScheme.primary),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
