import 'package:flutter/material.dart';

class SubjectSwitcher extends StatelessWidget {
  final String selectedTopic;
  final ValueChanged<String> onSubjectSelected;

  const SubjectSwitcher({
    super.key,
    required this.selectedTopic,
    required this.onSubjectSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSubjectSelected,
      color: const Color(0xFF19271F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'DSA',
          child: _SubjectItem(
            emoji: '⚔️',
            title: 'DSA',
            subtitle: 'Main coding journey',
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          enabled: false,
          child: Text(
            'CORE CS',
            style: TextStyle(
              color: Color(0xFFE8A94E),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        const PopupMenuItem(
          value: 'OOPS',
          child: _SubjectItem(
            emoji: '🧩',
            title: 'OOPS',
            subtitle: 'Object oriented programming',
          ),
        ),
        const PopupMenuItem(
          value: 'DBMS',
          child: _SubjectItem(
            emoji: '🗄️',
            title: 'DBMS',
            subtitle: 'Databases and SQL',
          ),
        ),
        const PopupMenuItem(
          value: 'OS',
          child: _SubjectItem(
            emoji: '⚙️',
            title: 'Operating Systems',
            subtitle: 'Processes and memory',
          ),
        ),
        const PopupMenuItem(
          value: 'CN',
          child: _SubjectItem(
            emoji: '🌐',
            title: 'Computer Networks',
            subtitle: 'Networks and protocols',
          ),
        ),
        const PopupMenuItem(
          value: 'ML',
          child: _SubjectItem(
            emoji: '🤖',
            title: 'Machine Learning',
            subtitle: 'Models and learning',
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF19271F),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE8A94E),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _emojiFor(selectedTopic),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              _displayName(selectedTopic),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFFE8A94E),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  static String _displayName(String topic) {
    switch (topic.toUpperCase()) {
      case 'OS':
        return 'OS';
      case 'CN':
        return 'CN';
      case 'ML':
        return 'ML';
      default:
        return topic.toUpperCase();
    }
  }

  static String _emojiFor(String topic) {
    switch (topic.toUpperCase()) {
      case 'DSA':
        return '⚔️';
      case 'OOPS':
        return '🧩';
      case 'DBMS':
        return '🗄️';
      case 'OS':
        return '⚙️';
      case 'CN':
        return '🌐';
      case 'ML':
        return '🤖';
      default:
        return '📚';
    }
  }
}

class _SubjectItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _SubjectItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}