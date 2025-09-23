import 'package:flutter/material.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = "Guest";
  int age = 25;
  String location = "Bangkok";
  String language = "English";

  void _saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ User info saved!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Personal Info', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isNotEmpty ? null : "Required",
                onChanged: (v) => setState(() => name = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: age.toString(),
                decoration: const InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.calendar_today)),
                keyboardType: TextInputType.number,
                validator: (v) => int.tryParse(v!) != null ? null : "Enter valid age",
                onChanged: (v) => setState(() => age = int.tryParse(v) ?? 25),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: location,
                decoration: const InputDecoration(labelText: 'Current City', prefixIcon: Icon(Icons.location_on)),
                validator: (v) => v!.isNotEmpty ? null : "Required",
                onChanged: (v) => setState(() => location = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: language,
                decoration: const InputDecoration(labelText: 'Language', prefixIcon: Icon(Icons.translate)),
                items: ["English", "Spanish", "French", "Chinese", "Japanese", "Thai"].map((lang) {
                  return DropdownMenuItem(value: lang, child: Text(lang));
                }).toList(),
                onChanged: (v) => setState(() => language = v!),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  child: const Text('Save Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}