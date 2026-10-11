import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/dsa_service.dart';
import '../../../widgets/hint_deck_widgets.dart';

// Same palette as the DSA World home screen and the Hint Deck.
const Color _mint = HintDeckColors.mint;
const Color _card = HintDeckColors.card;
const Color _panel = HintDeckColors.panel;
const Color _border = HintDeckColors.border;
const Color _borderStrong = HintDeckColors.borderStrong;
const Color _text = HintDeckColors.text;
const Color _text2 = HintDeckColors.textSecondary;
const Color _muted = HintDeckColors.textMuted;
const Color _gold = HintDeckColors.gold;
const Color _red = Color(0xFFF87171);

String _s(dynamic v) => (v ?? '').toString();
Map<String, dynamic> _m(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

class _InsightData {
  final Map<String, dynamic> solution;
  final Map<String, dynamic> problem;
  const _InsightData(this.solution, this.problem);
}

class _StageSpec {
  final String key;
  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
  final String unlockLabel;
  const _StageSpec(
    this.key,
    this.label,
    this.title,
    this.subtitle,
    this.icon,
    this.unlockLabel,
  );
}

class KeyInsightScreen extends StatefulWidget {
  final String problemId;
  final int correctIntuitionChallenges;

  const KeyInsightScreen({
    Key? key,
    required this.problemId,
    required this.correctIntuitionChallenges,
  }) : super(key: key);

  @override
  State<KeyInsightScreen> createState() => _KeyInsightScreenState();
}

class _KeyInsightScreenState extends State<KeyInsightScreen> {
  late Future<_InsightData> _future;
  int _unlockedCount = 0; // cards unlock in order
  final List<GlobalKey> _cardKeys = List.generate(3, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_InsightData> _load() async {
    final solutionFuture = DSAService.getSolution(widget.problemId);
    // The problem is only used for extras (score, XP). Never fail the page on it.
    final problemFuture = DSAService.getProblem(widget.problemId)
        .then<Map<String, dynamic>>((d) => _m(d['problem']))
        .catchError((_) => <String, dynamic>{});

    final raw = await solutionFuture;
    // The backend returns the fields at the top level. Accept a nested
    // "solution" object too, in case that ever changes.
    final solution = raw['solution'] is Map ? _m(raw['solution']) : raw;
    final problem = await problemFuture;
    return _InsightData(solution, problem);
  }

  void _continueToTransfer() {
    Navigator.of(context).pushReplacementNamed(
      '/dsa-transfer-question',
      arguments: {
        'problemId': widget.problemId,
        'correctIntuitionChallenges': widget.correctIntuitionChallenges,
      },
    );
  }

  void _unlockNext(int total) {
    if (_unlockedCount >= total) return;
    HapticFeedback.lightImpact();
    setState(() => _unlockedCount++);
    final idx = _unlockedCount - 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _cardKeys[idx].currentContext;
      if (ctx != null && mounted) {
        Scrollable.ensureVisible(
          ctx,
          duration: deckMotion(context, 450),
          curve: Curves.easeOutCubic,
          alignment: 0.04,
        );
      }
    });
  }

  void _unlockAll(int total) {
    HapticFeedback.mediumImpact();
    setState(() => _unlockedCount = total);
  }

  /// XP still available, using the same rules as the server:
  /// a base reward that depends on hints used + a bonus per correct transfer.
  int? _xpOnTheLine(Map<String, dynamic> problem) {
    final xp = problem['xpReward'];
    final progress = problem['userProgress'];
    if (xp is! Map || progress is! Map || progress['hintsUsed'] is! List) {
      return null;
    }
    int g(String k) => xp[k] is num ? (xp[k] as num).toInt() : 0;
    final hints = (progress['hintsUsed'] as List).length;
    final int base;
    if (hints == 0) {
      base = g('noHint');
    } else if (hints == 1) {
      base = g('hint1');
    } else if (hints == 2) {
      base = g('hint2');
    } else if (hints == 3) {
      base = g('hint3');
    } else {
      base = g('reveal');
    }
    final transfers = problem['transferQuestions'] is List
        ? (problem['transferQuestions'] as List).length
        : 0;
    return base + transfers * g('transferCorrect');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HintDeckColors.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [HintDeckColors.bgGlow, HintDeckColors.bg],
            stops: [0.0, 0.55],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<_InsightData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: _mint),
                );
              }
              if (snapshot.hasError) {
                return _errorView('Error: ${snapshot.error}');
              }
              return _buildBody(context, snapshot.data!);
            },
          ),
        ),
      ),
    );
  }

  Widget _errorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _text2, fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: DeckOutlineButton(
                label: 'Go back',
                leadingIcon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, _InsightData data) {
    final sol = data.solution;
    final problem = data.problem;

    final keyInsight = _s(sol['keyInsight']);
    final brute = _m(sol['bruteForceApproach']);
    final optimal = _m(sol['optimalApproach']);
    final patternName = _s(sol['patternName']);

    bool hasAny(Map<String, dynamic> a) =>
        _s(a['description']).isNotEmpty ||
        _s(a['timeComplexity']).isNotEmpty ||
        _s(a['spaceComplexity']).isNotEmpty;
    final hasApproaches = hasAny(brute) || hasAny(optimal);

    final stages = <_StageSpec>[
      const _StageSpec(
        'insight',
        'Insight',
        'Key Intuition',
        'The big idea behind this problem',
        Icons.lightbulb_rounded,
        'Unlock Insight',
      ),
      if (hasApproaches)
        const _StageSpec(
          'compare',
          'Compare',
          'Brute Force vs Optimized',
          'See why the smarter way wins',
          Icons.compare_arrows_rounded,
          'Compare Approaches',
        ),
      if (patternName.isNotEmpty)
        const _StageSpec(
          'pattern',
          'Pattern',
          'Pattern Unlocked',
          'A tool you can reuse',
          Icons.auto_awesome_rounded,
          'Reveal Pattern',
        ),
    ];
    final total = stages.length;
    final allDone = _unlockedCount >= total;

    final challenges = problem['intuitionChallenges'];
    final int? totalChallenges = challenges is List ? challenges.length : null;
    final topics = problem['topics'] is List
        ? List<String>.from(
            (problem['topics'] as List).map((e) => e.toString()),
          )
        : <String>[];
    final xpLine = _xpOnTheLine(problem);

    Widget content(String key) {
      switch (key) {
        case 'insight':
          return _InsightContent(text: keyInsight);
        case 'compare':
          return _CompareContent(brute: brute, optimal: optimal);
        default:
          return _PatternContent(name: patternName, topics: topics);
      }
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    DeckIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Back',
                      onTap: () => Navigator.maybePop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text.rich(
                          const TextSpan(
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _text,
                            ),
                            children: [
                              TextSpan(
                                text: 'Key ',
                                style: TextStyle(color: _mint),
                              ),
                              TextSpan(text: 'Insight'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
                const SizedBox(height: 20),
                _ScoreCard(
                  correct: widget.correctIntuitionChallenges,
                  total: totalChallenges,
                ),
                const SizedBox(height: 22),
                DeckStepTracker(
                  labels: [for (final s in stages) s.label],
                  activeIndex: math.min(_unlockedCount, total - 1),
                  completed: {for (int i = 0; i < _unlockedCount; i++) i},
                  reachable: {
                    for (int i = 0; i <= _unlockedCount && i < total; i++) i,
                  },
                  onSelect: (i) {
                    if (i == _unlockedCount) _unlockNext(total);
                  },
                ),
                const SizedBox(height: 24),
                for (int i = 0; i < total; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: KeyedSubtree(
                      key: _cardKeys[i],
                      child: _StageCard(
                        spec: stages[i],
                        unlocked: i < _unlockedCount,
                        available: i == _unlockedCount,
                        onUnlock: () => _unlockNext(total),
                        content: content(stages[i].key),
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                if (xpLine != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt_rounded, size: 18, color: _gold),
                        const SizedBox(width: 6),
                        Text(
                          'Verify your understanding to earn up to $xpLine XP',
                          style: const TextStyle(
                            color: _gold,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                DeckGradientButton(
                  label: 'Verify Understanding',
                  trailingIcon: allDone
                      ? Icons.arrow_forward_rounded
                      : Icons.lock_outline_rounded,
                  onPressed: allDone ? _continueToTransfer : null,
                  height: 56,
                ),
                if (!allDone)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: TextButton(
                        onPressed: () => _unlockAll(total),
                        child: const Text(
                          'Skip ahead and reveal everything',
                          style: TextStyle(color: _text2, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Score + stars
// ---------------------------------------------------------------------------

class _ScoreCard extends StatelessWidget {
  final int correct;
  final int? total;

  const _ScoreCard({required this.correct, required this.total});

  @override
  Widget build(BuildContext context) {
    final t = total;
    final known = t != null && t > 0;
    int stars = 0;
    String message = 'Now lock the idea in.';
    if (known) {
      final pct = correct / t!;
      if (pct >= 0.8) {
        stars = 3;
        message = 'Sharp intuition!';
      } else if (pct >= 0.5) {
        stars = 2;
        message = 'Solid instincts. This page will sharpen them.';
      } else {
        stars = 1;
        message = 'Good start. This page is where it clicks.';
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INTUITION ROUND COMPLETE',
                  style: TextStyle(
                    color: _mint,
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  known
                      ? '$correct of $t challenges right'
                      : '$correct challenges right',
                  style: const TextStyle(
                    color: _text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: _text2, fontSize: 13),
                ),
              ],
            ),
          ),
          if (known) _StarRow(stars: stars),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final int stars;

  const _StarRow({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final earned = i < stars;
        final icon = Icon(
          earned ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 30,
          color: earned ? _gold : _muted,
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: earned
              ? TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: deckMotion(context, 1400),
                  curve: Interval(
                    i * 0.22,
                    i * 0.22 + 0.45,
                    curve: Curves.elasticOut,
                  ),
                  builder: (context, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: icon,
                )
              : icon,
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Unlockable card
// ---------------------------------------------------------------------------

class _StageCard extends StatelessWidget {
  final _StageSpec spec;
  final bool unlocked;
  final bool available;
  final VoidCallback onUnlock;
  final Widget content;

  const _StageCard({
    required this.spec,
    required this.unlocked,
    required this.available,
    required this.onUnlock,
    required this.content,
  });

  Widget _bar(double f) => FractionallySizedBox(
    widthFactor: f,
    alignment: Alignment.centerLeft,
    child: Container(
      height: 11,
      decoration: BoxDecoration(
        color: _border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  );

  Widget _lockedBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bar(0.9),
        const SizedBox(height: 10),
        _bar(0.65),
        const SizedBox(height: 10),
        _bar(0.8),
        const SizedBox(height: 18),
        if (available)
          SizedBox(
            width: double.infinity,
            child: DeckGradientButton(
              label: spec.unlockLabel,
              leadingIcon: Icons.lock_open_rounded,
              onPressed: onUnlock,
            ),
          )
        else
          const Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 16, color: _muted),
              SizedBox(width: 8),
              Text(
                'Unlock the card above first',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: deckMotion(context, 300),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: unlocked ? _borderStrong : _border),
        boxShadow: [
          BoxShadow(
            color: _mint.withValues(alpha: unlocked ? 0.10 : 0.0),
            blurRadius: 28,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: deckMotion(context, 300),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: unlocked ? HintDeckColors.iconBox : _panel,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: unlocked ? _mint : _border,
                          width: unlocked ? 1.6 : 1,
                        ),
                        boxShadow: unlocked
                            ? [
                                BoxShadow(
                                  color: _mint.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        unlocked ? spec.icon : Icons.lock_outline_rounded,
                        color: unlocked ? _mint : _muted,
                        size: 26,
                      ),
                    ),
                    if (unlocked) const _Burst(),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spec.title,
                      style: TextStyle(
                        color: unlocked ? _text : _text2,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      spec.subtitle,
                      style: const TextStyle(color: _muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                unlocked ? 'UNLOCKED' : 'LOCKED',
                style: TextStyle(
                  color: unlocked ? _mint : _muted,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AnimatedSize(
            duration: deckMotion(context, 300),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: deckMotion(context, 300),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topLeft,
                children: [...previous, if (current != null) current],
              ),
              child: KeyedSubtree(
                key: ValueKey(unlocked),
                child: unlocked ? content : _lockedBody(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A short ring of sparks when a card unlocks. Draws nothing when the system
/// asks for reduced motion.
class _Burst extends StatefulWidget {
  const _Burst();

  @override
  State<_Burst> createState() => _BurstState();
}

class _BurstState extends State<_Burst> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !MediaQuery.of(context).disableAnimations) {
        _c.forward();
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          size: const Size(52, 52),
          painter: _BurstPainter(_c.value),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  final double t;
  const _BurstPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final center = size.center(Offset.zero);
    final eased = Curves.easeOutCubic.transform(t);
    for (int i = 0; i < 12; i++) {
      final a = i * math.pi * 2 / 12;
      final dist = 24 + 30 * eased;
      final color = i.isEven ? _mint : HintDeckColors.mintSoft;
      canvas.drawCircle(
        center + Offset(math.cos(a), math.sin(a)) * dist,
        3.2 * (1 - t) + 0.6,
        Paint()..color = (i % 4 == 0 ? _gold : color).withValues(alpha: 1 - t),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Card contents
// ---------------------------------------------------------------------------

class _InsightContent extends StatelessWidget {
  final String text;

  const _InsightContent({required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'IF YOU REMEMBER ONE THING, REMEMBER THIS',
          style: TextStyle(
            color: _mint,
            fontSize: 11,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _TypeText(
          text: text.isEmpty
              ? 'The key idea for this problem is not available yet.'
              : text,
          style: const TextStyle(
            color: _text,
            fontSize: 21,
            height: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TypeText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _TypeText({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: text.length),
      duration: deckMotion(
        context,
        math.min(1800, math.max(400, text.length * 16)),
      ),
      builder: (context, v, _) {
        final shown = math.min(v, text.length);
        return Stack(
          children: [
            Text(text, style: style.copyWith(color: Colors.transparent)),
            Text(text.substring(0, shown), style: style),
          ],
        );
      },
    );
  }
}

class _CompareContent extends StatelessWidget {
  final Map<String, dynamic> brute;
  final Map<String, dynamic> optimal;

  const _CompareContent({required this.brute, required this.optimal});

  @override
  Widget build(BuildContext context) {
    final bt = _s(brute['timeComplexity']);
    final ot = _s(optimal['timeComplexity']);
    final canRace = _opsFor(bt, 10) != null && _opsFor(ot, 10) != null;

    final bruteCard = _ApproachPanel(
      title: 'Brute Force',
      icon: Icons.hourglass_bottom_rounded,
      color: _red,
      description: _s(brute['description']),
      time: bt,
      space: _s(brute['spaceComplexity']),
    );
    final optimalCard = _ApproachPanel(
      title: 'Optimized',
      icon: Icons.bolt_rounded,
      color: _mint,
      description: _s(optimal['description']),
      time: ot,
      space: _s(optimal['spaceComplexity']),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth >= 560) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: bruteCard),
                  const SizedBox(width: 12),
                  Expanded(child: optimalCard),
                ],
              );
            }
            return Column(
              children: [bruteCard, const SizedBox(height: 12), optimalCard],
            );
          },
        ),
        if (canRace) ...[
          const SizedBox(height: 18),
          _ComplexityRace(brute: bt, optimal: ot),
        ],
      ],
    );
  }
}

class _ApproachPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final String time;
  final String space;

  const _ApproachPanel({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.time,
    required this.space,
  });

  Widget _chip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label  ', style: const TextStyle(color: _muted, fontSize: 11)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(color: _text2, fontSize: 13, height: 1.5),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (time.isNotEmpty) _chip('Time', time),
              if (space.isNotEmpty) _chip('Space', space),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Complexity race (interactive)
// ---------------------------------------------------------------------------

/// Turns a complexity string such as "O(n²)" or "O(n log n) per add" into a
/// number of steps for input size [n]. Returns null when it cannot tell, in
/// which case the race is simply not shown.
double? _opsFor(String raw, double n) {
  final lower = raw.toLowerCase();
  final start = lower.indexOf('o(');
  if (start < 0) return null;
  int depth = 0;
  int end = -1;
  for (int i = start + 1; i < lower.length; i++) {
    if (lower[i] == '(') depth++;
    if (lower[i] == ')') {
      depth--;
      if (depth == 0) {
        end = i;
        break;
      }
    }
  }
  if (end < 0) return null;

  final e = lower
      .substring(start + 2, end)
      .replaceAll(RegExp(r'[\s·*×]'), '')
      .replaceAll('²', '^2')
      .replaceAll('³', '^3')
      .replaceAll('ⁿ', '^n');
  final log2n = math.max(1.0, math.log(n) / math.ln2);

  switch (e) {
    case '1':
      return 1;
    case 'logn':
      return log2n;
    case 'n':
      return n;
    case 'nlogn':
      return n * log2n;
    case 'n^2':
      return n * n;
    case 'n^3':
      return n * n * n;
    case '2^n':
      return math.pow(2, math.min(n, 1000)).toDouble();
  }
  return null;
}

String _commas(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

String _fmtOps(double v) {
  if (!v.isFinite || v >= 1e15) {
    final p = v.isFinite ? (math.log(v) / math.ln10).floor() : 300;
    return '10^$p';
  }
  if (v >= 1e12) return '${(v / 1e12).toStringAsFixed(1)}T';
  if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(1)}B';
  if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
  if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(1)}K';
  return v.round().toString();
}

class _ComplexityRace extends StatefulWidget {
  final String brute;
  final String optimal;

  const _ComplexityRace({required this.brute, required this.optimal});

  @override
  State<_ComplexityRace> createState() => _ComplexityRaceState();
}

class _ComplexityRaceState extends State<_ComplexityRace> {
  double _exp = 2; // input size is 10^_exp

  @override
  Widget build(BuildContext context) {
    final n = math.pow(10, _exp).roundToDouble();
    final double b = _opsFor(widget.brute, n) ?? 1.0;
    final double o = _opsFor(widget.optimal, n) ?? 1.0;
    final double maxOps = math.max(b, o);
    final double bw = math.max(0.012, b / maxOps);
    final double ow = math.max(0.012, o / maxOps);
    final ratio = o > 0 ? b / o : 1.0;

    final String verdict;
    final Color verdictColor;
    if (ratio >= 1.5) {
      verdict = 'Optimized does about ${_fmtOps(ratio)}x less work here';
      verdictColor = _mint;
    } else if (ratio > 0.67) {
      verdict = 'About the same time here. Compare the space cost instead.';
      verdictColor = _text2;
    } else {
      verdict = 'This approach spends more time to save something else.';
      verdictColor = _gold;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed_rounded, size: 18, color: _mint),
              const SizedBox(width: 8),
              const Text(
                'Complexity race',
                style: TextStyle(
                  color: _text,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'n = ${_commas(n.toInt())}',
                style: const TextStyle(
                  color: _mint,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Drag the slider to grow the input and watch the work explode.',
            style: TextStyle(color: _muted, fontSize: 12),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _mint,
              inactiveTrackColor: HintDeckColors.track,
              thumbColor: _mint,
              overlayColor: _mint.withValues(alpha: 0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: _exp,
              min: 1,
              max: 6,
              onChanged: (v) => setState(() => _exp = v),
            ),
          ),
          _RaceBar(
            label: 'Brute force',
            ops: b,
            factor: bw,
            color: _red,
            motion: deckMotion(context, 160),
          ),
          const SizedBox(height: 10),
          _RaceBar(
            label: 'Optimized',
            ops: o,
            factor: ow,
            color: _mint,
            motion: deckMotion(context, 160),
          ),
          const SizedBox(height: 14),
          Text(
            verdict,
            style: TextStyle(
              color: verdictColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RaceBar extends StatelessWidget {
  final String label;
  final double ops;
  final double factor;
  final Color color;
  final Duration motion;

  const _RaceBar({
    required this.label,
    required this.ops,
    required this.factor,
    required this.color,
    required this.motion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: const TextStyle(color: _text2, fontSize: 12),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 12,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: HintDeckColors.track,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                AnimatedFractionallySizedBox(
                  duration: motion,
                  alignment: Alignment.centerLeft,
                  widthFactor: math.min(1.0, math.max(0.0, factor)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 78,
          child: Text(
            '${_fmtOps(ops)} steps',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pattern card
// ---------------------------------------------------------------------------

class _PatternContent extends StatelessWidget {
  final String name;
  final List<String> topics;

  const _PatternContent({required this.name, required this.topics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _mint.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _mint.withValues(alpha: 0.4)),
          ),
          child: const Text(
            'PATTERN',
            style: TextStyle(
              color: _mint,
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            color: _text,
            fontSize: 28,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (topics.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in topics)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _border),
                  ),
                  child: Text(
                    t,
                    style: const TextStyle(color: _text2, fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        const Text(
          'Spot this pattern early and you will know where to start.',
          style: TextStyle(color: _text2, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }
}
