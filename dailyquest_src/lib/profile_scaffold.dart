import 'package:flutter/material.dart';
import 'quests_screen.dart';
import 'user.dart';
import 'colors.dart';
import 'temp_db.dart';

/// A scaffold that includes the app bar with a profile icon and the end drawer
/// showing user details. Use this when screens should not directly handle user data.
class ProfileScaffold extends StatelessWidget {
  final User user;
  final Widget body;

  const ProfileScaffold({required this.user, required this.body, super.key});

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    final showLogoutOnLeading = body.runtimeType == QuestsCategoryScreen;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Daily Quest'),
        centerTitle: true,
        leading: showLogoutOnLeading
            ? IconButton(
                // Logout button
                tooltip: 'Logout',
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: backgroundColor,
                          title: Text('Logout', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(color: Colors.white)),
                          content: Text('Are you sure you want to log out?', style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                          // Use a Row inside actions to position Cancel on the left and Logout on the right.
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(backgroundColor: primColor_dGreen, foregroundColor: Colors.white),
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (ok) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  }
                },
              )
            : null,
        actions: [
          // Profile button to open end drawer
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      // Profile end drawer
      endDrawer: Drawer(
        child: Container(
          color: backgroundColor,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  // Placeholder profile avatar
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: primColor_dGreen,
                    child: const Icon(Icons.person, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  // Username, level and XP progress: rebuild when `user` notifies
                  AnimatedBuilder(
                    animation: user,
                    builder: (ctx, _) {
                      final pct = (user.currXp / (user.level * 100)).clamp(0.0, 1.0);
                      return Column(
                        children: [
                          // Username centered
                          Text(user.username, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white), textAlign: TextAlign.center),
                          const SizedBox(height: 18),
                          // Level and XP progress bar
                          Row(
                            children: [
                              // Level number on the left
                              Text('${user.level}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                              const SizedBox(width: 12),
                              // Progress bar
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Pill-shaped progress bar with overlaid XP text
                                    LayoutBuilder(builder: (ctx, constraints) {
                                      return Container(
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Colors.white24,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: FractionallySizedBox(
                                                widthFactor: pct,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: primColor_dGreen,
                                                    borderRadius: BorderRadius.circular(999),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Center(
                                              child: Text('${user.currXp} / ${user.level * 100} XP', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  // Recent completions header
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Recent discoveries', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                  ),
                  const SizedBox(height: 8),
                  // Recent completed quests (up to 10)
                  Builder(builder: (ctx) {
                    final recent = TempDatabase.recentCompleted(user.username);
                    if (recent.isEmpty) {
                      return Expanded(
                        child: Center(
                          child: Text('No recent completions', style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                        ),
                      );
                    }
                    return Expanded(
                      child: ListView.separated(
                        itemCount: recent.length,
                        separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 12),
                        itemBuilder: (c, i) {
                          final rc = recent[i];
                          // Get quest title from TempQuestDatabase (if available)
                          final quests = TempQuestDatabase.questsForCategory(rc.category);
                          final title = (rc.index >= 0 && rc.index < quests.length) ? quests[rc.index].qName : 'Quest ${rc.index}';
                          final ts = rc.timestamp.toLocal();
                          final timeLabel = '${ts.year}-${ts.month.toString().padLeft(2,'0')}-${ts.day.toString().padLeft(2,'0')}';
                          // Choose colors per category
                          Color boxBg = backgroundColor;
                          Color border = Colors.white24;
                          switch (rc.category) {
                            case 'land':
                              boxBg = landColorBg;
                              border = landColor;
                              break;
                            case 'sea':
                              boxBg = seaColorBg;
                              border = seaColor;
                              break;
                            case 'sky':
                              boxBg = skyColorBg;
                              border = skyColor;
                              break;
                          }
                          final textColor = boxBg.computeLuminance() > 0.5 ? Colors.black : Colors.white;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            decoration: BoxDecoration(
                              color: boxBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: border.withOpacity(0.9)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('${rc.category[0].toUpperCase()}${rc.category.substring(1)} • $timeLabel', style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: textColor.withOpacity(0.85))),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
      body: body,
    );
  }
}
