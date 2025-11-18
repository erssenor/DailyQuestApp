// No local File/Uint8List storage needed for thumbnails anymore.
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'colors.dart';
import 'db_helper_User.dart';
import 'temp_db.dart';
import 'quest.dart';
import 'user.dart';
import 'celebration_screen.dart';

class CategoryQuestsScreen extends StatefulWidget {
  final String category;
  final User user;

  const CategoryQuestsScreen({required this.category, required this.user, super.key});

  @override
  State<CategoryQuestsScreen> createState() => _CategoryQuestsScreenState();
}

class _CategoryQuestsScreenState extends State<CategoryQuestsScreen> {
  final ImagePicker _picker = ImagePicker();
  // We no longer store or display picked thumbnails; keep picker for completion flow.
  // Track which quest indices have been completed so we can show 'Completed' and hide action buttons
  final Set<int> _completed = {};

  @override
  void initState() {
    super.initState();

    // Load any persisted completed indices for the signed-in user
    final saved = TempDatabase.completedFor(widget.user.username, widget.category);
    _completed.addAll(saved);
  }

  // Camera option
  Future<void> _takePhoto(int questId) async {
    // Use image_picker to take a photo with the camera
    final XFile? xfile = await _picker.pickImage(source: ImageSource.camera);

    // If no photo was taken, return early
    if (xfile == null) return;

    if (!mounted) return; // avoid using context across async gaps

    // Award XP for completing the quest before navigating
    final quests = TempQuestDatabase.questsForCategory(widget.category);

    // Ensure questId is valid
    if (questId >= 0 && questId < quests.length) {
      final quest = quests[questId];

      // Complete the quest and get awarded XP
      final int xp = quest.completeQuest(quest.difficulty);
      final user = widget.user;
      user.addXp(xp);

      // Update the user with new XP/level in the database
      await DbHelperUser.updateUser(user);

      // persist completion
      TempDatabase.markCompleted(user.username, widget.category, questId);
      setState(() {
        _completed.add(questId);
      });
    }

    // Navigate to CelebrationScreen
    final user = widget.user;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CelebrationScreen(user: user, category: widget.category)));
  }

  // Gallery option
  Future<void> _chooseFromGallery(int questId) async {
    // Use image_picker to pick an image from the gallery
    final XFile? xfile = await _picker.pickImage(source: ImageSource.gallery);

    // If no photo was selected, return early
    if (xfile == null) return;

    if (!mounted) return; // avoid using context across async gaps

    // Award XP for completing the quest before navigating
    final quests = TempQuestDatabase.questsForCategory(widget.category);

    // Ensure questId is valid
    if (questId >= 0 && questId < quests.length) {
      final quest = quests[questId];

      // Complete the quest and get awarded XP
      final int xp = quest.completeQuest(quest.difficulty);
      final user = widget.user;
      user.addXp(xp);

      // Update the user with new XP/level in the database
      await DbHelperUser.updateUser(user);

      // persist completion
      TempDatabase.markCompleted(user.username, widget.category, questId);

      setState(() {
        _completed.add(questId);
      });
    }

    // Navigate to CelebrationScreen
    final user = widget.user;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CelebrationScreen(user: user, category: widget.category)));
  }

  @override
  Widget build(BuildContext context) {
    // Load quests from the temporary database for this category
    final quests = TempQuestDatabase.questsForCategory(widget.category);

    // determine background color for the category
    final String cat = widget.category.toLowerCase();
    Color bg = backgroundColor;
    if (cat == 'land') bg = landColor;
    if (cat == 'sea') bg = seaColor;
    if (cat == 'sky') bg = skyColor;

  // build widgets list for quests
  final double cardWidth = MediaQuery.of(context).size.width * 0.8;
  final List<Widget> questWidgets = quests.asMap().entries.map((entry) {
      final idx = entry.key;
      final Quest quest = entry.value;

      // pick bg and border color according to difficulty
      Color bgColor = easyQuestColorBg;
      Color borderColor = easyQuestColorBoarder;
      switch (quest.difficulty) {
        case Difficulty.Easy:
          bgColor = easyQuestColorBg;
          borderColor = easyQuestColorBoarder;
          break;
        case Difficulty.Medium:
          bgColor = mediumQuestColorBg;
          borderColor = mediumQuestColorBoarder;
          break;
        case Difficulty.Hard:
          bgColor = hardQuestColorBg;
          borderColor = hardQuestColorBoarder;
          break;
      }

      // choose readable text color based on bg luminance
      final textColor = bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: SizedBox(
            width: cardWidth,
            child: Card(
              color: bgColor,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: borderColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Quest title and optional thumbnail
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Difficulty and reward header
                          Builder(builder: (ctx) {
                            final diffLabel = quest.difficulty.toString().split('.').last;

                            if (_completed.contains(idx)) {
                              return Text(
                                '$diffLabel - Completed',
                                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: textColor, fontWeight: FontWeight.w600),
                              );
                            }

                            // Use quest.completeQuest to compute base XP
                            final int baseXp = quest.completeQuest(quest.difficulty);
                            return Text(
                              '$diffLabel - ${baseXp}XP',
                              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: textColor),
                            );
                          }),
                          
                          const SizedBox(height: 6),
                          Text(quest.qName, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor)),
                          // Photo thumbnail removed: quest completion still navigates to celebration.
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Buttons (hidden when completed)
                    if (!_completed.contains(idx))
                      Column(
                        children: [
                          // Camera icon button
                          Material(
                            color: primColor_dGreen,
                            shape: const CircleBorder(),
                            child: IconButton(
                              tooltip: 'Take photo',
                              color: Colors.white,
                              onPressed: () => _takePhoto(idx),
                              icon: const Icon(Icons.camera_alt),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Upload / choose from gallery icon button
                          Material(
                            color: primColor_dGreen,
                            shape: const CircleBorder(),
                            child: IconButton(
                              tooltip: 'Choose from gallery',
                              color: Colors.white,
                              onPressed: () => _chooseFromGallery(idx),
                              icon: const Icon(Icons.photo_library),
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header above all quests (left-aligned with cards)
              Center(
                child: SizedBox(
                  width: cardWidth,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        'Your discoveries to find today:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
              ...questWidgets,
            ],
          ),
        ),
      ),
    );
  }
}
