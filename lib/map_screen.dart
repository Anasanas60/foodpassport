import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> locations = [
      {"name": "Pad Thai", "city": "Bangkok", "lat": 13.7563, "lng": 100.5018},
      {"name": "Tom Yum", "city": "Chiang Mai", "lat": 18.7883, "lng": 98.9853},
      {"name": "Mango Sticky Rice", "city": "Phuket", "lat": 7.8804, "lng": 98.3923},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Food Map 🗺️'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Foods I’ve Tried', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  var loc = locations[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_pin, color: Colors.red),
                      title: Text(loc["name"]),
                      subtitle: Text(loc["city"]),
                      trailing: Text("${loc["lat"]}, ${loc["lng"]}"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}