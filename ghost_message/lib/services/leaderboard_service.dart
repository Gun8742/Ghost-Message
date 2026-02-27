import 'package:ghost_message/models/leaderboard_item_model.dart';

class LeaderboardService {
  List<LeaderboardItemModel> getMockData() {
    return [
      LeaderboardItemModel(name: "Eiden", posts: 42, likes: 2430),
      LeaderboardItemModel(name: "Jackson", posts: 35, likes: 1847),
      LeaderboardItemModel(name: "Emma Aria", posts: 28, likes: 1674),
      LeaderboardItemModel(name: "Sebastian", posts: 21, likes: 1124),
      LeaderboardItemModel(name: "Jason", posts: 18, likes: 875),
      LeaderboardItemModel(name: "Natalie", posts: 15, likes: 774),
      LeaderboardItemModel(name: "Serenity", posts: 14, likes: 723),
      LeaderboardItemModel(name: "Hannah", posts: 10, likes: 559),
    ];
  }

  List<LeaderboardItemModel> sortByTab({
    required List<LeaderboardItemModel> list,
    required int tabIndex,
  }) {
    final result = List<LeaderboardItemModel>.from(list);

    result.sort((a, b) {
      final aScore = tabIndex == 0 ? a.posts : a.likes;
      final bScore = tabIndex == 0 ? b.posts : b.likes;
      return bScore.compareTo(aScore);
    });

    return result;
  }
}