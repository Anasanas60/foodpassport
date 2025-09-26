import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/food_state_service.dart';

class CulturalInsightsScreen extends StatefulWidget {
  final String dishName;
  const CulturalInsightsScreen({super.key, required this.dishName});
  @override State<CulturalInsightsScreen> createState() => _CulturalInsightsScreenState();
}

class _CulturalInsightsScreenState extends State<CulturalInsightsScreen> {
  Map<String, dynamic>? _culturalData;
  bool _isLoading = true;

  @override void initState() {
    super.initState();
    _loadCulturalData();
  }

  Future<void> _loadCulturalData() async {
    setState(() {
      _isLoading = false;
      _culturalData = {
        'origin': 'Various Regions', 
        'culturalInfo': 'Cultural information about ' + widget.dishName,
        'history': 'Historical background',
        'etiquette': 'Dining etiquette', 
        'funFact': 'Interesting fact'
      };
    });
  }

  @override Widget build(BuildContext context) {
    // foodState variable removed
    return Scaffold(
      appBar: AppBar(title: Text('Culture: ' + widget.dishName)),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(children: [
        Card(child: Padding(padding: EdgeInsets.all(16), child: Column(children: [
          Icon(Icons.public, size: 48), 
          SizedBox(height: 16),
          Text(_culturalData!['origin'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8), 
          Text('Cultural Heritage'),
        ]))),
        SizedBox(height: 16),
        Card(child: Padding(padding: EdgeInsets.all(16), child: Text(_culturalData!['culturalInfo']))),
      ]),
    );
  }
}

