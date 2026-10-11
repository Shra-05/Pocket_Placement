import 'dart:math' as math;

import 'package:flutter/material.dart';

// Put this file at: lib/widgets/hint_deck_widgets.dart
//
// Presentation-only widgets for the Hint Deck screen. They hold no business
// logic: the screen decides what is revealed, what costs XP and where to go.

class HintDeckColors {
  // Sampled from the DSA World home screen so both pages share one look.
  static const Color bg = Color(0xFF090D0B); // page background
  static const Color bgGlow = Color(0xFF102218); // soft green at the top
  static const Color card = Color(0xFF101713); // cards
  static const Color panel = Color(0xFF151B17); // raised rows / panels
  static const Color iconBox = Color(0xFF1D3426); // icon squares
  static const Color track = Color(0xFF20382A); // progress tracks
  static const Color border = Color(0xFF264434); // card borders
  static const Color borderStrong = Color(0xFF2E5C3E); // emphasised borders
  static const Color mint = Color(0xFF55D68A); // main accent (buttons, active)
  static const Color mintSoft = Color(0xFF7BE3A6);
  static const Color text = Color(0xFFE6E0E9);
  static const Color textSecondary = Color(0xFF929094);
  static const Color textMuted = Color(0xFF6F6E72);
  static const Color gold = Color(0xFFFFC247); // XP cost only
  static const Color ink = Color(0xFF07130B); // dark text on green
  static const Color gradientStart = Color(0xFF60DD94);
  static const Color gradientEnd = Color(0xFF4FC67F);
}

/// Animation length that respects the system "reduce motion" setting.
Duration deckMotion(BuildContext context, [int ms = 250]) =>
    MediaQuery.of(context).disableAnimations
    ? Duration.zero
    : Duration(milliseconds: ms);

/// Splits a hint into a short headline (first sentence) and the rest.
({String head, String rest}) splitDeckHint(String text) {
  final t = text.trim();
  for (int i = 0; i < t.length - 1; i++) {
    final ch = t[i];
    if ((ch == '.' || ch == '?' || ch == '!') && t[i + 1] == ' ') {
      return (head: t.substring(0, i + 1), rest: t.substring(i + 2).trim());
    }
  }
  return (head: t, rest: '');
}

/// Words wrapped in *asterisks* inside hint text are drawn in mint.
/// Hints without asterisks are drawn as plain text.
List<InlineSpan> deckEmphasis(String text, TextStyle base) {
  final parts = text.split('*');
  if (parts.length < 3 || parts.length.isEven) {
    return [TextSpan(text: text.replaceAll('*', ''), style: base)];
  }
  return [
    for (int i = 0; i < parts.length; i++)
      if (parts[i].isNotEmpty)
        TextSpan(
          text: parts[i],
          style: i.isOdd ? base.copyWith(color: HintDeckColors.mint) : base,
        ),
  ];
}

// ---------------------------------------------------------------------------
// Small pieces
// ---------------------------------------------------------------------------

class DeckXpBadge extends StatelessWidget {
  final String label;
  final bool compact;
  final Color color;

  const DeckXpBadge({
    super.key,
    required this.label,
    this.compact = false,
    this.color = HintDeckColors.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, size: compact ? 16 : 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class DeckHintRing extends StatelessWidget {
  final int revealed;
  final int total;

  const DeckHintRing({super.key, required this.revealed, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: HintDeckColors.panel,
        border: Border.all(color: HintDeckColors.border),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: total == 0 ? 0 : revealed / total),
              duration: deckMotion(context, 400),
              builder: (context, v, _) => CircularProgressIndicator(
                value: v,
                strokeWidth: 3,
                backgroundColor: HintDeckColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  HintDeckColors.mint,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$revealed / $total hints',
            style: const TextStyle(
              color: HintDeckColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class DeckIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const DeckIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: HintDeckColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: HintDeckColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: HintDeckColors.text, size: 20),
          ),
        ),
      ),
    );
  }
}

class DeckPagerDots extends StatelessWidget {
  final int count;
  final int active;

  const DeckPagerDots({super.key, required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final on = i == active;
        return AnimatedContainer(
          duration: deckMotion(context, 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: on ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: on ? HintDeckColors.mint : HintDeckColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Press-animated buttons
// ---------------------------------------------------------------------------

class _Pressable extends StatefulWidget {
  final BoxDecoration decoration;
  final VoidCallback? onTap;
  final double height;
  final BorderRadius radius;
  final Widget child;

  const _Pressable({
    required this.decoration,
    required this.onTap,
    required this.height,
    required this.radius,
    required this.child,
  });

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: (_down && widget.onTap != null) ? 0.97 : 1.0,
      duration: deckMotion(context, 90),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: widget.height,
          decoration: widget.decoration,
          child: InkWell(
            borderRadius: widget.radius,
            onTap: widget.onTap,
            onHighlightChanged: (v) => setState(() => _down = v),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}

class DeckGradientButton extends StatelessWidget {
  final String label;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final bool busy;
  final double height;

  const DeckGradientButton({
    super.key,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    required this.onPressed,
    this.busy = false,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    final fg = onPressed == null
        ? HintDeckColors.textMuted
        : HintDeckColors.ink;
    final radius = BorderRadius.circular(14);

    return _Pressable(
      height: height,
      radius: radius,
      onTap: enabled ? onPressed : null,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: onPressed == null
            ? null
            : const LinearGradient(
                colors: [
                  HintDeckColors.gradientStart,
                  HintDeckColors.gradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: onPressed == null ? HintDeckColors.panel : null,
        border: onPressed == null
            ? Border.all(color: HintDeckColors.border)
            : null,
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: HintDeckColors.mint.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: busy
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(fg),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, size: 20, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, size: 20, color: fg),
                  ],
                ],
              ),
            ),
    );
  }
}

class DeckOutlineButton extends StatelessWidget {
  final String label;
  final IconData? leadingIcon;
  final VoidCallback? onPressed;
  final double height;

  const DeckOutlineButton({
    super.key,
    required this.label,
    this.leadingIcon,
    required this.onPressed,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return _Pressable(
      height: height,
      radius: radius,
      onTap: onPressed,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: HintDeckColors.panel.withValues(alpha: 0.6),
        border: Border.all(color: HintDeckColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 20, color: HintDeckColors.mint),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: HintDeckColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stage tracker
// ---------------------------------------------------------------------------

class DeckStepTracker extends StatelessWidget {
  final List<String> labels;
  final int activeIndex;
  final Set<int> completed;
  final Set<int> reachable;
  final ValueChanged<int> onSelect;
  final bool compact;

  const DeckStepTracker({
    super.key,
    required this.labels,
    required this.activeIndex,
    required this.completed,
    required this.reachable,
    required this.onSelect,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final n = labels.length;
    if (n == 0) return const SizedBox.shrink();
    final r = compact ? 16.0 : 20.0;

    final furthest = <int>{...completed, activeIndex}.reduce(math.max);
    final fraction = n > 1 ? furthest / (n - 1) : 0.0;

    return Stack(
      children: [
        if (n > 1)
          Positioned(
            top: r - 1,
            left: 0,
            right: 0,
            child: Center(
              child: FractionallySizedBox(
                widthFactor: (n - 1) / n,
                child: SizedBox(
                  height: 2,
                  child: Stack(
                    children: [
                      Container(color: HintDeckColors.border),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: fraction),
                        duration: deckMotion(context, 350),
                        curve: Curves.easeOut,
                        builder: (context, v, _) => Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: v,
                            child: Container(color: HintDeckColors.mint),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Row(
          children: List.generate(n, (i) {
            return Expanded(
              child: _StepItem(
                number: i + 1,
                label: labels[i],
                radius: r,
                compact: compact,
                active: i == activeIndex,
                done: completed.contains(i),
                reachable: reachable.contains(i),
                onTap: reachable.contains(i) ? () => onSelect(i) : null,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final int number;
  final String label;
  final double radius;
  final bool compact;
  final bool active;
  final bool done;
  final bool reachable;
  final VoidCallback? onTap;

  const _StepItem({
    required this.number,
    required this.label,
    required this.radius,
    required this.compact,
    required this.active,
    required this.done,
    required this.reachable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color fill = HintDeckColors.panel;
    Color border = HintDeckColors.border;
    Color fg = HintDeckColors.textMuted;
    Widget content = Text(
      '$number',
      style: TextStyle(
        color: fg,
        fontWeight: FontWeight.w700,
        fontSize: compact ? 13 : 15,
      ),
    );
    List<BoxShadow>? glow;

    if (active) {
      fill = HintDeckColors.mint;
      border = HintDeckColors.mint;
      glow = [
        BoxShadow(
          color: HintDeckColors.mint.withValues(alpha: 0.35),
          blurRadius: 14,
        ),
      ];
      content = done
          ? Icon(
              Icons.check_rounded,
              size: compact ? 18 : 20,
              color: HintDeckColors.ink,
            )
          : Text(
              '$number',
              style: TextStyle(
                color: HintDeckColors.ink,
                fontWeight: FontWeight.w800,
                fontSize: compact ? 13 : 15,
              ),
            );
    } else if (done) {
      fill = HintDeckColors.card;
      border = HintDeckColors.mint;
      content = Icon(
        Icons.check_rounded,
        size: compact ? 18 : 20,
        color: HintDeckColors.mint,
      );
    } else if (reachable) {
      border = HintDeckColors.mint.withValues(alpha: 0.5);
      content = Text(
        '$number',
        style: TextStyle(
          color: HintDeckColors.text,
          fontWeight: FontWeight.w700,
          fontSize: compact ? 13 : 15,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: deckMotion(context, 250),
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fill,
              border: Border.all(color: border, width: 2),
              boxShadow: glow,
            ),
            child: Center(child: content),
          ),
          SizedBox(height: compact ? 6 : 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active
                  ? HintDeckColors.mint
                  : (reachable || done
                        ? HintDeckColors.textSecondary
                        : HintDeckColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main hint card
// ---------------------------------------------------------------------------

enum HintCardState { hidden, revealed, locked }

/// Two faint offset cards behind the main one, built from plain rectangles.
class DeckLayeredCard extends StatelessWidget {
  final Widget child;
  final double spread;

  const DeckLayeredCard({super.key, required this.child, this.spread = 12});

  Widget _layer(double a) => DecoratedBox(
    decoration: BoxDecoration(
      color: HintDeckColors.card.withValues(alpha: a),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: HintDeckColors.border.withValues(alpha: a)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -spread * 2,
          right: -spread * 2,
          top: 22,
          bottom: -22,
          child: _layer(0.35),
        ),
        Positioned(
          left: -spread,
          right: -spread,
          top: 11,
          bottom: -11,
          child: _layer(0.65),
        ),
        child,
      ],
    );
  }
}

class HintDeckCard extends StatelessWidget {
  final int level; // 1-based
  final String stageName;
  final IconData icon;
  final String? costLabel;
  final String? costNote;
  final String? hintText;
  final HintCardState state;
  final bool busy;
  final String revealLabel;
  final VoidCallback? onReveal;
  final bool compact;

  const HintDeckCard({
    super.key,
    required this.level,
    required this.stageName,
    required this.icon,
    required this.state,
    required this.revealLabel,
    required this.onReveal,
    this.costLabel,
    this.costNote,
    this.hintText,
    this.busy = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final pad = compact ? 20.0 : 32.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14231A), HintDeckColors.card],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HintDeckColors.borderStrong, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: HintDeckColors.mint.withValues(alpha: 0.06),
            blurRadius: 28,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          SizedBox(height: compact ? 18 : 28),
          AnimatedSize(
            duration: deckMotion(context, 250),
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
                key: ValueKey('$level-${state.name}'),
                child: _body(),
              ),
            ),
          ),
          SizedBox(height: compact ? 20 : 28),
          _action(),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: compact ? 44 : 52,
          height: compact ? 44 : 52,
          decoration: BoxDecoration(
            color: HintDeckColors.iconBox,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: HintDeckColors.borderStrong),
          ),
          child: Icon(
            icon,
            color: HintDeckColors.mint,
            size: compact ? 22 : 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hint $level',
                style: TextStyle(
                  color: HintDeckColors.text,
                  fontSize: compact ? 18 : 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stageName.toUpperCase(),
                style: const TextStyle(
                  color: HintDeckColors.mint,
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (costLabel != null) DeckXpBadge(label: costLabel!, compact: compact),
      ],
    );
  }

  Widget _bar(double factor) {
    return FractionallySizedBox(
      widthFactor: factor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: compact ? 10 : 12,
        decoration: BoxDecoration(
          color: HintDeckColors.border.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _body() {
    if (state == HintCardState.revealed) {
      final parts = splitDeckHint(hintText ?? '');
      final headStyle = TextStyle(
        color: HintDeckColors.text,
        fontSize: compact ? 22 : 30,
        height: 1.25,
        fontWeight: FontWeight.w800,
      );
      final restStyle = TextStyle(
        color: HintDeckColors.textSecondary,
        fontSize: compact ? 15 : 18,
        height: 1.6,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(TextSpan(children: deckEmphasis(parts.head, headStyle))),
          if (parts.rest.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: 64,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    HintDeckColors.mint.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text.rich(TextSpan(children: deckEmphasis(parts.rest, restStyle))),
          ],
        ],
      );
    }

    final locked = state == HintCardState.locked;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 20,
              color: HintDeckColors.mint.withValues(alpha: 0.85),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                locked
                    ? 'Reveal the previous hint first'
                    : 'Hidden until you reveal it',
                style: TextStyle(
                  color: HintDeckColors.text,
                  fontSize: compact ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _bar(0.92),
        const SizedBox(height: 10),
        _bar(0.7),
        const SizedBox(height: 10),
        _bar(0.82),
        if (!locked && costNote != null) ...[
          const SizedBox(height: 16),
          Text(
            costNote!,
            style: const TextStyle(
              color: HintDeckColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }

  Widget _action() {
    if (state == HintCardState.revealed) {
      return Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: HintDeckColors.mint.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: HintDeckColors.mint.withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: HintDeckColors.mint,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Hint Revealed',
              style: TextStyle(
                color: HintDeckColors.mint,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: DeckGradientButton(
        label: revealLabel,
        leadingIcon: Icons.visibility_outlined,
        onPressed: state == HintCardState.locked ? null : onReveal,
        busy: busy,
        height: compact ? 50 : 54,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Supporting panels
// ---------------------------------------------------------------------------

class DeckInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const DeckInfoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HintDeckColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HintDeckColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: HintDeckColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class DeckProgressPanel extends StatelessWidget {
  final int revealed;
  final int total;

  const DeckProgressPanel({
    super.key,
    required this.revealed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return DeckInfoCard(
      icon: Icons.insights_rounded,
      iconColor: HintDeckColors.mint,
      title: 'Your Progress',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$revealed of $total hints unlocked',
            style: const TextStyle(
              color: HintDeckColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(total, (i) {
              return Expanded(
                child: AnimatedContainer(
                  duration: deckMotion(context, 300),
                  height: 6,
                  margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: i < revealed
                        ? HintDeckColors.mint
                        : HintDeckColors.track,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class DeckCostPanel extends StatelessWidget {
  final int? cost;
  final String caption;

  const DeckCostPanel({super.key, required this.cost, required this.caption});

  @override
  Widget build(BuildContext context) {
    return DeckInfoCard(
      icon: Icons.bolt_rounded,
      iconColor: HintDeckColors.gold,
      title: 'Hint Cost',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cost == null ? 'Lowers your reward' : '$cost XP',
            style: const TextStyle(
              color: HintDeckColors.gold,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: const TextStyle(
              color: HintDeckColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class DeckWhyPanel extends StatelessWidget {
  const DeckWhyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const DeckInfoCard(
      icon: Icons.lightbulb_outline_rounded,
      iconColor: HintDeckColors.mintSoft,
      title: 'Why use hints?',
      child: Text(
        'Hints help you build intuition without giving away the full solution.',
        style: TextStyle(
          color: HintDeckColors.textSecondary,
          fontSize: 13,
          height: 1.5,
        ),
      ),
    );
  }
}
