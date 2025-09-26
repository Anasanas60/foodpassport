import 'package:flutter/material.dart';

class EmergencyAlertScreen extends StatelessWidget {
  const EmergencyAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.errorContainer.withAlpha((0.1 * 255).round()),
      appBar: AppBar(
        title: const Text('🚨 EMERGENCY ALERT'),
        backgroundColor: theme.colorScheme.error,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, size: 100, color: theme.colorScheme.error),
              const SizedBox(height: 20),
              Text(
                'ALLERGEN DETECTED!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'We detected an ingredient you’re allergic to. Notify staff immediately or seek medical help.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('🚑 Local emergency services notified'), backgroundColor: theme.colorScheme.error),
                  );
                  await Future.delayed(const Duration(seconds: 3));
                  if (!context.mounted) return;
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                ),
                child: const Text('CALL FOR HELP NOW', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: Text('I’m Safe - Go Back', style: TextStyle(color: theme.colorScheme.error)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
