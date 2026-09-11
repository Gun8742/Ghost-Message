import 'package:flutter/material.dart';
import 'package:ghost_message/models/leaderboard_item_model.dart';
import 'package:ghost_message/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:ghost_message/providers/user_provider.dart';

class LeaderboardTabs extends StatelessWidget {
  const LeaderboardTabs({
    super.key,
    required this.tabIndex,
    required this.onChangeTab,
    required this.leftText,
    required this.rightText,
  });

  final int tabIndex;
  final Function(int) onChangeTab;

  final String leftText;
  final String rightText;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    final Color bgColor = isDark ? ThemeProvider.buttonDark : ThemeProvider.buttonLight;
    final Color selectedColor = isDark ? ThemeProvider.fieldDark : ThemeProvider.pillLight;
    final Color textColor = isDark ? ThemeProvider.textDark : ThemeProvider.textLight;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              text: leftText,
              isSelected: tabIndex == 0,
              selectedColor: selectedColor,
              textColor: textColor,
              onTap: () => onChangeTab(0),
            ),
          ),
          Expanded(
            child: _TabButton(
              text: rightText,
              isSelected: tabIndex == 1,
              selectedColor: selectedColor,
              textColor: textColor,
              onTap: () => onChangeTab(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.text,
    required this.isSelected,
    required this.selectedColor,
    required this.textColor,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final Color selectedColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class LeaderboardTop3 extends StatelessWidget {
  const LeaderboardTop3({
    super.key,
    required this.items,
    required this.tabIndex,
    required this.userProvider,
  });

  final List<LeaderboardItemModel> items;
  final int tabIndex;
  final UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    if (items.length < 3) return const SizedBox.shrink();

    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    final Color cardColor = isDark ? ThemeProvider.buttonDark : ThemeProvider.buttonLight;
    final Color textColor = isDark ? ThemeProvider.textDark : ThemeProvider.textLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _TopCard(
          item: items[1],
          rank: 2,
          tabIndex: tabIndex,
          cardColor: cardColor,
          textColor: textColor,
          userProvider: userProvider,
          
        ),
        _TopCard(
          item: items[0],
          rank: 1,
          tabIndex: tabIndex,
          cardColor: cardColor,
          textColor: textColor,
          isCenter: true,
          userProvider: userProvider,
        ),
        _TopCard(
          item: items[2],
          rank: 3,
          tabIndex: tabIndex,
          cardColor: cardColor,
          textColor: textColor,
          userProvider: userProvider,
        ),
      ],
    );
  }
}

class _TopCard extends StatelessWidget {
  const _TopCard({
    required this.item,
    required this.rank,
    required this.tabIndex,
    required this.cardColor,
    required this.textColor,
    required this.userProvider,
    this.isCenter = false,
  });

  final LeaderboardItemModel item;
  final UserProvider userProvider;
  final int rank;
  final int tabIndex;

  final Color cardColor;
  final Color textColor;

  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    final double size = isCenter ? 80 : 62;
    final int score = item.count;
    final String? photoPath = userProvider.getPhotoPath(item.uid);

    return Container(
      width: isCenter ? 120 : 105,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              CircleAvatar(
                radius: size / 2,
                backgroundColor: Colors.white.withOpacity(0.12),
                backgroundImage:
                    (photoPath != null && photoPath.isNotEmpty) ? NetworkImage(photoPath) : null,
                child: (photoPath == null || photoPath.isEmpty)
                    ? Text(
                        item.name.isNotEmpty ? item.name[0].toUpperCase() : "?",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      )
                    : null,
              ),
              if (rank == 1)
                const Positioned(
                  top: -6,
                  child: Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            score.toString(),
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class LeaderboardList extends StatelessWidget {
  const LeaderboardList({
    super.key,
    required this.items,
    required this.tabIndex,
    required this.userProvider,
  });

  final List<LeaderboardItemModel> items;
  final int tabIndex;
  final UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    final Color cardColor = isDark ? ThemeProvider.buttonDark : ThemeProvider.buttonLight;
    final Color fieldColor = isDark ? ThemeProvider.fieldDark : ThemeProvider.pillLight;
    final Color textColor = isDark ? ThemeProvider.textDark : ThemeProvider.textLight;
    final Color dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final score = item.count;
          final String? photoPath = userProvider.getPhotoPath(item.uid);

          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: fieldColor,
                  backgroundImage:
                      (photoPath != null && photoPath.isNotEmpty) ? NetworkImage(photoPath) : null,
                  child: (photoPath == null || photoPath.isEmpty)
                      ? Text(
                          item.name.isNotEmpty ? item.name[0].toUpperCase() : "?",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  item.name,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  tabIndex == 0 ? "${item.count} posts" : "${item.count} likes",
                  style: TextStyle(color: textColor.withOpacity(0.7)),
                ),
                trailing: Text(
                  score.toString(),
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                ),
              ),
              if (index != items.length - 1)
                Divider(height: 1, color: dividerColor),
            ],
          );
        }),
      ),
    );
  }
}