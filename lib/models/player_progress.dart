/// Serializable player progress model.
/// Stored and loaded via SaveManager / SharedPreferences.
class PlayerProgress {
  PlayerProgress({
    this.totalScore = 0,
    this.coins = 0,
    this.unlockedAircraftIds = const ['interceptor'],
    this.currentLevel = 1,
    this.highScore = 0,
  });

  int totalScore;
  int coins;
  List<String> unlockedAircraftIds;
  int currentLevel;
  int highScore;

  bool ownsAircraft(String id) => unlockedAircraftIds.contains(id);

  void unlockAircraft(String id) {
    if (!ownsAircraft(id)) unlockedAircraftIds = [...unlockedAircraftIds, id];
  }

  void addScore(int pts) {
    totalScore += pts;
    if (totalScore > highScore) highScore = totalScore;
  }

  /// Converts score earned in a mission to coins.
  int missionCoins(int missionScore) => (missionScore * 0.01).floor();

  Map<String, dynamic> toJson() => {
        'totalScore': totalScore,
        'coins': coins,
        'unlockedAircraftIds': unlockedAircraftIds,
        'currentLevel': currentLevel,
        'highScore': highScore,
      };

  factory PlayerProgress.fromJson(Map<String, dynamic> json) => PlayerProgress(
        totalScore: (json['totalScore'] as int?) ?? 0,
        coins: (json['coins'] as int?) ?? 0,
        unlockedAircraftIds: List<String>.from(
            (json['unlockedAircraftIds'] as List?) ?? ['interceptor']),
        currentLevel: (json['currentLevel'] as int?) ?? 1,
        highScore: (json['highScore'] as int?) ?? 0,
      );
}
