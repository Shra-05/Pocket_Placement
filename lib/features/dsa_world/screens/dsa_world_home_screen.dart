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
      setState(() {
        xp = prefs.getInt('xp') ?? 0;
        dsaTotalXP = prefs.getInt('dsaTotalXP') ?? 0;
        streak = prefs.getInt('streak') ?? 0;
        problemsAttempted = prefs.getInt('problemsAttempted') ?? 0;
        isLoading = false;
      });
    } catch (e) {
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
    final primaryColor = isDark ? Colors.green : Colors.green.shade400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌍 DSA World'),
        centerTitle: true,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FadeSlide(
                            index: 0,
                            child: Text(
                              "Today's DSA Goal",
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FadeSlide(
                            index: 1,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.green.shade700,
                                    Colors.green.shade400,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.35),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Complete 1 intuition challenge',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 16,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '5–10 minutes',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.green.shade700,
                                        elevation: 4,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: _openProblemList,
                                      child: const Text(
                                        'Start Learning',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          _FadeSlide(
                            index: 2,
                            child: Text(
                              'Your Progress',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FadeSlide(
                            index: 3,
                            child: GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.7,
                              children: [
                                _StatCard(
                                  title: 'XP',
                                  emoji: '⚡',
                                  value: xp,
                                  color: primaryColor,
                                ),
                                _StatCard(
                                  title: 'DSA XP',
                                  emoji: '🧠',
                                  value: dsaTotalXP,
                                  color: Colors.blue,
                                ),
                                _StatCard(
                                  title: 'Streak',
                                  emoji: '🔥',
                                  value: streak,
                                  color: Colors.orange,
                                ),
                                _StatCard(
                                  title: 'Problems',
                                  emoji: '✅',
                                  value: problemsAttempted,
                                  color: Colors.purple,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _FadeSlide(
                            index: 4,
                            child: Text(
                              'Topics',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FadeSlide(
                            index: 5,
                            child: _TopicCard(
                              title: 'Arrays & Hashing',
                              problemsCount: 10,
                              color: Colors.green,
                              onTap: _openProblemList,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

/// Fade + slide-up entrance. Later items (higher index) animate slightly slower
/// so the screen builds in a staggered way. No controllers needed.
class _FadeSlide extends StatelessWidget {
  final int index;
  final Widget child;

  const _FadeSlide({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + index * 120),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - v)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String emoji;
  final int value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.emoji,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.7), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: value),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOut,
                  builder: (context, v, _) => Text(
                    v.toString(),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final String title;
  final int problemsCount;
  final Color color;
  final VoidCallback onTap;

  const _TopicCard({
    required this.title,
    required this.problemsCount,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.07),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.7), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('📊', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$problemsCount problem${problemsCount != 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
