import 'package:flutter/material.dart';

import 'colors.dart';
import 'profile_scaffold.dart';
import 'user.dart';

class CelebrationScreen extends StatelessWidget {
  final String? category;
  final User user;

  const CelebrationScreen({required this.user, this.category, super.key});

  @override
  Widget build(BuildContext context) {
    // map category to background color
    Color bg = Colors.white;
    final cat = category?.toLowerCase();
    if (cat == 'land') bg = landColor;
    if (cat == 'sea') bg = seaColor;
    if (cat == 'sky') bg = skyColor;

    final textColor = bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    final body = Container(
      color: bg,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 120)),
              const SizedBox(height: 24),
              Text(
                'Congratulations!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Well done, but can you complete them all today?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor,
                    ),
              ),

              // Return to quests button
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to quests'),
              ),
            ],
          ),
        ),
      ),
    );

    return ProfileScaffold(user: user, body: body);
  }
}
