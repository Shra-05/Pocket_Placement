import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  void _openProblemList() {
    Navigator.of(context).pushNamed('/dsa-problem-list');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF090D0B)
        : const Color(0xFFF4F8F5);
    final textColor = Theme.of(context).colorScheme.onSurface;
    final mutedColor = textColor.withValues(alpha: 0.62);
    const green = Color(0xFF55D68A);
    const borderGreen = Color(0xFF285541);

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
                                child: _QuestCard(onTap: _openProblemList),
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
                                      Expanded(
                                        child: _XPProgressCard(
                                          xp: xp,
                                          dsaTotalXP: dsaTotalXP,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: _StreakActivityCard(
                                          streak: streak,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: _NextUpCard(
                                          onTap: _openProblemList,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (medium)
                                Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 365,
                                            child: _XPProgressCard(
                                              xp: xp,
                                              dsaTotalXP: dsaTotalXP,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: SizedBox(
                                            height: 365,
                                            child: _StreakActivityCard(
                                              streak: streak,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      height: 365,
                                      child: _NextUpCard(
                                        onTap: _openProblemList,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 345,
                                      child: _XPProgressCard(
                                        xp: xp,
                                        dsaTotalXP: dsaTotalXP,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      height: 365,
                                      child: _StreakActivityCard(
                                        streak: streak,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      height: 365,
                                      child: _NextUpCard(
                                        onTap: _openProblemList,
                                      ),
                                    ),
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
                                child: _TopicCard(
                                  title: 'Arrays & Hashing',
                                  problemsCount: 10,
                                  onTap: _openProblemList,
                                ),
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
  final VoidCallback onTap;

  const _QuestCard({required this.onTap});

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
                child: const Icon(
                  Icons.flag_rounded,
                  color: Color(0xFF55D68A),
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAILY MISSION',
                      style: TextStyle(
                        color: Color(0xFF55D68A),
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Complete 1 intuition challenge',
                      style: TextStyle(
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
            'Understand the why behind the algorithm. No code editor, '
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
              label: const Text('Start learning'),
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

  const _StreakActivityCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF55D68A);
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.55);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
          Text(
            streak > 0 ? 'Keep it going!  🔥' : 'Start a streak today.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
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
                      ...List.generate(10, (column) {
                        // Decorative intensity only. Historical activity
                        // is not stored by the current screen.
                        final active =
                            ((row * 3 + column * 2 + row * column) % 7) < 3;
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: active
                                  ? green.withValues(
                                      alpha: 0.25 + ((row + column) % 3) * 0.22,
                                    )
                                  : const Color(0xFF1B2B22),
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
          Text(
            'Activity history not connected yet',
            style: TextStyle(fontSize: 9, color: muted),
          ),
        ],
      ),
    );
  }
}

class _NextUpCard extends StatelessWidget {
  final VoidCallback onTap;

  const _NextUpCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF55D68A);
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.65);

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
          Text('Next up:', style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 5),
          const Text(
            'Arrays & Hashing',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Spot patterns, reason through examples, and build '
            'strong problem-solving intuition.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: muted, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: const Color(0xFF07130B),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Start', style: TextStyle(fontWeight: FontWeight.w800)),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, size: 19),
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
  final String title;
  final int problemsCount;
  final VoidCallback onTap;

  const _TopicCard({
    required this.title,
    required this.problemsCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFF55D68A),
                  size: 26,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$problemsCount challenges · Build the foundations',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: const LinearProgressIndicator(
                        value: 0,
                        minHeight: 5,
                        backgroundColor: Color(0xFF20382A),
                        valueColor: AlwaysStoppedAnimation<Color>(
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
