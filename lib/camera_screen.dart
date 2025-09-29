import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/camera_viewmodel.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  late CameraViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CameraViewModel(context, widget.camera);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _viewModel.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<CameraViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                FutureBuilder<void>(
                  future: viewModel.initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (viewModel.isImageCaptured && viewModel.capturedImage != null) {
                        return SizedBox.expand(
                          child: Image.file(
                            File(viewModel.capturedImage!.path),
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                      return CameraPreview(viewModel.cameraController);
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                _buildHeaderOverlay(context, viewModel),
                _buildRealTimeOverlays(context, viewModel),
                _buildBottomActionBar(context, viewModel),
                if (viewModel.isImageCaptured && viewModel.capturedImage != null)
                  _buildPostScanSheet(context, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderOverlay(BuildContext context, CameraViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Text(
                'foodpassport',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.flash_on, color: colorScheme.onPrimary),
                onPressed: viewModel.toggleFlash,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealTimeOverlays(BuildContext context, CameraViewModel viewModel) {
    return Positioned.fill(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (viewModel.detectedDish != null && !viewModel.isTranslateMode)
                _buildDishRecognitionOverlay(context, viewModel),
              if (viewModel.detectedText != null && viewModel.isTranslateMode)
                _buildTextTranslationOverlay(context, viewModel),
              if (viewModel.detectedAllergens.isNotEmpty)
                _buildAllergyAlertOverlay(context, viewModel),
            ],
          ),
        ),
    );
  }

  Widget _buildDishRecognitionOverlay(BuildContext context, CameraViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant, color: colorScheme.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            viewModel.detectedDish!,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTextTranslationOverlay(BuildContext context, CameraViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.secondary,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Translated',
              style: textTheme.labelSmall?.copyWith(color: colorScheme.onSecondary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.detectedText!,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyAlertOverlay(BuildContext context, CameraViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: colorScheme.onError, size: 16),
          const SizedBox(width: 8),
          Text(
            'Contains: ${viewModel.detectedAllergens.join(', ')}',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onError, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, CameraViewModel viewModel) {
    if (viewModel.isImageCaptured) return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModeButton(
                    context: context,
                    icon: Icons.restaurant,
                    label: 'Dish ID',
                    isActive: !viewModel.isTranslateMode,
                    onTap: viewModel.toggleTranslateMode,
                  ),
                  const SizedBox(width: 16),
                  _buildModeButton(
                    context: context,
                    icon: Icons.translate,
                    label: 'Translate',
                    isActive: viewModel.isTranslateMode,
                    onTap: viewModel.toggleTranslateMode,
                  ),
                ],
              ),
            ),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 32, color: Colors.white),
                onPressed: viewModel.isProcessing ? null : viewModel.takePhoto,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? colorScheme.onPrimary : colorScheme.onPrimary.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: isActive ? colorScheme.onPrimary : colorScheme.onPrimary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostScanSheet(BuildContext context, CameraViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (viewModel.detectedDish != null) _buildAchievementNotification(context),
                const SizedBox(height: 16),
                if (viewModel.detectedDish != null) _buildDishInfoSection(context, viewModel),
                if (viewModel.detectedText != null) _buildTranslationSection(context, viewModel),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: viewModel.retakePhoto,
                        child: const Text('Retake'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: viewModel.saveToJournal,
                        child: const Text('Save to Journal'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementNotification(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.celebration, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Dish Identified! +10 XP',
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishInfoSection(BuildContext context, CameraViewModel viewModel) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          viewModel.detectedDish!,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        if (viewModel.detectedAllergens.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Detected Ingredients:', style: textTheme.titleMedium),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: viewModel.detectedAllergens
                    .map((allergen) => Chip(label: Text(allergen)))
                    .toList(),
              ),
            ],
          ),
        const SizedBox(height: 16),
        Text('Nutrition Information:', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        const Row(
          children: [
            NutritionInfoItem(label: 'Calories', value: '250'),
            SizedBox(width: 16),
            NutritionInfoItem(label: 'Protein', value: '15g'),
            SizedBox(width: 16),
            NutritionInfoItem(label: 'Carbs', value: '30g'),
          ],
        ),
      ],
    );
  }

  Widget _buildTranslationSection(BuildContext context, CameraViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Translated Text:', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(viewModel.detectedText!, style: textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class NutritionInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const NutritionInfoItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(value, style: textTheme.titleLarge),
        Text(label, style: textTheme.bodySmall?.copyWith(color: Colors.grey)),
      ],
    );
  }
}