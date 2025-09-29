import 'package:flutter/material.dart';
import '../models/food_item.dart';

class EmergencyAlertScreen extends StatelessWidget {
  final FoodItem foodItem;

  const EmergencyAlertScreen({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allergens = foodItem.detectedAllergens;

    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        title: const Text('🚨 EMERGENCY ALERT'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_services),
            onPressed: () {
              _showEmergencyContacts(context);
            },
            tooltip: 'Emergency Contacts',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Critical Alert Section
            _buildCriticalAlertSection(context, allergens, colorScheme),
            
            const SizedBox(height: 24),
            
            // Emergency Actions
            _buildEmergencyActions(context, allergens, colorScheme),
            
            const SizedBox(height: 24),
            
            // Food Details
            _buildFoodDetailsCard(foodItem, colorScheme),
            
            const SizedBox(height: 24),
            
            // Safety Information
            _buildSafetyInformation(colorScheme),
            
            const SizedBox(height: 16),
            
            // Safe Return Button
            _buildSafeReturnButton(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalAlertSection(BuildContext context, List<String> allergens, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[600]!, Colors.red[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withAlpha(100),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Warning Icon
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.red[700],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Alert Title
          Text(
            'ALLERGEN EMERGENCY!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Food Name
          Text(
            foodItem.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Detected Allergens
          if (allergens.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                children: [
                  Text(
                    'DETECTED ALLERGENS:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    allergens.map((a) => a.toUpperCase()).join('\n'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmergencyActions(BuildContext context, List<String> allergens, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          'EMERGENCY ACTIONS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
          ),
        ),
        const SizedBox(height: 16),
        
        // Call for Help Button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton(
            onPressed: () => _callForHelp(context, allergens),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emergency, size: 24),
                SizedBox(width: 12),
                Text(
                  'CALL FOR HELP NOW',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Alert Staff Button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: OutlinedButton(
            onPressed: () => _alertStaff(context, allergens),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[700],
              side: BorderSide(color: Colors.red[700]!, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 20),
                SizedBox(width: 12),
                Text(
                  'ALERT RESTAURANT STAFF',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Share Location Button
        Container(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _shareLocation(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[700],
              side: BorderSide(color: Colors.blue[700]!, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 20),
                SizedBox(width: 12),
                Text(
                  'SHARE MY LOCATION',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodDetailsCard(FoodItem foodItem, ColorScheme colorScheme) {
    return Card(
      elevation: 4,
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
                  'FOOD DETAILS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Nutrition Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildNutritionItem('Calories', '${foodItem.calories.round()}', Icons.local_fire_department, Colors.orange),
                _buildNutritionItem('Protein', '${foodItem.protein.round()}g', Icons.fitness_center, Colors.blue),
                _buildNutritionItem('Carbs', '${foodItem.carbs.round()}g', Icons.grain, Colors.green),
                _buildNutritionItem('Fat', '${foodItem.fat.round()}g', Icons.water_drop, Colors.red),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Confidence Score
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.secondary),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, color: colorScheme.secondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detection Confidence',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        Text(
                          '${(foodItem.confidenceScore * 100).toStringAsFixed(1)}% accurate',
                          style: TextStyle(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildNutritionItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyInformation(ColorScheme colorScheme) {
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
                Icon(Icons.medical_information, color: Colors.orange[700], size: 24),
                const SizedBox(width: 12),
                Text(
                  'SAFETY INFORMATION',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildSafetyStep('1. Stop eating immediately', Icons.block, Colors.red),
            _buildSafetyStep('2. Notify staff about allergens', Icons.person, Colors.orange),
            _buildSafetyStep('3. Use epinephrine if prescribed', Icons.medical_services, Colors.red),
            _buildSafetyStep('4. Seek immediate medical attention', Icons.local_hospital, Colors.red),
            _buildSafetyStep('5. Stay calm and monitor symptoms', Icons.psychology, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyStep(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafeReturnButton(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          _confirmSafeReturn(context);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.green[700],
          side: BorderSide(color: Colors.green[700]!, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          'I\'M SAFE - RETURN TO APP',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _callForHelp(BuildContext context, List<String> allergens) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.white),
            SizedBox(width: 8),
            Text('🚑 Alerting emergency services about allergens'),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 4),
      ),
    );

    // Simulate emergency call process
    await Future.delayed(const Duration(seconds: 2));
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Emergency Services Alerted'),
          content: const Text('Help is on the way. Stay calm and wait for assistance.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _alertStaff(BuildContext context, List<String> allergens) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.person, color: Colors.white),
            SizedBox(width: 8),
            Text('Alerting restaurant staff about allergens'),
          ],
        ),
        backgroundColor: Colors.orange[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _shareLocation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.white),
            SizedBox(width: 8),
            Text('Sharing your location with emergency contacts'),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showEmergencyContacts(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildContactItem('Emergency Services', '911', Icons.emergency),
                    _buildContactItem('Poison Control', '1-800-222-1222', Icons.medical_services),
                    _buildContactItem('Local Hospital', '(555) 123-4567', Icons.local_hospital),
                    _buildContactItem('Personal Contact', 'Mom - (555) 987-6543', Icons.person),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(String name, String number, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.red[700], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  number,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.phone, color: Colors.green[700]),
            onPressed: () {
              // In a real app, this would initiate a phone call
            },
          ),
        ],
      ),
    );
  }

  void _confirmSafeReturn(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Safety'),
        content: const Text('Are you sure you\'re safe and want to return to the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('STAY HERE'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
            ),
            child: const Text('I\'M SAFE'),
          ),
        ],
      ),
    );
  }
}