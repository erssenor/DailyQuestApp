import 'package:flutter/material.dart';
import 'colors.dart';
import 'category_quests_screen.dart';
import 'user.dart';
import 'profile_scaffold.dart';

class QuestsCategoryScreen extends StatelessWidget {
  final User user;

  const QuestsCategoryScreen({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width * 0.8;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Non-interactive prompt
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'How will you explore today?',
                style: TextStyle(color: inputTextColor, fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),

            // Land Button (large, bordered)
              ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(buttonWidth, 60),
                backgroundColor: landColorBg,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: landColor, width: 2),
                ),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ProfileScaffold(
                    user: user,
                    body: CategoryQuestsScreen(category: 'Land', user: user),
                  ),
                ));
              },
              child: const Text('Land 🌲'),
            ),
            const SizedBox(height: 12),

            // Sea Button (large, bordered)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(buttonWidth, 60),
                backgroundColor: seaColorBg,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: seaColor, width: 2),
                ),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ProfileScaffold(
                    user: user,
                    body: CategoryQuestsScreen(category: 'Sea', user: user),
                  ),
                ));
              },
              child: const Text('Sea 🌊'),
            ),
            const SizedBox(height: 12),

            // Sky Button (large, bordered)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(buttonWidth, 60),
                backgroundColor: skyColorBg,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: skyColor, width: 2),
                ),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ProfileScaffold(
                    user: user,
                    body: CategoryQuestsScreen(category: 'Sky', user: user),
                  ),
                ));
              },
              child: const Text('Sky ☁'),
            ),
          ],
        ),
      ),
    );
  }
}
