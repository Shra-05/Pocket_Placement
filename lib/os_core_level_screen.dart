import 'package:flutter/material.dart';
import 'theme_selection_screen.dart';
import 'core_question_bank.dart';
import 'core_subject_level_screen.dart';
import 'core_knowledge_test_screen.dart';

class OSCoreLevelScreen extends StatelessWidget {
  final int level;
  final String title;
  final String subtitle;
  final String topic;
  final Color accentColor;
  final AppTheme theme;

  const OSCoreLevelScreen({
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
    final questions = CoreQuestionBank.forSubject('OS');
    if (level < 1 || level > 100) {
      return Scaffold(
        backgroundColor: const Color(0xFF081711),
        body: Center(
          child: Text('All 100 OS levels are complete!',
              style: const TextStyle(color: Colors.white, fontSize: 20)),
        ),
      );
    }

    final question = questions[level - 1];
    final checkpoint = level % 20 == 0;
    final testNumber = level ~/ 20;
    final nextLabel = checkpoint
        ? (testNumber == 5 ? 'FINAL TEST' : 'KNOWLEDGE TEST $testNumber')
        : 'NEXT LEVEL';

    return CoreSubjectLevelScreen(
      theme: theme,
      level: level,
      subject: 'OS',
      title: question.title,
      subtitle: '${question.concept} • ${_difficulty(level)}',
      accentColor: accentColor,
      questions: [question],
      nextTitle: nextLabel,
      onPreviousLevel: level > 1 ? () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OSCoreLevelScreen(
              level: level - 1,
              title: '',
              subtitle: '',
              topic: topic,
              accentColor: accentColor,
              theme: theme,
            ),
          ),
        );
      } : null,
      onLevelComplete: () {
        if (checkpoint) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CoreKnowledgeTestScreen(
                theme: theme,
                subject: 'OS',
                testNumber: testNumber,
                accentColor: accentColor,
                onPassed: testNumber < 5
                    ? () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OSCoreLevelScreen(
                              level: level + 1,
                              title: '',
                              subtitle: '',
                              topic: topic,
                              accentColor: accentColor,
                              theme: theme,
                            ),
                          ),
                        );
                      }
                    : null,
              ),
            ),
          );
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OSCoreLevelScreen(
              level: level + 1,
              title: '',
              subtitle: '',
              topic: topic,
              accentColor: accentColor,
              theme: theme,
            ),
          ),
        );
      },
    );
  }

  static String _difficulty(int level) {
    if (level <= 20) return 'BASIC';
    if (level <= 60) return 'INTERMEDIATE';
    if (level <= 80) return 'ADVANCED';
    return 'PLACEMENT';
  }
}
