import 'package:flutter/material.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  String userName = "Guest";
  bool avoidNuts = false;
  bool avoidDairy = false;
  bool avoidGluten = false;
  bool isVegan = false;

  void _savePreferences() {
    if (_formKey.currentState?.validate() ?? false) {
      final prefs = {
        'userName': userName,
        'avoidNuts': avoidNuts,
        'avoidDairy': avoidDairy,
        'avoidGluten': avoidGluten,
        'isVegan': isVegan,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Preferences saved!')),
      );
      Navigator.pop(context, prefs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dietary Settings'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Your Restrictions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: userName,
                decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
                onChanged: (v) => setState(() => userName = v),
                validator: (v) => v!.isNotEmpty ? null : "Required",
              ),
              const SizedBox(height: 20),
              ...[
                ("Avoid Nuts", (v) => avoidNuts = v),
                ("Avoid Dairy", (v) => avoidDairy = v),
                ("Avoid Gluten", (v) => avoidGluten = v),
                ("I am Vegan", (v) => isVegan = v),
              ].map((e) => CheckboxListTile(
                    title: Text(e.$1),
                    value: e.$1 == "Avoid Nuts" ? avoidNuts : e.$1 == "Avoid Dairy" ? avoidDairy : e.$1 == "Avoid Gluten" ? avoidGluten : isVegan,
                    onChanged: (v) => setState(() => e.$2(v!)),
                  )),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _savePreferences, child: const Text('Save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}