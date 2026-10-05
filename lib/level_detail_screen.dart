import 'package:flutter/material.dart';

import 'level_quiz_screen.dart';
import 'theme_selection_screen.dart';

/// Every level uses the SAME coding-workspace UI.
/// Only the level data changes.
class LevelDetailScreen extends StatelessWidget {
  final int level;
  final String title;
  final String subtitle;
  final String topic;
  final Color accentColor;
  final AppTheme theme;

  const LevelDetailScreen({
    super.key,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.topic,
    required this.accentColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return LevelQuizScreen(
      level: level,
      title: title,
      subtitle: subtitle,
      topic: topic,
      accentColor: accentColor,
      theme: theme,
    );
  }
}
