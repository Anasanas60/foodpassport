import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MenuScanScreen extends StatefulWidget {
  const MenuScanScreen({super.key});

  @override
  State<MenuScanScreen> createState() => _MenuScanScreenState();
}

class _MenuScanScreenState extends State<MenuScanScreen> {
  bool _isScanning = false;
  bool _isImageCaptured = false;
  bool _isRealTimeMode = true;
  File? _capturedImage;
  List<Map<String, dynamic>> _detectedTextItems = [];
  List<Map<String, dynamic>> _translatedItems = [];
  final ImagePicker _imagePicker = ImagePicker();

  // Mock real-time detection data
  final List<Map<String, dynamic>> _mockRealTimeItems = [
    {
      'text': 'Spaghetti Carbonara',
      'bounds': {'x': 50.0, 'y': 100.0, 'width': 200.0, 'height': 30.0},
      'translation': 'Spaghetti Carbonara',
      'allergyWarning': '⚠️ Contains eggs, dairy',
    },
    {
      'text': 'Pizza Margherita',
      'bounds': {'x': 50.0, 'y': 150.0, 'width': 180.0, 'height': 30.0},
      'translation': 'Margherita Pizza',
      'allergyWarning': '⚠️ Contains gluten, dairy',
    },
    {
      'text': 'Tiramisu',
      'bounds': {'x': 50.0, 'y': 200.0, 'width': 120.0, 'height': 30.0},
      'translation': 'Tiramisu',
      'allergyWarning': '⚠️ Contains eggs, dairy',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: _isImageCaptured ? Colors.black : theme.colorScheme.surface,
      appBar: _isImageCaptured 
          ? null 
          : AppBar(
              title: const Text('Menu Translate'),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              centerTitle: true,
            ),
      body: _isImageCaptured && _capturedImage != null
          ? _buildScanningInterface(theme, colorScheme)
          : _buildStartInterface(theme, colorScheme),
    );
  }

  Widget _buildStartInterface(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.secondary, colorScheme.secondary.withAlpha(200)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.translate,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Menu Translator',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Scan restaurant menus and get instant translations with allergy alerts',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          if (!_isScanning) ...[
            ElevatedButton.icon(
              onPressed: _scanMenu,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Menu with Camera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _scanFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose from Gallery'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: BorderSide(color: colorScheme.secondary),
              ),
            ),
          ],
          if (_isScanning) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text('Processing menu image...', style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 40),
          _buildFeatureHighlights(colorScheme),
        ],
      ),
    );
  }

  Widget _buildScanningInterface(ThemeData theme, ColorScheme colorScheme) {
    return Stack(
      children: [
        // Captured Image Background - Full Screen
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.file(
            _capturedImage!,
            fit: BoxFit.cover,
          ),
        ),

        // Semi-transparent Header
        if (_isRealTimeMode) _buildRealTimeHeader(colorScheme),

        // Real-time Text Detection Overlays
        if (_isRealTimeMode) ..._buildRealTimeTextOverlays(),

        // Translation Results Overlays
        ..._buildTranslationOverlays(),

        // Allergy/Info Notifications
        if (_hasAllergyWarnings()) _buildAllergyNotification(),

        // Bottom Action Bar
        _buildBottomActionBar(colorScheme),

        // Processing Indicator
        if (_isScanning) _buildProcessingOverlay(),
      ],
    );
  }

  Widget _buildRealTimeHeader(ColorScheme colorScheme) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(180),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _resetScan,
                  ),
                  Text(
                    'foodpassport',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flash_on, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Point camera at menu text',
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRealTimeTextOverlays() {
    return _mockRealTimeItems.map((item) {
      final bounds = item['bounds'] as Map<String, double>;
      return Positioned(
        left: bounds['x'],
        top: bounds['y'],
        child: Container(
          width: bounds['width'],
          height: bounds['height'],
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.secondary, // Mint Green for translation
              width: 3,
            ),
            color: colorScheme.secondary.withAlpha(40),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildTranslationOverlays() {
    return _translatedItems.map((item) {
      final bounds = item['bounds'] as Map<String, double>;
      return Positioned(
        left: bounds['x']! + bounds['width']! + 8,
        top: bounds['y']! - 40,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(240),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.secondary, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(100),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Translation Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.translate, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Translated',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Translation Text
              Text(
                item['translation'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Allergy Warning
              if (item['allergyWarning'] != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, color: Colors.red[700], size: 12),
                      const SizedBox(width: 4),
                      Text(
                        item['allergyWarning'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildAllergyNotification() {
    return Positioned(
      bottom: 140,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(230),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Allergy Alert: Menu contains common allergens',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(ColorScheme colorScheme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: _isRealTimeMode ? 160 : 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withAlpha(204),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_isRealTimeMode) _buildModeToggle(colorScheme),
            
            // Shutter Button and Actions
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mode Toggle - Dish ID
                  _buildModeButton(
                    icon: Icons.restaurant,
                    label: 'Dish ID',
                    isActive: !_isRealTimeMode,
                    onTap: () => setState(() => _isRealTimeMode = false),
                  ),
                  
                  // Shutter Button
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      color: Colors.transparent,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, size: 32),
                      color: Colors.white,
                      onPressed: _analyzeMenuText,
                    ),
                  ),
                  
                  // Mode Toggle - Translate
                  _buildModeButton(
                    icon: Icons.translate,
                    label: 'Translate',
                    isActive: _isRealTimeMode,
                    onTap: () => setState(() => _isRealTimeMode = true),
                  ),
                ],
              ),
            ),
            
            // Results Panel
            if (_translatedItems.isNotEmpty) _buildResultsPanel(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 80),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(100),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isRealTimeMode = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !_isRealTimeMode ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant,
                      color: !_isRealTimeMode ? Colors.white : Colors.white.withAlpha(150),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Dish ID',
                      style: TextStyle(
                        color: !_isRealTimeMode ? Colors.white : Colors.white.withAlpha(150),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isRealTimeMode = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _isRealTimeMode ? colorScheme.secondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.translate,
                      color: _isRealTimeMode ? Colors.white : Colors.white.withAlpha(150),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Translate',
                      style: TextStyle(
                        color: _isRealTimeMode ? Colors.white : Colors.white.withAlpha(150),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? Colors.white.withAlpha(50) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? Colors.white : Colors.white.withAlpha(100),
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.white.withAlpha(150),
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white.withAlpha(150),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsPanel(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          // Achievement Notification
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.primary),
            ),
            child: Row(
              children: [
                Icon(Icons.celebration, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Menu Translated! +15 XP',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Text(
            '${_translatedItems.length} items translated',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetScan,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('New Scan'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveTranslations,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save to Journal'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withAlpha(180),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            SizedBox(height: 20),
            Text(
              'Analyzing Menu Text...',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Detecting text and translating items',
              style: TextStyle(color: const Color(0x33FFFFFF), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureHighlights(ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_motion, color: colorScheme.secondary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Smart Translation Features',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureItem('Real-time Text Detection', 'Live menu text recognition'),
            _buildFeatureItem('Multi-language Translation', 'Supports 50+ languages'),
            _buildFeatureItem('Allergy Detection', 'Automatic allergen alerts'),
            _buildFeatureItem('Cultural Context', 'Local dish explanations'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: colorScheme.secondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanMenu() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 90,
    );

    if (image != null) {
      setState(() {
        _capturedImage = File(image.path);
        _isImageCaptured = true;
        _isRealTimeMode = true;
      });
    }
  }

  Future<void> _scanFromGallery() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 90,
    );

    if (image != null) {
      setState(() {
        _capturedImage = File(image.path);
        _isImageCaptured = true;
        _isRealTimeMode = true;
      });
    }
  }

  Future<void> _analyzeMenuText() async {
    setState(() {
      _isScanning = true;
    });

    // Simulate OCR processing
    await Future.delayed(const Duration(seconds: 2));

    // Mock translations with allergy detection
    final mockTranslations = [
      {
        'original': 'Spaghetti Carbonara',
        'translation': 'Spaghetti Carbonara',
        'bounds': {'x': 50.0, 'y': 100.0, 'width': 200.0, 'height': 30.0},
        'allergyWarning': 'Contains eggs, dairy',
      },
      {
        'original': 'Pizza Margherita',
        'translation': 'Margherita Pizza',
        'bounds': {'x': 50.0, 'y': 150.0, 'width': 180.0, 'height': 30.0},
        'allergyWarning': 'Contains gluten, dairy',
      },
      {
        'original': 'Tiramisu',
        'translation': 'Tiramisu',
        'bounds': {'x': 50.0, 'y': 200.0, 'width': 120.0, 'height': 30.0},
        'allergyWarning': 'Contains eggs, dairy',
      },
    ];

    setState(() {
      _translatedItems = mockTranslations;
      _isScanning = false;
    });
  }

  void _resetScan() {
    setState(() {
      _isImageCaptured = false;
      _capturedImage = null;
      _detectedTextItems.clear();
      _translatedItems.clear();
      _isRealTimeMode = true;
    });
  }

  void _saveTranslations() {
    // Show achievement notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.celebration, color: colorScheme.secondary),
            const SizedBox(width: 8),
            const Text('Translations saved! +15 XP earned'),
          ],
        ),
        backgroundColor: const Color(0xFFE8F5E8), // FIXED: Replaced Colors.green[50] with constant
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool _hasAllergyWarnings() {
    return _translatedItems.any((item) => item['allergyWarning'] != null);
  }

  // Getter for color scheme in non-build methods
  ColorScheme get colorScheme => Theme.of(context).colorScheme;
}