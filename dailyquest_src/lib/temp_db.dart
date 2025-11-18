import 'package:dailyquest_app/quest.dart';

// A small record for a completed quest so we can display recent completions.
class CompletedQuest {
  final String category;
  final int index;
  final DateTime timestamp;

  CompletedQuest(this.category, this.index) : timestamp = DateTime.now();
}

class TempDatabase {
  // In-memory map of completed quests per user per category: { username: { category: { indices } } }
  static final Map<String, Map<String, Set<int>>> _completed = {};

  // Keep a recent list (newest first) of completed quests per user. Limit to 10 entries.
  static final Map<String, List<CompletedQuest>> _recent = {};

  // Mark a quest index as completed for a given user and category.
  static void markCompleted(String username, String category, int index) {
    final userMap = _completed.putIfAbsent(username, () => {});
    final set = userMap.putIfAbsent(category.toLowerCase(), () => <int>{});
    set.add(index);

    // add to recent list (newest at front) and trim to 10
    final recentList = _recent.putIfAbsent(username, () => <CompletedQuest>[]);
    recentList.insert(0, CompletedQuest(category.toLowerCase(), index));
    if (recentList.length > 10) recentList.removeLast();
  }

  // Return completed indices for a user and category (empty set if none).
  static Set<int> completedFor(String username, String category) {
    return _completed[username]?[category.toLowerCase()] ?? <int>{};
  }

  // Return up to 10 most recent completed quests for [username], newest first.
  static List<CompletedQuest> recentCompleted(String username) {
    return List<CompletedQuest>.from(_recent[username] ?? <CompletedQuest>[]);
  }

  // Clear the current completion sets for all users (does NOT touch recent history).
  static void clearCurrentCompletions() {
    _completed.clear();
  }
}

class TempQuestDatabase {
  // Static collections so UI can fetch available quests per category
  static final List<LandQuest> landQuests = [
    LandQuest("Take a photo of any insect.", Difficulty.Easy),
    LandQuest("Take a photo of a dog or cat.", Difficulty.Medium),
    LandQuest("Take a photo of a wild mammal.", Difficulty.Hard),
  ];

  static final List<SeaQuest> seaQuests = [
    SeaQuest("Take a photo of a lake or ocean.", Difficulty.Easy),
    SeaQuest("Take a photo of a boat.", Difficulty.Medium),
    SeaQuest("Take a photo of a fish.", Difficulty.Hard),
  ];

  static final List<AirQuest> airQuests = [
    AirQuest("Take a photo of a cloud.", Difficulty.Easy),
    AirQuest("Take a photo of a bird.", Difficulty.Medium),
    AirQuest("Take a photo of an airplane.", Difficulty.Hard),
  ];

  // Return quests by category name (case-insensitive). Accepted values: 'land','sea','sky'.
  static List<Quest> questsForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'land':
        return List<Quest>.from(landQuests);
      case 'sea':
        return List<Quest>.from(seaQuests);
      case 'sky':
        return List<Quest>.from(airQuests);
      default:
        return <Quest>[];
    }
  }
}
