import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../services/dsa_service.dart';
import '../../../widgets/hint_deck_widgets.dart';

class HintProgressionScreen extends StatefulWidget {
  final String problemId;

  const HintProgressionScreen({Key? key, required this.problemId})
    : super(key: key);

  @override
  State<HintProgressionScreen> createState() => _HintProgressionScreenState();
}

class _HintProgressionScreenState extends State<HintProgressionScreen> {
  static const List<String> _stageNames = [
    'Direction',
    'Observation',
    'Pattern',
    'Reveal',
  ];
  static const List<IconData> _stageIcons = [
    Icons.explore_outlined,
    Icons.search_rounded,
    Icons.grid_view_rounded,
    Icons.lightbulb_outline_rounded,
  ];
  static const String _subtitle =
      'Take one hint at a time. Think, reveal and move forward!';

  late Future<Map<String, dynamic>> _problemFuture;

  // level -> hint text. Always a prefix: 0..n-1 (hints unlock in order).
  final Map<int, String> revealedHints = {};
  int _viewIndex = 0; // which hint is on screen
  bool _busy = false; // a reveal request is in flight

  @override
  void initState() {
    super.initState();
    _problemFuture = DSAService.getProblem(widget.problemId).then((data) {
      _restoreRevealed(data);
      return data;
    });
  }

  /// Hints the server already recorded for this user are shown as revealed,
  /// so they are never revealed (or charged) a second time.
  void _restoreRevealed(Map<String, dynamic> data) {
    final problem = data['problem'];
    if (problem is! Map) return;
    final hints = List<String>.from(problem['hints'] ?? []);
    final progress = problem['userProgress'];
    final used = <int>{};
    if (progress is Map && progress['hintsUsed'] is List) {
      for (final v in progress['hintsUsed'] as List) {
        if (v is num) used.add(v.toInt());
      }
    }
    int i = 0;
    while (i < hints.length && i < 4 && used.contains(i)) {
      revealedHints[i] = hints[i];
      i++;
    }
    _viewIndex = math.min(i, math.max(0, math.min(hints.length, 4) - 1));
  }

  Future<void> _requestHint(int hintLevel, List<String> hints) async {
    if (_busy) return;
    if (revealedHints.containsKey(hintLevel)) return; // never charge twice
    if (hintLevel > 0 && !revealedHints.containsKey(hintLevel - 1)) return;

    setState(() => _busy = true);
    try {
      final result = await DSAService.getHint(widget.problemId, hintLevel);
      final hint = (result['hint'] ?? '').toString();
      if (!mounted) return;
      setState(() {
        revealedHints[hintLevel] = hint.isEmpty ? hints[hintLevel] : hint;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _backToChallenge() {
    Navigator.pop(context);
  }

  // ---- XP helpers (read from the problem's own xpReward, never hardcoded) ----

  List<int?> _xpSequence(Map problem) {
    final x = problem['xpReward'];
    if (x is! Map) return const [];
    int? g(String k) => x[k] is num ? (x[k] as num).toInt() : null;
    return [g('noHint'), g('hint1'), g('hint2'), g('hint3'), g('reveal')];
  }

  /// XP lost by revealing hint [level] (0-based): reward tier before minus after.
  int? _costOf(int level, List<int?> seq) {
    if (seq.length < 5 || level < 0 || level > 3) return null;
    final a = seq[level];
    final b = seq[level + 1];
    if (a == null || b == null) return null;
    return a - b;
  }

  int? _rewardNow(List<int?> seq, int revealedCount) {
    if (seq.length < 5) return null;
    return seq[math.min(revealedCount, 4)];
  }

  // ---------------------------------------------------------------------------

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
                  child: CircularProgressIndicator(color: HintDeckColors.mint),
                );
              }
              if (snapshot.hasError) {
                return _message('Error: ${snapshot.error}');
              }

              final problem = snapshot.data?['problem'] ?? {};
              final hints = List<String>.from(problem['hints'] ?? []);
              if (hints.isEmpty) {
                return _message('No hints available');
              }
              return _buildDeck(context, problem, hints);
            },
          ),
        ),
      ),
    );
  }

  Widget _message(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: HintDeckColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 220,
              child: DeckOutlineButton(
                label: 'Back to Question',
                leadingIcon: Icons.arrow_back_rounded,
                onPressed: _backToChallenge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeck(BuildContext context, Map problem, List<String> hints) {
    final total = math.min(hints.length, 4);
    final title = (problem['title'] ?? 'Problem').toString();
    final topics = problem['topics'];
    final topic = (topics is List && topics.isNotEmpty)
        ? topics.first.toString()
        : 'Problem';

    final seq = _xpSequence(problem);
    final revealedCount = revealedHints.length;
    final level = _viewIndex;
    final isRevealed = revealedHints.containsKey(level);
    final isLocked = level > 0 && !revealedHints.containsKey(level - 1);
    final cost = _costOf(level, seq);
    final reward = _rewardNow(seq, revealedCount);

    final nextToReveal = math.min(revealedCount, total - 1);
    final completed = revealedHints.keys.toSet();
    final reachable = {for (int i = 0; i <= nextToReveal; i++) i};
    final canGoNext = isRevealed && level + 1 < total;

    final allCostsEqual =
        seq.length == 5 &&
        List.generate(4, (i) => _costOf(i, seq)).toSet().length == 1;
    final costCaption = cost == null
        ? 'Each hint lowers your lesson reward.'
        : (allCostsEqual
              ? 'per hint, taken off your lesson reward'
              : 'for this hint, taken off your lesson reward');

    HintDeckCard cardFor(bool compact) => HintDeckCard(
      compact: compact,
      level: level + 1,
      stageName: _stageNames[level],
      icon: _stageIcons[level],
      state: isRevealed
          ? HintCardState.revealed
          : (isLocked ? HintCardState.locked : HintCardState.hidden),
      hintText: revealedHints[level],
      costLabel: cost == null ? null : '$cost XP',
      costNote: cost == null
          ? null
          : 'Revealing it lowers your lesson reward by $cost XP.',
      revealLabel: cost == null ? 'Reveal Hint' : 'Reveal Hint  ·  −$cost XP',
      busy: _busy,
      onReveal: () => _requestHint(level, hints),
    );

    return LayoutBuilder(
      builder: (context, c) {
        final mobile = c.maxWidth < 760;
        final pad = mobile ? 16.0 : 28.0;

        final tracker = DeckStepTracker(
          labels: _stageNames.sublist(0, total),
          activeIndex: level,
          completed: completed,
          reachable: reachable,
          compact: mobile,
          onSelect: (i) => setState(() => _viewIndex = i),
        );

        final nextButton = DeckGradientButton(
          label: 'Next Hint',
          trailingIcon: Icons.arrow_forward_rounded,
          onPressed: canGoNext
              ? () => setState(() => _viewIndex = level + 1)
              : null,
        );
        final backButton = DeckOutlineButton(
          label: 'Back to Question',
          leadingIcon: Icons.arrow_back_rounded,
          onPressed: _backToChallenge,
        );

        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
                child: mobile
                    ? _mobileLayout(
                        title: title,
                        reward: reward,
                        tracker: tracker,
                        card: cardFor(true),
                        total: total,
                        level: level,
                        revealedCount: revealedCount,
                        cost: cost,
                        costCaption: costCaption,
                        backButton: backButton,
                        nextButton: nextButton,
                      )
                    : _desktopLayout(
                        title: title,
                        topic: topic,
                        reward: reward,
                        tracker: tracker,
                        card: cardFor(false),
                        total: total,
                        revealedCount: revealedCount,
                        cost: cost,
                        costCaption: costCaption,
                        backButton: backButton,
                        nextButton: nextButton,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _xpBadge(int? reward, {bool compact = false}) {
    if (reward == null) return const SizedBox.shrink();
    return Tooltip(
      message: 'Lesson reward you can still earn',
      child: DeckXpBadge(
        label: '$reward XP',
        compact: compact,
        color: HintDeckColors.mint,
      ),
    );
  }

  Widget _titleText(double size) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w800,
          color: HintDeckColors.text,
        ),
        children: const [
          TextSpan(
            text: 'Hint ',
            style: TextStyle(color: HintDeckColors.mint),
          ),
          TextSpan(text: 'Deck'),
        ],
      ),
    );
  }

  Widget _desktopLayout({
    required String title,
    required String topic,
    required int? reward,
    required Widget tracker,
    required Widget card,
    required int total,
    required int revealedCount,
    required int? cost,
    required String costCaption,
    required Widget backButton,
    required Widget nextButton,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            DeckIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back to question',
              onTap: _backToChallenge,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    color: HintDeckColors.textSecondary,
                    fontSize: 14,
                  ),
                  children: [
                    const TextSpan(text: 'DSA World  ›  '),
                    TextSpan(
                      text: '$topic  ›  ',
                      style: const TextStyle(color: HintDeckColors.mint),
                    ),
                    TextSpan(
                      text: title,
                      style: const TextStyle(color: HintDeckColors.text),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _xpBadge(reward),
            const SizedBox(width: 12),
            DeckHintRing(revealed: revealedCount, total: total),
          ],
        ),
        const SizedBox(height: 28),
        Center(child: _titleText(40)),
        const SizedBox(height: 8),
        const Text(
          _subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: HintDeckColors.textSecondary, fontSize: 15),
        ),
        const SizedBox(height: 28),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: tracker,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 72,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: DeckLayeredCard(spread: 12, child: card),
              ),
            ),
            const SizedBox(width: 28),
            Expanded(
              flex: 28,
              child: Column(
                children: [
                  DeckProgressPanel(revealed: revealedCount, total: total),
                  const SizedBox(height: 14),
                  DeckCostPanel(cost: cost, caption: costCaption),
                  const SizedBox(height: 14),
                  const DeckWhyPanel(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(color: HintDeckColors.border.withValues(alpha: 0.7), height: 1),
        const SizedBox(height: 20),
        Row(
          children: [
            SizedBox(width: 220, child: backButton),
            const Spacer(),
            SizedBox(width: 200, child: nextButton),
          ],
        ),
      ],
    );
  }

  Widget _mobileLayout({
    required String title,
    required int? reward,
    required Widget tracker,
    required Widget card,
    required int total,
    required int level,
    required int revealedCount,
    required int? cost,
    required String costCaption,
    required Widget backButton,
    required Widget nextButton,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 88,
              child: Align(
                alignment: Alignment.centerLeft,
                child: DeckIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Back to question',
                  onTap: _backToChallenge,
                ),
              ),
            ),
            Expanded(child: Center(child: _titleText(20))),
            // Keeps the title centred when there is no XP badge.
            SizedBox(
              width: 88,
              child: Align(
                alignment: Alignment.centerRight,
                child: _xpBadge(reward, compact: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(
            color: HintDeckColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          _subtitle,
          style: TextStyle(
            color: HintDeckColors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        tracker,
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.only(bottom: 26),
          child: DeckLayeredCard(spread: 5, child: card),
        ),
        DeckPagerDots(count: total, active: level),
        const SizedBox(height: 20),
        DeckProgressPanel(revealed: revealedCount, total: total),
        const SizedBox(height: 12),
        DeckCostPanel(cost: cost, caption: costCaption),
        const SizedBox(height: 12),
        const DeckWhyPanel(),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: backButton),
            const SizedBox(width: 12),
            Expanded(child: nextButton),
          ],
        ),
      ],
    );
  }
}
