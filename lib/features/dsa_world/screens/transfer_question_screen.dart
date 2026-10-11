import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/dsa_service.dart';
import '../../../widgets/hint_deck_widgets.dart';

// Same palette as the DSA World home screen, Hint Deck and Key Insight.
const Color _mint = HintDeckColors.mint;
const Color _mintSoft = HintDeckColors.mintSoft;
const Color _card = HintDeckColors.card;
const Color _panel = HintDeckColors.panel;
const Color _border = HintDeckColors.border;
const Color _borderStrong = HintDeckColors.borderStrong;
const Color _text = HintDeckColors.text;
const Color _text2 = HintDeckColors.textSecondary;
const Color _muted = HintDeckColors.textMuted;
const Color _gold = HintDeckColors.gold;
const Color _red = Color(0xFFF87171);

class TransferQuestionScreen extends StatefulWidget {
  final String problemId;
  final int correctIntuitionChallenges;

  const TransferQuestionScreen({
    Key? key,
    required this.problemId,
    required this.correctIntuitionChallenges,
  }) : super(key: key);

  @override
  State<TransferQuestionScreen> createState() => _TransferQuestionScreenState();
}

class _TransferQuestionScreenState extends State<TransferQuestionScreen> {
  late Future<Map<String, dynamic>> _problemFuture;
  int currentQuestionIndex = 0;
  int correctTransferAnswers = 0;
  int? selectedOption;
  bool showFeedback = false;
  bool isCorrect = false;

  // UI-only: right/wrong per question for the mastery track.
  final Map<int, bool> _results = {};
  bool _saving = false;

  static const List<LogicalKeyboardKey> _optionKeys = [
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyB,
    LogicalKeyboardKey.keyC,
    LogicalKeyboardKey.keyD,
  ];

  @override
  void initState() {
    super.initState();
    _problemFuture = DSAService.getProblem(widget.problemId);
  }

  void _selectOption(int optionIndex, List<dynamic> transferQuestions) {
    if (showFeedback || currentQuestionIndex >= transferQuestions.length) {
      return;
    }

    final question = transferQuestions[currentQuestionIndex];
    final correct = optionIndex == question['correct'];

    setState(() {
      selectedOption = optionIndex;
      isCorrect = correct;
      showFeedback = true;
      _results[currentQuestionIndex] = correct;

      if (correct) {
        correctTransferAnswers++;
      }
    });
    if (correct) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _nextQuestion(List<dynamic> transferQuestions) {
    if (currentQuestionIndex < transferQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOption = null;
        showFeedback = false;
      });
    } else {
      _completeLesson();
    }
  }

  /// FIX: the server only counts the transfer XP bonus from saved progress
  /// (it reads correctTransferQuestions in submit-solution). The old screen
  /// never saved it, so the bonus was always 0. Save it first, then continue.
  Future<void> _completeLesson() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await DSAService.checkpoint(
        widget.problemId,
        correctIntuitionChallenges: widget.correctIntuitionChallenges,
        correctTransferQuestions: correctTransferAnswers,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't save your score. Check your connection and try again.",
          ),
        ),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      '/dsa-lesson-completion',
      arguments: {
        'problemId': widget.problemId,
        'correctIntuitionChallenges': widget.correctIntuitionChallenges,
        'correctTransferQuestions': correctTransferAnswers,
      },
    );
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
          child: FutureBuilder<Map<String, dynamic>>(
            future: _problemFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: _mint),
                );
              }

              if (snapshot.hasError) {
                return _messageView(
                  icon: Icons.error_outline_rounded,
                  title: 'Something went wrong',
                  body: '${snapshot.error}',
                  buttonLabel: 'Go back',
                  onPressed: () => Navigator.maybePop(context),
                );
              }

              final problem = snapshot.data?['problem'] ?? {};
              final transferQuestions =
                  problem['transferQuestions'] as List<dynamic>? ?? [];

              if (transferQuestions.isEmpty) {
                return _messageView(
                  icon: Icons.celebration_rounded,
                  title: 'Lesson complete!',
                  body: 'No verification questions for this lesson.',
                  buttonLabel: 'See Results',
                  busy: _saving,
                  onPressed: _completeLesson,
                );
              }

              if (currentQuestionIndex >= transferQuestions.length) {
                return _messageView(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'All questions completed!',
                  body: '',
                  buttonLabel: 'See Results',
                  busy: _saving,
                  onPressed: _completeLesson,
                );
              }

              return _buildQuestion(context, problem, transferQuestions);
            },
          ),
        ),
      ),
    );
  }

  Widget _messageView({
    required IconData icon,
    required String title,
    required String body,
    required String buttonLabel,
    required VoidCallback onPressed,
    bool busy = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52, color: _mint),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _text,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (body.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _text2, fontSize: 14),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: DeckGradientButton(
                  label: buttonLabel,
                  trailingIcon: Icons.arrow_forward_rounded,
                  onPressed: onPressed,
                  busy: busy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(
    BuildContext context,
    dynamic problem,
    List<dynamic> transferQuestions,
  ) {
    final question = transferQuestions[currentQuestionIndex] as Map;
    final scenario = (question['scenario'] ?? '').toString();
    final questionText = (question['question'] ?? '').toString();
    final options = List<String>.from(question['options'] ?? []);
    final total = transferQuestions.length;
    final isLast = currentQuestionIndex == total - 1;

    final xpMap = problem['xpReward'];
    final int perCorrect = (xpMap is Map && xpMap['transferCorrect'] is num)
        ? (xpMap['transferCorrect'] as num).toInt()
        : 0;

    final isDesktop = const {
      TargetPlatform.windows,
      TargetPlatform.macOS,
      TargetPlatform.linux,
    }.contains(Theme.of(context).platform);

    final correctIndex = question['correct'];
    final String correctText =
        (correctIndex is int &&
            correctIndex >= 0 &&
            correctIndex < options.length)
        ? '${String.fromCharCode(65 + correctIndex)}. ${options[correctIndex]}'
        : '';

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        for (int i = 0; i < options.length && i < _optionKeys.length; i++)
          SingleActivator(_optionKeys[i]): () =>
              _selectOption(i, transferQuestions),
        const SingleActivator(LogicalKeyboardKey.enter): () {
          if (showFeedback) _nextQuestion(transferQuestions);
        },
      },
      child: Focus(
        autofocus: true,
        child: SingleChildScrollView(
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
                                    text: 'Verify ',
                                    style: TextStyle(color: _mint),
                                  ),
                                  TextSpan(text: 'Understanding'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 44),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Text(
                          'MASTERY  ·  $correctTransferAnswers/$total',
                          style: const TextStyle(
                            color: _mint,
                            fontSize: 12,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        if (perCorrect > 0)
                          TweenAnimationBuilder<int>(
                            tween: IntTween(
                              begin: 0,
                              end: perCorrect * correctTransferAnswers,
                            ),
                            duration: deckMotion(context, 700),
                            curve: Curves.easeOut,
                            builder: (context, v, _) => DeckXpBadge(
                              label: '+$v XP bonus',
                              compact: true,
                              color: _mint,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _MasteryTrack(
                      total: total,
                      current: currentQuestionIndex,
                      results: _results,
                    ),
                    const SizedBox(height: 22),
                    AnimatedSwitcher(
                      duration: deckMotion(context, 320),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: SizedBox(
                        key: ValueKey(currentQuestionIndex),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ScenarioCard(
                              scenario: scenario,
                              number: currentQuestionIndex + 1,
                              total: total,
                            ),
                            const SizedBox(height: 22),
                            Text(
                              questionText,
                              style: const TextStyle(
                                color: _text,
                                fontSize: 23,
                                height: 1.45,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 22),
                            ...options.asMap().entries.map((entry) {
                              final optionIndex = entry.key;
                              final isSelected = selectedOption == optionIndex;
                              final isCorrectOption =
                                  optionIndex == question['correct'];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _OptionTile(
                                  index: optionIndex,
                                  text: entry.value,
                                  isSelected: isSelected,
                                  isRight: showFeedback && isCorrectOption,
                                  isWrong:
                                      showFeedback && isSelected && !isCorrect,
                                  showFeedback: showFeedback,
                                  onTap: () => _selectOption(
                                    optionIndex,
                                    transferQuestions,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (showFeedback) ...[
                      _VerdictPanel(
                        correct: isCorrect,
                        xp: perCorrect,
                        correctText: correctText,
                      ),
                      const SizedBox(height: 18),
                      DeckGradientButton(
                        label: isLast ? 'Complete Lesson' : 'Next Question',
                        trailingIcon: Icons.arrow_forward_rounded,
                        onPressed: () => _nextQuestion(transferQuestions),
                        busy: _saving,
                        height: 56,
                      ),
                      if (isDesktop)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Center(
                            child: Text(
                              'press ENTER to continue',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1,
                                fontFamily: 'monospace',
                                color: _muted,
                              ),
                            ),
                          ),
                        ),
                    ] else
                      Center(
                        child: Text(
                          isDesktop
                              ? 'pick an answer  ·  press A – D'
                              : 'pick an answer to continue',
                          style: const TextStyle(
                            fontSize: 12,
                            letterSpacing: 1,
                            fontFamily: 'monospace',
                            color: _muted,
                          ),
                        ),
                      ),
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

// ---------------------------------------------------------------------------
// Mastery track
// ---------------------------------------------------------------------------

class _MasteryTrack extends StatelessWidget {
  final int total;
  final int current;
  final Map<int, bool> results;

  const _MasteryTrack({
    required this.total,
    required this.current,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final answered = results.containsKey(i);
        Color c = HintDeckColors.track;
        if (answered) {
          c = results[i]! ? _mint : _red;
        } else if (i == current) {
          c = _mintSoft;
        }
        return Expanded(
          child: AnimatedContainer(
            duration: deckMotion(context, 300),
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            height: 8,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(4),
              boxShadow:
                  (answered && results[i]!) || (!answered && i == current)
                  ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 10)]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Scenario card
// ---------------------------------------------------------------------------

const Set<String> _arrayNames = {
  'nums',
  'nums1',
  'nums2',
  'arr',
  'array',
  'heights',
  'height',
  'prices',
  'numbers',
  'values',
  'data',
  'cost',
  'costs',
  'temperatures',
  'piles',
};

/// Finds "nums = [0,2,0,5]" style arrays so they can be drawn as cells.
/// Only well-known array names are drawn, so trees and other structures are
/// never shown as a flat array by mistake.
({String name, List<String> items})? _parseArray(String scenario) {
  final m = RegExp(r'([A-Za-z_]\w*)\s*=\s*\[([^\[\]]*)\]').firstMatch(scenario);
  if (m == null) return null;
  final name = m.group(1)!;
  if (!_arrayNames.contains(name.toLowerCase())) return null;
  final items = m
      .group(2)!
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  if (items.isEmpty || items.length > 12 || items.any((e) => e.length > 5)) {
    return null;
  }
  return (name: name, items: items);
}

class _ScenarioCard extends StatelessWidget {
  final String scenario;
  final int number;
  final int total;

  const _ScenarioCard({
    required this.scenario,
    required this.number,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final arr = _parseArray(scenario);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderStrong),
        boxShadow: [
          BoxShadow(color: _mint.withValues(alpha: 0.08), blurRadius: 28),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: HintDeckColors.iconBox,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderStrong),
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  color: _mint,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'NEW SCENARIO',
                  style: TextStyle(
                    color: _mint,
                    fontSize: 12,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'Transfer $number/$total',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (arr != null) ...[
            _ArrayCells(items: arr.items),
            const SizedBox(height: 14),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Text(
              scenario,
              style: const TextStyle(
                color: _text,
                fontSize: 15,
                height: 1.5,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrayCells extends StatelessWidget {
  final List<String> items;

  const _ArrayCells({required this.items});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(items.length, (i) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: deckMotion(context, 300 + i * 70),
              curve: Curves.easeOutBack,
              builder: (context, v, child) => Opacity(
                opacity: math.min(1.0, math.max(0.0, v)),
                child: Transform.scale(scale: v, child: child),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: HintDeckColors.iconBox,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _borderStrong),
                      ),
                      child: Center(
                        child: Text(
                          items[i],
                          style: const TextStyle(
                            color: _text,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$i',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Options
// ---------------------------------------------------------------------------

class _OptionTile extends StatefulWidget {
  final int index;
  final String text;
  final bool isSelected;
  final bool isRight;
  final bool isWrong;
  final bool showFeedback;
  final VoidCallback onTap;

  const _OptionTile({
    required this.index,
    required this.text,
    required this.isSelected,
    required this.isRight,
    required this.isWrong,
    required this.showFeedback,
    required this.onTap,
  });

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final dimmed = w.showFeedback && !w.isRight && !w.isWrong;

    Color border = _border;
    Color fill = Colors.white.withValues(alpha: 0.03);
    Color keyColor = _text2;
    List<BoxShadow>? glow;

    if (w.isRight) {
      border = _mint;
      fill = _mint.withValues(alpha: 0.12);
      keyColor = _mint;
      glow = [BoxShadow(color: _mint.withValues(alpha: 0.25), blurRadius: 18)];
    } else if (w.isWrong) {
      border = _red;
      fill = _red.withValues(alpha: 0.12);
      keyColor = _red;
    } else if (w.isSelected) {
      border = _mintSoft;
      fill = _mintSoft.withValues(alpha: 0.1);
      keyColor = _mintSoft;
    } else if (_hover && !w.showFeedback) {
      border = _mint.withValues(alpha: 0.6);
      fill = _mint.withValues(alpha: 0.06);
      keyColor = _mint;
    }

    Widget tile = AnimatedContainer(
      duration: deckMotion(context, 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: border, width: 1.5),
        borderRadius: BorderRadius.circular(14),
        boxShadow: glow,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: deckMotion(context, 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (w.isRight || w.isWrong)
                        ? keyColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: keyColor, width: 1.5),
                  ),
                  child: Center(
                    child: w.isRight
                        ? const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: HintDeckColors.ink,
                          )
                        : w.isWrong
                        ? const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: HintDeckColors.ink,
                          )
                        : Text(
                            String.fromCharCode(65 + w.index),
                            style: TextStyle(
                              color: keyColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                  ),
                ),
                if (w.isRight) const _Spark(),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              w.text,
              style: const TextStyle(color: _text, fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );

    if (w.isWrong) {
      tile = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: deckMotion(context, 450),
        builder: (context, v, child) => Transform.translate(
          offset: Offset(math.sin(v * math.pi * 5) * 8 * (1 - v), 0),
          child: child,
        ),
        child: tile,
      );
    }

    return MouseRegion(
      cursor: w.showFeedback
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: w.onTap,
        child: AnimatedOpacity(
          duration: deckMotion(context, 250),
          opacity: dimmed ? 0.45 : 1,
          child: tile,
        ),
      ),
    );
  }
}

/// A short ring of sparks around the correct answer's key. Draws nothing
/// when the system asks for reduced motion.
class _Spark extends StatefulWidget {
  const _Spark();

  @override
  State<_Spark> createState() => _SparkState();
}

class _SparkState extends State<_Spark> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
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
          size: const Size(32, 32),
          painter: _SparkPainter(_c.value),
        ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final double t;
  const _SparkPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final center = size.center(Offset.zero);
    final eased = Curves.easeOutCubic.transform(t);
    for (int i = 0; i < 10; i++) {
      final a = i * math.pi * 2 / 10;
      final dist = 16 + 22 * eased;
      final color = i % 3 == 0 ? _gold : (i.isEven ? _mint : _mintSoft);
      canvas.drawCircle(
        center + Offset(math.cos(a), math.sin(a)) * dist,
        2.8 * (1 - t) + 0.5,
        Paint()..color = color.withValues(alpha: 1 - t),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Verdict
// ---------------------------------------------------------------------------

class _VerdictPanel extends StatelessWidget {
  final bool correct;
  final int xp;
  final String correctText;

  const _VerdictPanel({
    required this.correct,
    required this.xp,
    required this.correctText,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct ? _mint : _red;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: deckMotion(context, 350),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - v)),
          child: child,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.55)),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 24),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              correct ? Icons.verified_rounded : Icons.info_outline_rounded,
              color: color,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    correct ? 'Transfer confirmed' : 'Not this time',
                    style: TextStyle(
                      color: color,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    correct
                        ? 'You carried the idea into a brand new situation.'
                        : (correctText.isEmpty
                              ? 'Think about how the idea applies here.'
                              : 'The answer was $correctText. Same idea, new situation.'),
                    style: const TextStyle(
                      color: _text2,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            if (correct && xp > 0) ...[
              const SizedBox(width: 12),
              DeckXpBadge(label: '+$xp XP', color: _mint),
            ],
          ],
        ),
      ),
    );
  }
}
