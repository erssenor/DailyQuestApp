


enum Difficulty { 
  Easy,
  Medium,
  Hard
}

enum QuestType {
  Land,
  Water,
  Air
}

// Base Quest class
class Quest {

  final String qName;
  final Difficulty difficulty; // 'Easy', 'Medium', 'Hard'

  bool checkQuest() {
    // TODO implemnet accepting of a photo to verify quest completion
    bool questCompleted = true; // Placeholder for actual verification logic

    if (questCompleted) {
      completeQuest(this.difficulty);
      return true;
    }
    else 
    {
      return false;
    }

  }

  // Returns XP points based on difficulty
  int completeQuest(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.Easy:
        return 100;
      case Difficulty.Medium:
        return 500;
      case Difficulty.Hard:
        return 1000;
      default:
        return 0;
    }
  }
  
  Quest(this.qName, this.difficulty);  
}

// Subclasses for different quest types
class LandQuest extends Quest {
  QuestType type = QuestType.Land;

  LandQuest(super.qName, super.difficulty);
}

class SeaQuest extends Quest {
  QuestType type = QuestType.Water;

  SeaQuest(super.qName, super.difficulty);
}

class AirQuest extends Quest {
  QuestType type = QuestType.Air;

  AirQuest(super.qName, super.difficulty);
}