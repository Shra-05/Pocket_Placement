import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/dsa_service.dart';
import '../../../widgets/challenge_visual.dart';

// Visual language: dark "lab" background, green / cyan accents, mono labels.
const Color _bg = Color(0xFF0A0D0C);
const Color _panel = Color(0xFF111715);
const Color _accent = Color(0xFF10B981);
const Color _cyan = Color(0xFF22D3EE);
const Color _danger = Color(0xFFF87171);

class IntuitionGameScreen extends StatefulWidget {
  final String problemId;

  const IntuitionGameScreen({super.key, required this.problemId});

  @override
  State<IntuitionGameScreen> createState() => _IntuitionGameScreenState();
}

class _IntuitionGameScreenState extends State<IntuitionGameScreen> {
  late Future<Map<String, dynamic>> _problemFuture;

  // FIX: store the loaded problem so tap handlers can read it
  Map<String, dynamic>? _problem;

  int currentChallengeIndex = 0;
  int correctAnswers = 0;
  int? selectedOption;
  bool showFeedback = false;
  bool isCorrect = false;

  // UI-only: remembers right/wrong per question for the step track + combo.
  final Map<int, bool> _results = {};

  static const List<LogicalKeyboardKey> _optionKeys = [
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyB,
    LogicalKeyboardKey.keyC,
    LogicalKeyboardKey.keyD,
  ];

  @override
  void initState() {
    super.initState();
    // FIX: save the problem data when the request finishes
    _problemFuture = DSAService.getProblem(widget.problemId).then((data) {
      _problem = Map<String, dynamic>.from(data['problem'] ?? {});
      return data;
    });
  }

  // FIX: return the stored problem instead of always returning null
  Map<String, dynamic>? _getProblem() => _problem;

  void _selectOption(int optionIndex) {
    if (showFeedback) return;

    final problem = _getProblem();
    if (problem == null) return;

    final challenges = (problem['intuitionChallenges'] as List?) ?? [];
    if (challenges.isEmpty) return;

    final challenge = challenges[currentChallengeIndex];
    final correct = optionIndex == challenge['correct'];

    setState(() {
      selectedOption = optionIndex;
      isCorrect = correct;
      showFeedback = true;
      _results[currentChallengeIndex] = correct;

      if (correct) {
        correctAnswers++;
      }
    });
  }

  void _nextChallenge() {
    final problem = _getProblem();
    if (problem == null) return;

    final challenges = (problem['intuitionChallenges'] as List?) ?? [];
    if (currentChallengeIndex < challenges.length - 1) {
      setState(() {
        currentChallengeIndex++;
        selectedOption = null;
        showFeedback = false;
      });
    } else {
      _navigateToKeyInsight();
    }
  }

  void _requestHint() {
    Navigator.of(context).pushNamed(
      '/dsa-hint-progression',
      arguments: {'problemId': widget.problemId},
    );
  }

  void _navigateToKeyInsight() {
    Navigator.of(context).pushReplacementNamed(
      '/dsa-key-insight',
      arguments: {
        'problemId': widget.problemId,
        'correctIntuitionChallenges': correctAnswers,
      },
    );
  }

  // Consecutive correct answers ending at the latest answered question.
  int get _combo {
    int count = 0;
    int i = showFeedback ? currentChallengeIndex : currentChallengeIndex - 1;
    while (i >= 0 && _results[i] == true) {
      count++;
      i--;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'INTUITION LAB',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 3,
            fontWeight: FontWeight.w700,
            color: _accent,
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          FutureBuilder<Map<String, dynamic>>(
            future: _problemFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: _accent),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              final problem = snapshot.data?['problem'] ?? {};
              final challenges = List<Map<String, dynamic>>.from(
                problem['intuitionChallenges'] ?? [],
              );

              if (challenges.isEmpty) {
                return const Center(child: Text('No challenges found'));
              }

              if (currentChallengeIndex >= challenges.length) {
                return const Center(child: Text('All challenges completed!'));
              }

              final challenge = challenges[currentChallengeIndex];
              final question = (challenge['question'] ?? '').toString();
              final options = List<String>.from(challenge['options'] ?? []);
              final feedback = challenge['feedback'] ?? {};
              final rawVisual = challenge['visual'];
              final Map<String, dynamic>? visual = rawVisual is Map
                  ? Map<String, dynamic>.from(rawVisual)
                  : null;
              final title = (problem['title'] ?? '').toString();
              final isLast = currentChallengeIndex == challenges.length - 1;

              final String feedbackText =
                  (isCorrect
                          ? (feedback['correct'] ?? 'Great! You understand.')
                          : (feedback['incorrect'] ??
                                'Think more carefully about this.'))
                      .toString();

              final isDesktop = const {
                TargetPlatform.windows,
                TargetPlatform.macOS,
                TargetPlatform.linux,
              }.contains(Theme.of(context).platform);

              return CallbackShortcuts(
                bindings: <ShortcutActivator, VoidCallback>{
                  for (
                    int i = 0;
                    i < options.length && i < _optionKeys.length;
                    i++
                  )
                    SingleActivator(_optionKeys[i]): () => _selectOption(i),
                  const SingleActivator(LogicalKeyboardKey.enter): () {
                    if (showFeedback) _nextChallenge();
                  },
                },
                child: Focus(
                  autofocus: true,
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(title, _combo),
                              const SizedBox(height: 16),
                              _StepTrack(
                                total: challenges.length,
                                current: currentChallengeIndex,
                                results: _results,
                              ),
                              const SizedBox(height: 20),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 320),
                                transitionBuilder: (child, anim) =>
                                    FadeTransition(
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
                                  key: ValueKey(currentChallengeIndex),
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildStage(
                                        question,
                                        challenges.length,
                                        visual,
                                      ),
                                      const SizedBox(height: 20),
                                      ...options.asMap().entries.map((entry) {
                                        final optionIndex = entry.key;
                                        final optionText = entry.value;
                                        final isSelected =
                                            selectedOption == optionIndex;
                                        final isCorrectOption =
                                            optionIndex == challenge['correct'];

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: _OptionTile(
                                            index: optionIndex,
                                            text: optionText,
                                            isSelected: isSelected,
                                            isRight:
                                                showFeedback && isCorrectOption,
                                            isWrong:
                                                showFeedback &&
                                                isSelected &&
                                                !isCorrect,
                                            showFeedback: showFeedback,
                                            onTap: () =>
                                                _selectOption(optionIndex),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                              if (isDesktop && !showFeedback)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4, bottom: 8),
                                  child: Text(
                                    'press A – D to answer',
                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 1,
                                      fontFamily: 'monospace',
                                      color: Colors.white30,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              if (showFeedback) ...[
                                _buildTrace(isCorrect, feedbackText),
                                const SizedBox(height: 20),
                                if (!isLast)
                                  _primaryButton(
                                    'Next Question',
                                    _nextChallenge,
                                  )
                                else
                                  _primaryButton(
                                    'See Key Insight',
                                    _navigateToKeyInsight,
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
                                          color: Colors.white30,
                                        ),
                                      ),
                                    ),
                                  ),
                              ] else ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: _cyan,
                                      side: BorderSide(
                                        color: _cyan.withValues(alpha: 0.6),
                                        width: 1.5,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: _requestHint,
                                    icon: const Icon(
                                      Icons.lightbulb_outline_rounded,
                                    ),
                                    label: const Text(
                                      'Get a Hint',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, int combo) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PROBLEM',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                  color: Colors.white38,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: combo >= 2
              ? Container(
                  key: ValueKey(combo),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.6),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '🔥 ×$combo',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('no-combo')),
        ),
      ],
    );
  }

  Widget _dot(Color c) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildStage(String question, int total, Map<String, dynamic>? visual) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: _accent.withValues(alpha: 0.08), blurRadius: 30),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
            child: Row(
              children: [
                _dot(_danger),
                const SizedBox(width: 6),
                _dot(const Color(0xFFFBBF24)),
                const SizedBox(width: 6),
                _dot(_accent),
                const SizedBox(width: 14),
                Text(
                  'challenge_${(currentChallengeIndex + 1).toString().padLeft(2, '0')}.q',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Colors.white38,
                  ),
                ),
                const Spacer(),
                Text(
                  'Question ${currentChallengeIndex + 1}/$total',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SCENARIO',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: _cyan,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  question,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    height: 1.45,
                  ),
                ),
                if (visual != null) ...[
                  const SizedBox(height: 18),
                  ChallengeVisual(
                    key: ValueKey('visual-$currentChallengeIndex'),
                    visual: visual,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrace(bool correct, String text) {
    final color = correct ? _accent : _danger;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
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
        decoration: BoxDecoration(
          color: const Color(0xFF070A09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 24),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(13),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '>_ INSIGHT_LOG',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    correct ? '✅ Correct!' : '❌ Not quite',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _Typewriter(
                text: text,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: const Color(0xFF04130D),
          elevation: 8,
          shadowColor: _accent.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Segmented "step engine" progress: green = right, red = wrong,
/// glowing cyan = current, dim = upcoming.
class _StepTrack extends StatelessWidget {
  final int total;
  final int current;
  final Map<int, bool> results;

  const _StepTrack({
    required this.total,
    required this.current,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final answered = results.containsKey(i);
        Color c = Colors.white12;
        if (answered) {
          c = results[i]! ? _accent : _danger;
        } else if (i == current) {
          c = _cyan;
        }
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            height: 6,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(3),
              boxShadow: (i == current && !answered)
                  ? [
                      BoxShadow(
                        color: _cyan.withValues(alpha: 0.6),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

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

    Color border = Colors.white.withValues(alpha: 0.12);
    Color fill = Colors.white.withValues(alpha: 0.03);
    Color keyColor = Colors.white54;
    List<BoxShadow>? glow;

    if (w.isRight) {
      border = _accent;
      fill = _accent.withValues(alpha: 0.12);
      keyColor = _accent;
      glow = [
        BoxShadow(color: _accent.withValues(alpha: 0.25), blurRadius: 18),
      ];
    } else if (w.isWrong) {
      border = _danger;
      fill = _danger.withValues(alpha: 0.12);
      keyColor = _danger;
    } else if (w.isSelected) {
      border = _cyan;
      fill = _cyan.withValues(alpha: 0.1);
      keyColor = _cyan;
    } else if (_hover && !w.showFeedback) {
      border = _cyan.withValues(alpha: 0.6);
      fill = _cyan.withValues(alpha: 0.06);
      keyColor = _cyan;
    }

    Widget tile = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: border, width: 1.5),
        borderRadius: BorderRadius.circular(14),
        boxShadow: glow,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (w.isRight || w.isWrong) ? keyColor : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: keyColor, width: 1.5),
            ),
            child: Center(
              child: w.isRight
                  ? const Icon(Icons.check_rounded, size: 18, color: _bg)
                  : w.isWrong
                  ? const Icon(Icons.close_rounded, size: 18, color: _bg)
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
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              w.text,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );

    if (w.isWrong) {
      tile = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 450),
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
          duration: const Duration(milliseconds: 250),
          opacity: dimmed ? 0.45 : 1,
          child: tile,
        ),
      ),
    );
  }
}

/// Reveals text character by character. The full text is laid out invisibly
/// underneath so the panel height never jumps while typing.
class _Typewriter extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _Typewriter({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: text.length),
      duration: Duration(
        milliseconds: math.min(1500, math.max(300, text.length * 14)),
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

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
