import 'package:flutter/material.dart';

class FoodJournalScreen extends StatelessWidget {
  const FoodJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> stamps = [
      {"dish": "Pad Thai", "location": "Bangkok", "date": "May 5"},
      {"dish": "Tom Yum", "location": "Chiang Mai", "date": "May 7"},
      {"dish": "Mango Sticky Rice", "location": "Phuket", "date": "May 10"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Food Passport 🛂'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Collected Stamps', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8),
                itemCount: stamps.length,
                itemBuilder: (context, index) {
                  var stamp = stamps[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Container(
                          height: 80,
                          color: Colors.orange[100],
                          child: const Icon(Icons.restaurant, size: 40, color: Colors.orange),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(stamp["dish"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(stamp["location"]!, style: const TextStyle(color: Colors.grey)),
                              Text(stamp["date"]!, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
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