import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/dsa_service.dart';

const Color _green = Color(0xFF55D68A);

// ============================================================
// TOPIC DATA
// Topic rows are built from the database (GET /api/dsa/topics).
// A new topic appears automatically once a problem whose first
// "topics" entry is that topic exists. The icon and blurb below
// are optional decoration; unknown topics get a default.
// ============================================================

class _TopicInfo {
  final String name;
  final int total;
  final int completed;

  const _TopicInfo({
    required this.name,
    required this.total,
    required this.completed,
  });

  double get progress => total == 0 ? 0 : completed / total;
  bool get isDone => total > 0 && completed >= total;
}

class _TopicMeta {
  final IconData icon;
  final String blurb;

  const _TopicMeta(this.icon, this.blurb);
}

const _TopicMeta _defaultTopicMeta = _TopicMeta(
  Icons.category_rounded,
  'Sharpen your intuition',
);

const Map<String, _TopicMeta> _topicMeta = {
  'Arrays': _TopicMeta(Icons.grid_view_rounded, 'Build the foundations'),
  'Strings': _TopicMeta(Icons.text_fields_rounded, 'Spot patterns in text'),
  'Searching': _TopicMeta(Icons.search_rounded, 'Find answers fast'),
  'Sorting': _TopicMeta(Icons.sort_rounded, 'Order reveals insight'),
  'Linked List': _TopicMeta(Icons.link_rounded, 'Think in pointers'),
  'Stack & Queue': _TopicMeta(Icons.layers_rounded, 'Control the order'),
  'Recursion & Backtracking': _TopicMeta(
    Icons.loop_rounded,
    'Break it down, try every path',
  ),
  'Trees': _TopicMeta(Icons.account_tree_rounded, 'Branching structures'),
  'Graphs': _TopicMeta(Icons.hub_rounded, 'Connections and networks'),
  'Dynamic Programming': _TopicMeta(
    Icons.trending_up_rounded,
    'Reuse work, skip repeats',
  ),
};

_TopicMeta _metaFor(String name) => _topicMeta[name] ?? _defaultTopicMeta;

// ============================================================
// STREAK HELPERS
// ============================================================

DateTime _dayOf(DateTime date) => DateTime(date.year, date.month, date.day);

/// Number of consecutive days (ending today, or yesterday if nothing has
/// been completed yet today) with at least one completed problem.
int _computeStreak(List<DateTime> completions) {
  final days = completions.map(_dayOf).toSet();
  final now = DateTime.now();
  var cursor = DateTime(now.year, now.month, now.day);
  if (!days.contains(cursor)) {
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }
  var count = 0;
  while (days.contains(cursor)) {
    count++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }
  return count;
}

Color _heatColor(int count, bool isFuture) {
  if (isFuture) return const Color(0xFF111A15);
  if (count <= 0) return const Color(0xFF1B2B22);
  final alpha = count == 1 ? 0.4 : (count == 2 ? 0.65 : 0.95);
  return _green.withValues(alpha: alpha);
}

class DSAWorldHomeScreen extends StatefulWidget {
  const DSAWorldHomeScreen({super.key});

  @override
  State<DSAWorldHomeScreen> createState() => _DSAWorldHomeScreenState();
}

class _DSAWorldHomeScreenState extends State<DSAWorldHomeScreen> {
  late SharedPreferences prefs;
  int xp = 0;
  int dsaTotalXP = 0;
  int streak = 0;
  int problemsAttempted = 0;
  bool isLoading = true;

  // Data from the backend
  List<_TopicInfo> topics = [];
  bool topicsLoading = true;
  String? topicsError;
  List<DateTime> completions = [];
  bool activityLoaded = false;
  bool activityFailed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadUserData();
    await _loadRemoteData();
  }

  Future<void> _loadUserData() async {
    try {
      prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        xp = prefs.getInt('xp') ?? 0;
        dsaTotalXP = prefs.getInt('dsaTotalXP') ?? 0;
        streak = prefs.getInt('streak') ?? 0;
        problemsAttempted = prefs.getInt('problemsAttempted') ?? 0;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadRemoteData() async {
    if (!mounted) return;
    setState(() {
      topicsLoading = topics.isEmpty;
      topicsError = null;
      activityFailed = false;
    });

    try {
      final raw = await DSAService.getTopics();
      if (!mounted) return;
      setState(() {
        topics = raw
            .map(
              (topic) => _TopicInfo(
                name: (topic['name'] ?? '').toString(),
                total: (topic['total'] as num?)?.toInt() ?? 0,
                completed: (topic['completed'] as num?)?.toInt() ?? 0,
              ),
            )
            .where((topic) => topic.name.isNotEmpty)
            .toList();
        topicsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        topicsError = e.toString();
        topicsLoading = false;
      });
    }

    try {
      final dates = await DSAService.getActivity();
      if (!mounted) return;
      final newStreak = _computeStreak(dates);
      setState(() {
        completions = dates;
        activityLoaded = true;
        streak = newStreak;
      });
      await prefs.setInt('streak', newStreak);
    } catch (e) {
      if (!mounted) return;
      // Keep the streak saved on the device if the activity cannot load.
      setState(() {
        activityFailed = true;
      });
    }
  }

  // Completed problems per day, in local time.
  Map<DateTime, int> get _dayCounts {
    final counts = <DateTime, int>{};
    for (final date in completions) {
      final day = _dayOf(date);
      counts[day] = (counts[day] ?? 0) + 1;
    }
    return counts;
  }

  bool get _doneToday => _dayCounts.containsKey(_dayOf(DateTime.now()));

  bool get _allDone => topics.isNotEmpty && topics.every((t) => t.isDone);

  // The first topic that still has unfinished problems.
  _TopicInfo? get _nextTopic {
    for (final topic in topics) {
      if (!topic.isDone) return topic;
    }
    return null;
  }

  Future<void> _openProblemList({String? topic}) async {
    await Navigator.of(context).pushNamed(
      '/dsa-problem-list',
      arguments: topic == null ? null : {'topic': topic},
    );
    if (!mounted) return;
    // Coming back from a lesson: refresh XP, streak and topic progress.
    await _loadUserData();
    await _loadRemoteData();
  }

  void _openNextUp() {
    _openProblemList(topic: _allDone ? null : _nextTopic?.name);
  }

  Widget _buildTopicsSection(bool wide) {
    if (topicsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (topicsError != null) {
      return _TopicsMessage(
        message: 'Could not load topics.\n$topicsError',
        actionLabel: 'Try again',
        onAction: _loadRemoteData,
      );
    }
    if (topics.isEmpty) {
      return const _TopicsMessage(
        message:
            'No topics yet. Add problems to the database and their topics '
            'will appear here automatically.',
      );
    }

    final cards = [
      for (final topic in topics)
        _TopicCard(
          topic: topic,
          onTap: () => _openProblemList(topic: topic.name),
        ),
    ];

    if (!wide) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == cards.length - 1 ? 0 : 12),
              child: cards[i],
            ),
        ],
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < cards.length; i += 2) {
      final hasPair = i + 1 < cards.length;
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: i + 2 >= cards.length ? 0 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[i]),
              const SizedBox(width: 14),
              Expanded(child: hasPair ? cards[i + 1] : const SizedBox.shrink()),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF090D0B)
        : const Color(0xFFF4F8F5);
    final textColor = Theme.of(context).colorScheme.onSurface;
    final mutedColor = textColor.withValues(alpha: 0.62);

    final doneToday = _doneToday;

    final xpCard = _XPProgressCard(xp: xp, dsaTotalXP: dsaTotalXP);
    final streakCard = _StreakActivityCard(
      streak: streak,
      dayCounts: _dayCounts,
      loaded: activityLoaded,
      failed: activityFailed,
      doneToday: doneToday,
    );
    final nextUpCard = _NextUpCard(
      topic: _nextTopic,
      loading: topicsLoading,
      allDone: _allDone,
      onTap: _openNextUp,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'DSA World',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        centerTitle: false,
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(child: _StreakPill(streak: streak)),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF153522).withValues(alpha: 0.55),
                    backgroundColor,
                  ],
                  stops: const [0, 0.42],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 1000;
                  final medium = constraints.maxWidth >= 650;
                  return SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1240),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: wide ? 30 : 18,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Entrance(index: 0, child: _HeroPanel(xp: xp)),
                              const SizedBox(height: 28),
                              _Entrance(
                                index: 1,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Today's quest",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: -0.3,
                                                ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'One short session. A sharper mind.',
                                            style: TextStyle(
                                              color: mutedColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const _QuickWinBadge(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              _Entrance(
                                index: 2,
                                child: _QuestCard(
                                  doneToday: doneToday,
                                  onTap: _openNextUp,
                                ),
                              ),
                              const SizedBox(height: 30),
                              _Entrance(
                                index: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your progress',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.3,
                                          ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Your effort, consistency, and next step.',
                                      style: TextStyle(
                                        color: mutedColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              if (wide)
                                SizedBox(
                                  height: 365,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(child: xpCard),
                                      const SizedBox(width: 14),
                                      Expanded(child: streakCard),
                                      const SizedBox(width: 14),
                                      Expanded(child: nextUpCard),
                                    ],
                                  ),
                                )
                              else if (medium)
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 365,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(child: xpCard),
                                          const SizedBox(width: 14),
                                          Expanded(child: streakCard),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(height: 365, child: nextUpCard),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    SizedBox(height: 345, child: xpCard),
                                    const SizedBox(height: 14),
                                    SizedBox(height: 365, child: streakCard),
                                    const SizedBox(height: 14),
                                    SizedBox(height: 365, child: nextUpCard),
                                  ],
                                ),
                              const SizedBox(height: 30),
                              _Entrance(
                                index: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Topics',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.3,
                                          ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Build intuition one pattern at a time.',
                                      style: TextStyle(
                                        color: mutedColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              _Entrance(
                                index: 5,
                                child: _buildTopicsSection(wide),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final int xp;

  const _HeroPanel({required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B2B22), Color(0xFF151B18), Color(0xFF10221A)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -14,
            child: Icon(
              Icons.hub_rounded,
              size: 135,
              color: Colors.white.withValues(alpha: 0.045),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF55D68A).withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'THE INTUITION ARENA',
                  style: TextStyle(
                    color: Color(0xFF55D68A),
                    fontSize: 10,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Train your brain.\nNot your typing speed.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Learn to spot patterns, choose smarter approaches, '
                'and think like an interviewer.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    color: Color(0xFF9BE8B8),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$xp XP earned so far',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  final int streak;

  const _StreakPill({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2917).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF8B5B22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: Color(0xFFFFA94D),
            size: 18,
          ),
          const SizedBox(width: 5),
          Text(
            '$streak days',
            style: const TextStyle(
              color: Color(0xFFFFB65E),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickWinBadge extends StatelessWidget {
  const _QuickWinBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF55D68A).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF55D68A).withValues(alpha: 0.28),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, color: Color(0xFF55D68A), size: 15),
          SizedBox(width: 4),
          Text(
            '5–10 min',
            style: TextStyle(
              color: Color(0xFF55D68A),
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  final bool doneToday;
  final VoidCallback onTap;

  const _QuestCard({required this.doneToday, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151B17) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF39784F).withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF55D68A).withValues(alpha: 0.045),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF55D68A).withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  doneToday ? Icons.check_circle_rounded : Icons.flag_rounded,
                  color: const Color(0xFF55D68A),
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doneToday ? 'MISSION COMPLETE' : 'DAILY MISSION',
                      style: const TextStyle(
                        color: Color(0xFF55D68A),
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      doneToday
                          ? "You finished today's challenge"
                          : 'Complete 1 intuition challenge',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            doneToday
                ? 'Nice work. Solve one more to build momentum and keep '
                      'your streak strong.'
                : 'Understand the why behind the algorithm. No code editor, '
                      'no hour-long grind.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(doneToday ? 'Keep learning' : 'Start learning'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3EAD58),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _CardShell({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101713) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF315743), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF55D68A), size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.more_horiz_rounded,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _XPProgressCard extends StatelessWidget {
  final int xp;
  final int dsaTotalXP;

  const _XPProgressCard({required this.xp, required this.dsaTotalXP});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF55D68A);
    return _CardShell(
      title: 'XP Progress',
      icon: Icons.workspace_premium_outlined,
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            width: 178,
            height: 178,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 9,
                    color: const Color(0xFF244335),
                  ),
                ),
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: xp == 0 ? 0 : (xp % 1000) / 1000,
                    strokeWidth: 9,
                    strokeCap: StrokeCap.round,
                    color: green,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total XP',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      child: Text(
                        '$xp',
                        style: const TextStyle(
                          fontSize: 38,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: green,
                      size: 22,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'DSA XP  ·  '),
                TextSpan(
                  text: '$dsaTotalXP XP',
                  style: const TextStyle(
                    color: green,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Experience earned through learning',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakActivityCard extends StatelessWidget {
  final int streak;
  final Map<DateTime, int> dayCounts;
  final bool loaded;
  final bool failed;
  final bool doneToday;

  const _StreakActivityCard({
    required this.streak,
    required this.dayCounts,
    required this.loaded,
    required this.failed,
    required this.doneToday,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF55D68A);
    const weeks = 10;
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.55);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // The heatmap shows the last 10 weeks. Each column is a week
    // (Monday to Sunday) and the last column is the current week.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday - 1),
    );
    final windowStart = DateTime(
      monday.year,
      monday.month,
      monday.day - (weeks - 1) * 7,
    );

    var recentTotal = 0;
    dayCounts.forEach((date, count) {
      if (!date.isBefore(windowStart) && !date.isAfter(today)) {
        recentTotal += count;
      }
    });

    String subtitle;
    if (streak == 0) {
      subtitle = 'Start a streak today.';
    } else if (doneToday) {
      subtitle = 'Keep it going!  🔥';
    } else {
      subtitle = 'Solve one today to keep your streak alive.';
    }

    String footnote;
    if (loaded) {
      footnote = '$recentTotal completed in the last 10 weeks';
    } else if (failed) {
      footnote = 'Activity history unavailable';
    } else {
      footnote = 'Loading activity…';
    }

    return _CardShell(
      title: 'Learning Streak',
      icon: Icons.local_fire_department_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$streak',
                  style: const TextStyle(
                    color: green,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const TextSpan(
                  text: ' day streak',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(subtitle, style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 18),
          Expanded(
            child: Column(
              children: List.generate(7, (row) {
                return Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          days[row],
                          style: TextStyle(fontSize: 10, color: muted),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ...List.generate(weeks, (column) {
                        final date = DateTime(
                          monday.year,
                          monday.month,
                          monday.day + (column - (weeks - 1)) * 7 + row,
                        );
                        final isFuture = date.isAfter(today);
                        final count = dayCounts[date] ?? 0;
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: _heatColor(count, isFuture),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Less', style: TextStyle(fontSize: 10, color: muted)),
              const SizedBox(width: 8),
              ...List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: green.withValues(alpha: 0.18 + index * 0.24),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text('More', style: TextStyle(fontSize: 10, color: muted)),
            ],
          ),
          const SizedBox(height: 4),
          Text(footnote, style: TextStyle(fontSize: 9, color: muted)),
        ],
      ),
    );
  }
}

class _NextUpCard extends StatelessWidget {
  final _TopicInfo? topic;
  final bool loading;
  final bool allDone;
  final VoidCallback onTap;

  const _NextUpCard({
    required this.topic,
    required this.loading,
    required this.allDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF55D68A);
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.65);

    final current = topic;
    String label;
    String name;
    String description;
    String buttonLabel;
    var enabled = true;

    if (loading) {
      label = 'Next up:';
      name = 'Loading…';
      description = '';
      buttonLabel = 'Start';
      enabled = false;
    } else if (allDone) {
      label = 'Well done:';
      name = 'Every topic complete';
      description =
          'You have finished every challenge. Revisit any problem to keep '
          'your intuition sharp.';
      buttonLabel = 'Review';
    } else if (current == null) {
      label = 'Next up:';
      name = 'No topics yet';
      description =
          'Add problems to the database and your topics will appear here.';
      buttonLabel = 'Start';
      enabled = false;
    } else {
      final left = current.total - current.completed;
      label = 'Next up:';
      name = current.name;
      description =
          '${_metaFor(current.name).blurb}. '
          '$left of ${current.total} challenges left.';
      buttonLabel = current.completed > 0 ? 'Continue' : 'Start';
    }

    return _CardShell(
      title: 'Next Up',
      icon: Icons.menu_book_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: CustomPaint(
                size: const Size(double.infinity, 150),
                painter: _AlgorithmPatternPainter(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: muted, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: enabled ? onTap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: const Color(0xFF07130B),
                disabledBackgroundColor: green.withValues(alpha: 0.25),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    buttonLabel,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_rounded, size: 19),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlgorithmPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF55D68A).withValues(alpha: 0.08)
      ..strokeWidth = 0.7;

    for (double x = 8; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 8; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final axisPaint = Paint()
      ..color = const Color(0xFF8EA99A).withValues(alpha: 0.8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final origin = Offset(size.width * 0.5, size.height * 0.76);
    canvas.drawLine(
      Offset(size.width * 0.12, origin.dy),
      Offset(size.width * 0.9, origin.dy),
      axisPaint,
    );
    canvas.drawLine(
      Offset(origin.dx, size.height * 0.93),
      Offset(origin.dx, size.height * 0.08),
      axisPaint,
    );

    final curve = Path()
      ..moveTo(size.width * 0.18, size.height * 0.22)
      ..quadraticBezierTo(
        size.width * 0.33,
        size.height * 1.2,
        size.width * 0.5,
        size.height * 0.76,
      )
      ..quadraticBezierTo(
        size.width * 0.67,
        size.height * 1.2,
        size.width * 0.82,
        size.height * 0.22,
      );

    final glowPaint = Paint()
      ..color = greenGlow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(curve, glowPaint);

    final curvePaint = Paint()
      ..color = const Color(0xFF55D68A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(curve, curvePaint);
  }

  static const greenGlow = Color(0x8855D68A);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopicCard extends StatelessWidget {
  final _TopicInfo topic;
  final VoidCallback onTap;

  const _TopicCard({required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meta = _metaFor(topic.name);
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.65);

    return Material(
      color: isDark ? const Color(0xFF151B17) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF39784F).withValues(alpha: 0.7),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF55D68A).withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  topic.isDone ? Icons.check_circle_rounded : meta.icon,
                  color: const Color(0xFF55D68A),
                  size: 26,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            topic.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${topic.completed}/${topic.total}',
                          style: const TextStyle(
                            color: Color(0xFF55D68A),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${topic.total} challenges · ${meta.blurb}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: topic.progress,
                        minHeight: 5,
                        backgroundColor: const Color(0xFF20382A),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF55D68A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF55D68A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicsMessage extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _TopicsMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.65);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF39784F).withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 13, height: 1.5),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _Entrance extends StatelessWidget {
  final int index;
  final Widget child;

  const _Entrance({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
