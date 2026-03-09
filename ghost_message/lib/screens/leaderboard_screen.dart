import 'package:flutter/material.dart';
import 'package:ghost_message/models/leaderboard_item_model.dart';
import 'package:ghost_message/providers/l_provider.dart';
import 'package:ghost_message/providers/theme_provider.dart';
import 'package:ghost_message/services/leaderboard_service.dart';
import 'package:ghost_message/widgets/leaderboard_list_build.dart';
import 'package:provider/provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardService _leaderboardService = LeaderboardService();

  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<L>(context);

    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    final Color bg = isDark ? ThemeProvider.bgDark : ThemeProvider.bgLight;
    final Color text = isDark ? ThemeProvider.textDark : ThemeProvider.textLight;

    final String boardId = _tabIndex == 0 ? 'posts' : 'likes';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(l.leaderboardTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
      ),
      body: StreamBuilder<List<LeaderboardItemModel>>(
        stream: _leaderboardService.streamLeaderboard(boardId: boardId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load leaderboard',
                style: TextStyle(
                  color: text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final List<LeaderboardItemModel> items = snapshot.data ?? [];
          final List<LeaderboardItemModel> top3 =
              items.length >= 3 ? items.sublist(0, 3) : items;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              LeaderboardTabs(
                tabIndex: _tabIndex,
                onChangeTab: (i) {
                  setState(() {
                    _tabIndex = i;
                  });
                },
                leftText: l.leaderboardPostTab,
                rightText: l.leaderboardLikeTab,
              ),
              const SizedBox(height: 18),
              LeaderboardTop3(
                items: top3,
                tabIndex: _tabIndex,
              ),
              const SizedBox(height: 18),
              LeaderboardList(
                items: items,
                tabIndex: _tabIndex,
              ),
            ],
          );
        },
      ),
    );
  }
}