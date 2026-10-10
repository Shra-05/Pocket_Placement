import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

// Put this file at: lib/features/dsa_world/widgets/challenge_visual.dart
//
// Renders a step-by-step animation from JSON stored on each intuition challenge:
//
//   visual: {
//     type: "tree" | "array",
//     values: [...],            // tree: HEAP layout (children of i are 2i+1, 2i+2, null = empty)
//     values2: [...],           // optional second tree, drawn side by side
//     names: ["p", "q"],        // optional labels for the two trees
//     steps: [
//       { caption: "text",
//         hl: [idx],  ok: [idx],  bad: [idx],      // cyan / green / red
//         hl2, ok2, bad2,                          // same, for the second tree
//         tags: { idx: "text" }, tags2: {...},     // small labels under nodes / above cells
//         values: [...], values2: [...],           // optional: change the data in this step
//         ptrs: { i: 0, j: 3 },                    // array only: named pointers
//         aux: { label: "queue", items: ["3"] },   // side structure (queue, seen map, ...)
//         out: "1, 2, 3" }                         // running output
//     ]
//   }

const Color _accent = Color(0xFF10B981);
const Color _cyan = Color(0xFF22D3EE);
const Color _danger = Color(0xFFF87171);
const Color _panelBg = Color(0xFF0C1110);

Color _solid(Color c, double a) =>
    Color.alphaBlend(c.withValues(alpha: a), _panelBg);

List<dynamic> _asList(dynamic v) => v is List ? v : const [];

Set<int> _asIntSet(dynamic v) =>
    _asList(v).whereType<num>().map((e) => e.toInt()).toSet();

Map<int, String> _asTagMap(dynamic v) {
  final out = <int, String>{};
  if (v is Map) {
    v.forEach((k, val) {
      final i = int.tryParse(k.toString());
      if (i != null) out[i] = val.toString();
    });
  }
  return out;
}

Map<String, int> _asPtrMap(dynamic v) {
  final out = <String, int>{};
  if (v is Map) {
    v.forEach((k, val) {
      if (val is num) out[k.toString()] = val.toInt();
    });
  }
  return out;
}

class ChallengeVisual extends StatefulWidget {
  final Map<String, dynamic> visual;

  const ChallengeVisual({super.key, required this.visual});

  @override
  State<ChallengeVisual> createState() => _ChallengeVisualState();
}

class _ChallengeVisualState extends State<ChallengeVisual> {
  static const Duration _stepDuration = Duration(milliseconds: 2600);

  late final List<Map<String, dynamic>> _steps;
  late final bool _hasAux;
  late final bool _hasOut;
  Timer? _timer;
  int _step = 0;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _steps = _asList(
      widget.visual['steps'],
    ).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
    _hasAux = _steps.any((s) => s['aux'] is Map);
    _hasOut = _steps.any((s) => s['out'] != null);
    if (_steps.length > 1) {
      _playing = true;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_stepDuration, (_) {
      if (!mounted) return;
      if (_step < _steps.length - 1) {
        setState(() => _step++);
      } else {
        _timer?.cancel();
        setState(() => _playing = false);
      }
    });
  }

  void _togglePlay() {
    if (_playing) {
      _timer?.cancel();
      setState(() => _playing = false);
      return;
    }
    setState(() {
      if (_step >= _steps.length - 1) _step = 0;
      _playing = true;
    });
    _startTimer();
  }

  void _go(int delta) {
    _timer?.cancel();
    setState(() {
      _playing = false;
      _step = math.min(_steps.length - 1, math.max(0, _step + delta));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty) return const SizedBox.shrink();

    final v = widget.visual;
    final step = _steps[_step];
    final type = (v['type'] ?? 'tree').toString();
    final last = _steps.length - 1;

    Widget stage;
    if (type == 'array') {
      stage = _ArrayView(
        values: _asList(step['values'] ?? v['values']),
        hl: _asIntSet(step['hl']),
        ok: _asIntSet(step['ok']),
        bad: _asIntSet(step['bad']),
        ptrs: _asPtrMap(step['ptrs']),
        tags: _asTagMap(step['tags']),
      );
    } else {
      final names = _asList(v['names']).map((e) => e.toString()).toList();
      Widget panel(String? name, Widget tree) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (name != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                ),
              ),
            ),
          tree,
        ],
      );

      final first = panel(
        names.isNotEmpty ? names[0] : null,
        _TreeView(
          values: _asList(step['values'] ?? v['values']),
          hl: _asIntSet(step['hl']),
          ok: _asIntSet(step['ok']),
          bad: _asIntSet(step['bad']),
          tags: _asTagMap(step['tags']),
        ),
      );

      if (v['values2'] != null) {
        final second = panel(
          names.length > 1 ? names[1] : null,
          _TreeView(
            values: _asList(step['values2'] ?? v['values2']),
            hl: _asIntSet(step['hl2']),
            ok: _asIntSet(step['ok2']),
            bad: _asIntSet(step['bad2']),
            tags: _asTagMap(step['tags2']),
          ),
        );
        stage = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 14),
            Expanded(child: second),
          ],
        );
      } else {
        stage = first;
      }
    }

    final aux = step['aux'];
    final auxMap = aux is Map ? aux : null;
    final auxLabel = auxMap == null ? '' : (auxMap['label'] ?? '').toString();
    final auxItems = auxMap == null
        ? <String>[]
        : _asList(auxMap['items']).map((e) => e.toString()).toList();
    final out = step['out']?.toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panelBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'VISUALIZER',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: _cyan,
                ),
              ),
              const Spacer(),
              Text(
                'step ${_step + 1}/${_steps.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          stage,
          if (_hasAux) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: auxMap == null
                  ? null
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _AuxStrip(
                        key: ValueKey('$auxLabel|${auxItems.join(',')}'),
                        label: auxLabel,
                        items: auxItems,
                      ),
                    ),
            ),
          ],
          if (_hasOut) ...[
            const SizedBox(height: 6),
            SizedBox(
              height: 22,
              child: out == null
                  ? null
                  : Text(
                      'output ▸ $out',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: _accent,
                      ),
                    ),
            ),
          ],
          const SizedBox(height: 12),
          _buildCaption((step['caption'] ?? '').toString()),
          const SizedBox(height: 10),
          Row(
            children: [
              _CtrlBtn(
                icon: Icons.skip_previous_rounded,
                onTap: _step > 0 ? () => _go(-1) : null,
              ),
              const SizedBox(width: 6),
              _CtrlBtn(
                icon: _playing
                    ? Icons.pause_rounded
                    : (_step >= last
                          ? Icons.replay_rounded
                          : Icons.play_arrow_rounded),
                onTap: _steps.length > 1 ? _togglePlay : null,
                primary: true,
              ),
              const SizedBox(width: 6),
              _CtrlBtn(
                icon: Icons.skip_next_rounded,
                onTap: _step < last ? () => _go(1) : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: (_step + 1) / _steps.length),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 4,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(_accent),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaption(String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 56),
        color: Colors.white.withValues(alpha: 0.05),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: _cyan),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.25),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.centerLeft,
                      children: [...previous, if (current != null) current],
                    ),
                    child: Text(
                      text,
                      key: ValueKey(_step),
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool primary;

  const _CtrlBtn({
    required this.icon,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = primary ? _accent : Colors.white;
    return Material(
      color: primary
          ? _accent.withValues(alpha: enabled ? 0.18 : 0.06)
          : Colors.white.withValues(alpha: 0.05),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            size: 20,
            color: color.withValues(alpha: enabled ? 1 : 0.25),
          ),
        ),
      ),
    );
  }
}

class _AuxStrip extends StatelessWidget {
  final String label;
  final List<String> items;

  const _AuxStrip({super.key, required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label ▸',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: _cyan,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.isEmpty
                  ? const [
                      Text(
                        '(empty)',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Colors.white38,
                        ),
                      ),
                    ]
                  : [
                      for (final it in items)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _accent.withValues(alpha: 0.12),
                            border: Border.all(
                              color: _accent.withValues(alpha: 0.6),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            it,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                    ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// TREE
// ---------------------------------------------------------------------------

class _EdgeSpec {
  final Offset a;
  final Offset b;
  final Color c;
  const _EdgeSpec(this.a, this.b, this.c);
}

class _EdgePainter extends CustomPainter {
  final List<_EdgeSpec> edges;
  const _EdgePainter(this.edges);

  @override
  void paint(Canvas canvas, Size size) {
    for (final e in edges) {
      canvas.drawLine(
        e.a,
        e.b,
        Paint()
          ..color = e.c
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TreeView extends StatelessWidget {
  final List<dynamic> values;
  final Set<int> hl;
  final Set<int> ok;
  final Set<int> bad;
  final Map<int, String> tags;

  const _TreeView({
    required this.values,
    required this.hl,
    required this.ok,
    required this.bad,
    required this.tags,
  });

  static const double _r = 19;
  static const double _rowH = 66;

  @override
  Widget build(BuildContext context) {
    final n = values.length;
    if (n == 0) return const SizedBox.shrink();

    int levels = 1;
    while ((1 << levels) - 1 < n) {
      levels++;
    }
    final slots = (1 << levels) - 1;

    bool exists(int i) => i >= 0 && i < n && values[i] != null;
    bool marked(int i) => hl.contains(i) || ok.contains(i) || bad.contains(i);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite ? c.maxWidth : 320.0;
        final totalH = (levels - 1) * _rowH + _r * 2 + 30;

        Offset pos(int i) {
          int d = 0;
          while ((1 << (d + 1)) - 1 <= i) {
            d++;
          }
          final j = i - ((1 << d) - 1);
          return Offset((j + 0.5) / (1 << d) * w, d * _rowH + _r + 2);
        }

        final edges = <_EdgeSpec>[];
        final nodes = <Widget>[];

        for (int i = 0; i < slots; i++) {
          final real = exists(i);
          final sibling = i.isOdd ? i + 1 : i - 1;
          final ghost =
              !real &&
              i > 0 &&
              exists((i - 1) ~/ 2) &&
              (exists(sibling) || marked(i));
          if (!real && !ghost) continue;

          final p = pos(i);

          if (i > 0) {
            Color col = Colors.white;
            double a = ghost ? 0.1 : 0.22;
            if (bad.contains(i)) {
              col = _danger;
              a = 0.8;
            } else if (hl.contains(i)) {
              col = _cyan;
              a = 0.8;
            } else if (ok.contains(i)) {
              col = _accent;
              a = 0.8;
            }
            edges.add(
              _EdgeSpec(pos((i - 1) ~/ 2), p, col.withValues(alpha: a)),
            );
          }

          nodes.add(
            Positioned(
              left: p.dx - _r,
              top: p.dy - _r,
              child: _TreeNode(
                label: real ? values[i].toString() : '∅',
                ghost: ghost,
                hl: hl.contains(i),
                ok: ok.contains(i),
                bad: bad.contains(i),
              ),
            ),
          );

          if (tags.containsKey(i)) {
            nodes.add(
              Positioned(
                left: p.dx - 44,
                width: 88,
                top: p.dy + _r + 3,
                child: Text(
                  tags[i]!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: Colors.white60,
                  ),
                ),
              ),
            );
          }
        }

        return SizedBox(
          height: totalH,
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _EdgePainter(edges))),
              ...nodes,
            ],
          ),
        );
      },
    );
  }
}

class _TreeNode extends StatelessWidget {
  final String label;
  final bool ghost;
  final bool hl;
  final bool ok;
  final bool bad;

  const _TreeNode({
    required this.label,
    required this.ghost,
    required this.hl,
    required this.ok,
    required this.bad,
  });

  @override
  Widget build(BuildContext context) {
    Color border = Colors.white.withValues(alpha: ghost ? 0.15 : 0.28);
    Color fill = _solid(Colors.white, ghost ? 0.0 : 0.05);
    Color? glow;

    if (bad) {
      border = _danger;
      fill = _solid(_danger, 0.25);
      glow = _danger;
    } else if (hl) {
      border = _cyan;
      fill = _solid(_cyan, 0.25);
      glow = _cyan;
    } else if (ok) {
      border = _accent;
      fill = _solid(_accent, 0.22);
      glow = _accent;
    }

    return AnimatedScale(
      scale: hl ? 1.14 : 1,
      duration: const Duration(milliseconds: 250),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: _TreeView._r * 2,
        height: _TreeView._r * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          border: Border.all(color: border, width: 1.6),
          boxShadow: glow == null
              ? null
              : [
                  BoxShadow(
                    color: glow.withValues(alpha: 0.45),
                    blurRadius: hl ? 14 : 8,
                  ),
                ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              label,
              key: ValueKey(label),
              style: TextStyle(
                fontSize: ghost ? 13 : 14,
                fontWeight: FontWeight.bold,
                color: ghost ? Colors.white38 : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ARRAY
// ---------------------------------------------------------------------------

class _ArrayView extends StatelessWidget {
  final List<dynamic> values;
  final Set<int> hl;
  final Set<int> ok;
  final Set<int> bad;
  final Map<String, int> ptrs;
  final Map<int, String> tags;

  const _ArrayView({
    required this.values,
    required this.hl,
    required this.ok,
    required this.bad,
    required this.ptrs,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(values.length, (i) {
            final names = ptrs.entries
                .where((e) => e.value == i)
                .map((e) => e.key)
                .toList();
            final label = values[i]?.toString() ?? '∅';

            Color border = Colors.white.withValues(alpha: 0.28);
            Color fill = _solid(Colors.white, 0.05);
            Color? glow;
            if (bad.contains(i)) {
              border = _danger;
              fill = _solid(_danger, 0.25);
              glow = _danger;
            } else if (hl.contains(i)) {
              border = _cyan;
              fill = _solid(_cyan, 0.25);
              glow = _cyan;
            } else if (ok.contains(i)) {
              border = _accent;
              fill = _solid(_accent, 0.22);
              glow = _accent;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  SizedBox(
                    height: 16,
                    child: tags[i] != null
                        ? Text(
                            tags[i]!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              color: Colors.white60,
                            ),
                          )
                        : null,
                  ),
                  AnimatedScale(
                    scale: hl.contains(i) ? 1.1 : 1,
                    duration: const Duration(milliseconds: 250),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: border, width: 1.6),
                        boxShadow: glow == null
                            ? null
                            : [
                                BoxShadow(
                                  color: glow.withValues(alpha: 0.45),
                                  blurRadius: 12,
                                ),
                              ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            label,
                            key: ValueKey(label),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$i',
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: Colors.white38,
                    ),
                  ),
                  SizedBox(
                    height: 56,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: names.isEmpty
                          ? const SizedBox.shrink(key: ValueKey('none'))
                          : Column(
                              key: ValueKey(names.join(',')),
                              children: [
                                const Icon(
                                  Icons.arrow_drop_up_rounded,
                                  color: _cyan,
                                  size: 20,
                                ),
                                ...names.map(
                                  (n) => Text(
                                    n,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                      color: _cyan,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
