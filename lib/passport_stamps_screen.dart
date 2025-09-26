import 'package:flutter/material.dart';
import 'models/passport_stamp.dart';

class PassportStampsScreen extends StatefulWidget {
  const PassportStampsScreen({super.key});
  @override State<PassportStampsScreen> createState() => _PassportStampsScreenState();
}

class _PassportStampsScreenState extends State<PassportStampsScreen> {
  final List<PassportStamp> stamps = [];
  @override void initState() {
    super.initState();
    _loadSampleStamps();
  }
  void _loadSampleStamps() {
    stamps.add(PassportStamp.basic(foodName: 'Pad Thai', date: DateTime.now(), location: 'Thailand'));
    stamps.add(PassportStamp.basic(foodName: 'Pizza', date: DateTime.now(), location: 'Italy'));
    stamps.add(PassportStamp.basic(foodName: 'Sushi', date: DateTime.now(), location: 'Japan'));
    setState(() {});
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Food Passport')),
      body: ListView.builder(itemCount: stamps.length, itemBuilder: (context, index) {
        final stamp = stamps[index];
        return Card(margin: EdgeInsets.all(8), child: ListTile(
          leading: Icon(stamp.icon), title: Text(stamp.foodName), subtitle: Text(stamp.location)
        ));
      }),
    );
  }
}
