import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/dsa_service.dart';

const Color _green = Color(0xFF55D68A);
const Color _amber = Color(0xFFFFC857);
const Color _violet = Color(0xFFB26BFF);
const Color _red = Color(0xFFFF6B6B);
const Color _cyan = Color(0xFF4DD0E1);
const Color _bgColor = Color(0xFF090D0B);
const Color _cardColor = Color(0xFF101713);
const Color _borderColor = Color(0xFF315743);

Color _difficultyColor(String difficulty) {
  switch (difficulty) {
    case 'Easy':
      return _green;
    case 'Medium':
      return const Color(0xFFFFB44D);
    case 'Hard':
      return _red;
    default:
      return Colors.grey;
  }
}

/// Consecutive days (ending today, or yesterday) with a completed problem.
int _computeStreak(List<DateTime> completions) {
  final days = completions.map((d) => DateTime(d.year, d.month, d.day)).toSet();
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

class LessonCompletionScreen extends StatefulWidget {
  final String problemId;
  final int correctIntuitionChallenges;
  final int correctTransferQuestions;

  const LessonCompletionScreen({
    super.key,
    required this.problemId,
    required this.correctIntuitionChallenges,
    required this.correctTransferQuestions,
  });

  @override
  State<LessonCompletionScreen> createState() => _LessonCompletionScreenState();
}

class _LessonCompletionScreenState extends State<LessonCompletionScreen>
    with TickerProviderStateMixin {
  // Loading / errors
  bool _loading = true;
  String? _error;

  // Rewards
  int _xpEarned = 0;
  int _previousXP = 0;
  int _totalXP = 0;

  // Problem details
  String _title = '';
  String _difficulty = '';
  String? _topic;
  int _totalIntuition = 0;
  int _totalTransfer = 0;
  String _patternName = '';
  String _keyInsight = '';

  // Topic progress, next problem, streak
  int _topicDone = 0;
  int _topicTotal = 0;
  Map<String, dynamic>? _nextProblem;
  int _streak = 0;

  bool _patternUnlocked = false;

  late final AnimationController _intro;
  late final AnimationController _pulse;
  late final AnimationController _confetti;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _confetti = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );

    final random = Random(42);
    const colors = [_green, _amber, _violet, _cyan, Colors.white, _red];
    _particles = List.generate(80, (index) {
      return _Particle(
        x0: random.nextDouble(),
        vy: 0.55 + random.nextDouble() * 0.6,
        drift: 0.02 + random.nextDouble() * 0.06,
        phase: random.nextDouble() * 2 * pi,
        size: 5 + random.nextDouble() * 6,
        spin: 2 + random.nextDouble() * 6,
        delay: random.nextDouble() * 0.25,
        color: colors[random.nextInt(colors.length)],
      );
    });

    _load();
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    // 1) Submit the solution and get the XP (this is the part that matters)
    int xp;
    try {
      final result = await DSAService.submitSolution(widget.problemId);
      xp = (result['xpEarned'] as num?)?.toInt() ?? 0;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      return;
    }

    // Update local preferences
    final prefs = await SharedPreferences.getInstance();
    final currentXP = prefs.getInt('xp') ?? 0;
    final currentDSAXP = prefs.getInt('dsaTotalXP') ?? 0;
    await prefs.setInt('xp', currentXP + xp);
    await prefs.setInt('dsaTotalXP', currentDSAXP + xp);

    // 2) Optional extras. If any of them fails the page still works.
    Map<String, dynamic> problem = {};
    try {
      final data = await DSAService.getProblem(widget.problemId);
      problem = Map<String, dynamic>.from(data['problem'] ?? {});
    } catch (_) {}

    final topics = List<String>.from(problem['topics'] ?? []);
    final topic = topics.isNotEmpty ? topics.first : null;

    var topicDone = 0;
    var topicTotal = 0;
    Map<String, dynamic>? next;
    try {
      final list = await DSAService.getProblems(topic: topic);
      topicTotal = list.length;
      topicDone = list.where((p) => p['completed'] == true).length;
      final currentIndex = list.indexWhere((p) => p['_id'] == widget.problemId);
      final start = currentIndex < 0 ? -1 : currentIndex;
      for (var i = 1; i <= list.length; i++) {
        final candidate = list[(start + i) % list.length];
        if (candidate['completed'] != true &&
            candidate['_id'] != widget.problemId) {
          next = candidate;
          break;
        }
      }
    } catch (_) {}

    var streak = 0;
    try {
      streak = _computeStreak(await DSAService.getActivity());
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _xpEarned = xp;
      _previousXP = currentXP;
      _totalXP = currentXP + xp;
      _title = (problem['title'] ?? '').toString();
      _difficulty = (problem['difficulty'] ?? '').toString();
      _topic = topic;
      _totalIntuition = (problem['intuitionChallenges'] as List?)?.length ?? 0;
      _totalTransfer = (problem['transferQuestions'] as List?)?.length ?? 0;
      _patternName = (problem['patternName'] ?? '').toString();
      _keyInsight = (problem['keyInsight'] ?? '').toString();
      _topicDone = topicDone;
      _topicTotal = topicTotal;
      _nextProblem = next;
      _streak = streak;
      _loading = false;
    });
    _intro.forward();
    _confetti.forward();
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _load();
  }

  void _backToDSAHome() {
    Navigator.of(context).pushReplacementNamed('/dsa-world-home');
  }

  void _openNext() {
    final next = _nextProblem;
    if (next != null) {
      Navigator.of(context).pushReplacementNamed(
        '/dsa-problem-display',
        arguments: {'problemId': next['_id']},
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/dsa-problem-list');
    }
  }

  // ----------------------------------------------------------
  // Derived values
  // ----------------------------------------------------------

  int get _correctIntuition => _totalIntuition > 0
      ? min(widget.correctIntuitionChallenges, _totalIntuition)
      : widget.correctIntuitionChallenges;

  int get _correctTransfer => _totalTransfer > 0
      ? min(widget.correctTransferQuestions, _totalTransfer)
      : widget.correctTransferQuestions;

  int get _stars {
    final total = _totalIntuition + _totalTransfer;
    if (total == 0) return 3;
    final ratio = (_correctIntuition + _correctTransfer) / total;
    if (ratio >= 0.8) return 3;
    if (ratio >= 0.5) return 2;
    return 1;
  }

  int get _level => _totalXP ~/ 1000 + 1;
  bool get _leveledUp => _totalXP ~/ 1000 > _previousXP ~/ 1000;

  // Progress (0..1) of one animation stage inside the 3.4 second intro.
  double _stage(double begin, double end, [Curve curve = Curves.easeOutCubic]) {
    final t = _intro.value;
    if (t <= begin) return 0;
    if (t >= end) return 1;
    return curve.transform((t - begin) / (end - begin));
  }

  Widget _reveal(double begin, double end, Widget child) {
    final value = _stage(begin, end);
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 18 * (1 - value)),
        child: child,
      ),
    );
  }

  // ----------------------------------------------------------
  // Build
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF153522).withValues(alpha: 0.55), _bgColor],
            stops: const [0, 0.42],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? _buildLoading()
              : (_error != null ? _buildError() : _buildContent()),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.6);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Calculating your rewards…', style: TextStyle(color: muted)),
        ],
      ),
    );
  }

  Widget _buildError() {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.65);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: _red, size: 48),
              const SizedBox(height: 14),
              const Text(
                'Could not save your lesson',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                '$_error',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 18),
              _PrimaryButton(label: 'Try again', onTap: _retry),
              const SizedBox(height: 10),
              _SecondaryButton(
                label: 'Back to DSA World',
                onTap: _backToDSAHome,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final wide = MediaQuery.of(context).size.width >= 600;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  wide ? 24 : 16,
                  28,
                  wide ? 24 : 16,
                  36,
                ),
                child: AnimatedBuilder(
                  animation: Listenable.merge([_intro, _pulse]),
                  builder: (context, _) {
                    return Column(
                      children: [
                        _reveal(0.0, 0.18, _buildHeader(wide)),
                        const SizedBox(height: 18),
                        _buildStars(),
                        const SizedBox(height: 22),
                        _reveal(0.18, 0.4, _buildXpCard(wide)),
                        const SizedBox(height: 16),
                        _reveal(0.42, 0.62, _buildLevelBar()),
                        const SizedBox(height: 16),
                        _reveal(0.52, 0.74, _buildStats(wide)),
                        const SizedBox(height: 16),
                        _reveal(0.68, 0.82, _buildChips()),
                        const SizedBox(height: 18),
                        _reveal(0.76, 0.92, _buildPatternCard()),
                        const SizedBox(height: 26),
                        _reveal(0.86, 1.0, _buildButtons()),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        // Confetti on top, never blocks taps
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ConfettiPainter(
                animation: _confetti,
                particles: _particles,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool wide) {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.65);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'LESSON COMPLETE',
            style: TextStyle(
              color: _green,
              fontSize: 10,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'You '),
              TextSpan(
                text: 'cracked',
                style: TextStyle(color: _green),
              ),
              const TextSpan(text: ' it!'),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: wide ? 38 : 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You discovered the intuition!',
          style: TextStyle(color: muted, fontSize: wide ? 15 : 13),
        ),
        if (_title.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_difficulty.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Text(
                    _difficulty,
                    style: TextStyle(
                      color: _difficultyColor(_difficulty),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStars() {
    final stars = _stars;
    final labels = ['KEEP PRACTISING', 'GREAT JOB', 'PERFECT'];
    final label = labels[stars - 1];
    final labelColor = stars == 3 ? _amber : (stars == 2 ? _green : _cyan);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final scale = _stage(
              0.1 + index * 0.07,
              0.3 + index * 0.07,
              Curves.elasticOut,
            );
            final earned = index < stars;
            return Padding(
              padding: EdgeInsets.only(top: index == 1 ? 0 : 10),
              child: Opacity(
                opacity: min(1.0, scale),
                child: Transform.scale(
                  scale: scale,
                  child: Icon(
                    Icons.star_rounded,
                    size: index == 1 ? 64 : 52,
                    color: earned
                        ? _amber
                        : Colors.white.withValues(alpha: 0.12),
                    shadows: earned
                        ? [
                            Shadow(
                              color: _amber.withValues(alpha: 0.6),
                              blurRadius: 18,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Opacity(
          opacity: _stage(0.3, 0.42),
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 12,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildXpCard(bool wide) {
    final shown = (_xpEarned * _stage(0.22, 0.6)).round();
    final glow = 0.14 + 0.16 * _pulse.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1A0D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _amber.withValues(alpha: 0.85), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: _amber.withValues(alpha: glow),
            blurRadius: 34,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bolt_rounded, color: _amber, size: 30),
              const SizedBox(width: 4),
              Text(
                '+$shown',
                style: TextStyle(
                  fontSize: wide ? 64 : 52,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  color: _amber,
                  letterSpacing: -1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'XP EARNED',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBar() {
    final fraction = (_totalXP % 1000) / 1000;
    final startFraction = _leveledUp ? 0.0 : (_previousXP % 1000) / 1000;
    final animated =
        startFraction + (fraction - startFraction) * _stage(0.5, 0.8);
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.6);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'LEVEL $_level',
                  style: const TextStyle(
                    color: _green,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (_leveledUp) ...[
                const SizedBox(width: 10),
                Transform.scale(
                  scale: 1 + 0.06 * _pulse.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _violet.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _violet.withValues(alpha: 0.6)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          color: _violet,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'LEVEL UP!',
                          style: TextStyle(
                            color: _violet,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '${_totalXP % 1000} / 1000 XP',
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: animated.clamp(0.0, 1.0).toDouble(),
              minHeight: 9,
              backgroundColor: const Color(0xFF20382A),
              valueColor: const AlwaysStoppedAnimation<Color>(_green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(bool wide) {
    final progress = _stage(0.58, 0.9);
    final intuition = _StatCard(
      icon: Icons.lightbulb_rounded,
      iconColor: _amber,
      label: 'Intuition Challenges',
      correct: _correctIntuition,
      total: _totalIntuition,
      progress: progress,
    );
    final transfer = _StatCard(
      icon: Icons.sync_rounded,
      iconColor: _cyan,
      label: 'Transfer Questions',
      correct: _correctTransfer,
      total: _totalTransfer,
      progress: progress,
    );

    if (wide) {
      // IntrinsicHeight: a Row with "stretch" needs a bounded height, and
      // this page scrolls, so the height is taken from the tallest card.
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: intuition),
            const SizedBox(width: 14),
            Expanded(child: transfer),
          ],
        ),
      );
    }
    return Column(children: [intuition, const SizedBox(height: 12), transfer]);
  }

  Widget _buildChips() {
    final chips = <Widget>[];
    if (_streak > 0) {
      chips.add(
        _InfoChip(
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFFFA94D),
          text: '$_streak day streak',
        ),
      );
    }
    if (_topicTotal > 0) {
      chips.add(
        _InfoChip(
          icon: Icons.folder_open_rounded,
          color: _green,
          text: '${_topic ?? 'Topic'} · $_topicDone/$_topicTotal done',
        ),
      );
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: chips,
    );
  }

  Widget _buildPatternCard() {
    final glow = 0.12 + 0.18 * _pulse.value;
    final name = _patternName.isNotEmpty ? _patternName : 'A new pattern';
    final tip = _keyInsight.isNotEmpty
        ? _keyInsight
        : 'Look for the same idea the next time you see a similar problem.';

    final locked = Container(
      key: const ValueKey('locked'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1226),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _violet.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(color: _violet.withValues(alpha: glow), blurRadius: 26),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _violet.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.lock_rounded, color: _violet, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEW PATTERN READY',
                  style: TextStyle(
                    color: _violet,
                    fontSize: 11,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Tap to unlock what you just learned',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const Icon(Icons.touch_app_rounded, color: _violet),
        ],
      ),
    );

    final unlocked = Container(
      key: const ValueKey('unlocked'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1226),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _violet),
        boxShadow: [
          BoxShadow(color: _violet.withValues(alpha: 0.22), blurRadius: 28),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_open_rounded, color: _violet, size: 20),
              SizedBox(width: 8),
              Text(
                'PATTERN UNLOCKED',
                style: TextStyle(
                  color: _violet,
                  fontSize: 12,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            tip,
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        if (!_patternUnlocked) setState(() => _patternUnlocked = true);
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 520),
        transitionBuilder: (child, animation) {
          return AnimatedBuilder(
            animation: animation,
            child: child,
            builder: (context, child) {
              final angle = (1 - animation.value) * (pi / 2);
              return Opacity(
                opacity: animation.value.clamp(0.0, 1.0).toDouble(),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateX(angle),
                  child: child,
                ),
              );
            },
          );
        },
        child: _patternUnlocked ? unlocked : locked,
      ),
    );
  }

  Widget _buildButtons() {
    final next = _nextProblem;
    return Column(
      children: [
        _PrimaryButton(
          label: next != null ? 'Next challenge' : 'Choose another problem',
          subtitle: next != null ? (next['title'] ?? '').toString() : null,
          icon: Icons.arrow_forward_rounded,
          onTap: _openNext,
        ),
        const SizedBox(height: 12),
        _SecondaryButton(label: 'Back to DSA World', onTap: _backToDSAHome),
      ],
    );
  }
}

// ============================================================
// WIDGETS
// ============================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final int correct;
  final int total;
  final double progress;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.correct,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final perfect = total > 0 && correct >= total;
    final ratio = total > 0 ? correct / total : 1.0;
    final accent = perfect ? _green : iconColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: perfect ? _green.withValues(alpha: 0.7) : _borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                total > 0 ? '$correct/$total' : '$correct',
                style: TextStyle(
                  color: accent,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (ratio * progress).clamp(0.0, 1.0).toDouble(),
              minHeight: 6,
              backgroundColor: const Color(0xFF20382A),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 7),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3EAD58),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 12),
              Icon(icon, size: 22),
            ],
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: _green,
          side: const BorderSide(color: _borderColor),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

// ============================================================
// CONFETTI
// ============================================================

class _Particle {
  final double x0;
  final double vy;
  final double drift;
  final double phase;
  final double size;
  final double spin;
  final double delay;
  final Color color;

  const _Particle({
    required this.x0,
    required this.vy,
    required this.drift,
    required this.phase,
    required this.size,
    required this.spin,
    required this.delay,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  final List<_Particle> particles;

  _ConfettiPainter({required this.animation, required this.particles})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    if (t <= 0 || t >= 1) return;

    for (final particle in particles) {
      final local = ((t - particle.delay) / (1 - particle.delay))
          .clamp(0.0, 1.0)
          .toDouble();
      if (local <= 0) continue;

      final y = (local * particle.vy * 1.3 - 0.05) * size.height;
      final x =
          (particle.x0 + particle.drift * sin(local * 9 + particle.phase)) *
          size.width;
      final fade = local < 0.8 ? 1.0 : (1 - local) / 0.2;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.spin * local * 2 * pi);
      final paint = Paint()
        ..color = particle.color.withValues(
          alpha: fade.clamp(0.0, 1.0).toDouble(),
        );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.55,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => false;
}
