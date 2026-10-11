import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

// Put this file at: lib/features/dsa_world/widgets/challenge_visual.dart
//
// Renders a step-by-step animation from JSON stored on each intuition challenge:
//
//   visual: {
//     type: "tree" | "array" | "list" | "grid" | "graph" | "intervals",
//     values: [...],            // tree: HEAP layout (children of i are 2i+1, 2i+2, null = empty)
//     values2: [...],           // optional second tree / second list, drawn side by side (tree) or below (list)
//     names: ["p", "q"],        // optional labels for the two trees / lists
//     next: { "3": 1 },         // list only: starting wiring, see below
//     steps: [
//       { caption: "text",
//         hl: [idx],  ok: [idx],  bad: [idx],      // cyan / green / red
//         hl2, ok2, bad2,                          // same, for the second tree / list
//         tags: { idx: "text" }, tags2: {...},     // small labels under nodes / above cells
//         values: [...], values2: [...],           // optional: change the data in this step
//         ptrs: { i: 0, j: 3 },                    // array + list: named pointers
//         ptrs2: { b: 0 },                         // list only: pointers for the second list
//         aux: { label: "queue", items: ["3"] },   // side structure (queue, seen map, ...)
//         out: "1, 2, 3" }                         // running output
//     ]
//   }
//
// LIST type (linked list drawn as a row of nodes with arrows):
//   - Node i points to node i + 1 by default, and the last node points to a "null" slot.
//   - next: { "0": null, "3": 1 } rewires arrows. Key = node, value = target node.
//     A null value means "points to nothing" (drawn as a short arrow ending in a circle-slash).
//     A top-level `next` is the starting wiring for every step. A step's own `next`
//     replaces it for that step only, so repeat the full map on each step that needs it.
//     Arrows to a node other than the next one are drawn as arcs above the row.
//   - hlNext: [idx] draws the arrows leaving those nodes in cyan (use it for freshly changed arrows).
//   - ptrs index == values.length points at the "null" slot after the last node.
//   - For the second list use values2, hl2, ok2, bad2, tags2, ptrs2, next2, hlNext2.
//
// GRID type (2D grid or DP table drawn as a matrix of cells):
//   - values: [[1, 1, 0], [1, 0, 1]]   2D array, every row the same length (at most 8 x 8).
//     A step's `values` replaces the whole grid (same size), for filling a table or repainting cells.
//   - Cells are [row, col] pairs: hl: [[0, 1]], ok: [[0, 0]], bad: [[1, 2]]  (cyan / green / red).
//   - tags: { "1,2": "diag" } puts a tiny label inside a cell. Keys are "row,col".
//   - dim: [[0, 2]] fades cells (water, empty cells). A top-level `dim` is the default for every
//     step, and a step's own `dim` replaces it for that step.
//   - rowLabels / colLabels (top level): label the rows and columns, for example the letters of two
//     words in a DP table. Their lengths must match the grid size.
//
// GRAPH type (nodes joined by edges):
//   - nodes: ["1", "2", "3"]           labels, node i is the i-th label (at most 10 nodes).
//   - edges: [[0, 1], [1, 2, 4]]       pairs of node indices, with an optional weight as the third value.
//   - directed: true                   draws arrowheads from the first node to the second.
//   - pos: [[0.1, 0.5], [0.5, 0.2]]    optional layout, x and y between 0 and 1 for every node.
//     Without pos the nodes are placed on a circle.
//   - height: 220                      optional height of the drawing in pixels (default 210).
//   - hl / ok / bad: node indices (cyan / green / red). tags: { node: "t=2" } labels under a node.
//   - hlE / okE / badE: edges to color, written as node pairs, for example hlE: [[0, 1]].
//     For undirected graphs [0, 1] and [1, 0] mean the same edge.
//   - aux and out work as in the other types (for example a map of copies or a visited set).
//
// INTERVALS type (time spans drawn as bars on a number line, one bar per row):
//   - intervals: [[1, 3], [2, 6]]      start and end of each span (at most 7).
//   - range: [0, 13]                   optional start and end of the number line. Set it so the
//     line does not change size from step to step.
//   - A step's own `intervals` replaces the list for that step (use it to show spans merging).
//   - hl / ok / bad: indices into the current list (cyan / green / red).
//   - tags: { index: "ends 10" } small text to the right of a bar.
//   - marker: 3 draws a dashed vertical line at that time, and markerLabel: "end 3" names it.

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

// List wiring: node index -> target node index, or -1 for "points to nothing".
Map<int, int> _asNextMap(dynamic v) {
  final out = <int, int>{};
  if (v is Map) {
    v.forEach((k, val) {
      final i = int.tryParse(k.toString());
      if (i == null) return;
      out[i] = val is num ? val.toInt() : -1;
    });
  }
  return out;
}

// Grid helpers: values as rows, cells as [row, col] pairs.
List<List<dynamic>> _asGrid(dynamic v) =>
    _asList(v).map((row) => _asList(row)).toList();

Set<String> _asCellSet(dynamic v) {
  final out = <String>{};
  for (final e in _asList(v)) {
    if (e is List && e.length >= 2 && e[0] is num && e[1] is num) {
      out.add('${(e[0] as num).toInt()},${(e[1] as num).toInt()}');
    } else if (e is String) {
      out.add(e);
    }
  }
  return out;
}

Map<String, String> _asCellTags(dynamic v) {
  final out = <String, String>{};
  if (v is Map) {
    v.forEach((k, val) => out[k.toString()] = val.toString());
  }
  return out;
}

// Intervals helper: a list of [start, end] pairs.
List<List<double>> _asIntervals(dynamic v) {
  final out = <List<double>>[];
  for (final e in _asList(v)) {
    if (e is List && e.length >= 2 && e[0] is num && e[1] is num) {
      out.add([(e[0] as num).toDouble(), (e[1] as num).toDouble()]);
    }
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
  late final bool _hasArcs;
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
    // Linked lists reserve room above the row for arrows that jump or loop back.
    _hasArcs =
        widget.visual['next'] is Map ||
        widget.visual['next2'] is Map ||
        _steps.any((s) => s['next'] is Map || s['next2'] is Map);
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
    } else if (type == 'intervals') {
      final rangeRaw = _asList(v['range']);
      List<double>? rng;
      if (rangeRaw.length >= 2 && rangeRaw[0] is num && rangeRaw[1] is num) {
        rng = [
          (rangeRaw[0] as num).toDouble(),
          (rangeRaw[1] as num).toDouble(),
        ];
      } else {
        // No range given: use the span of every interval in every step.
        double lo = double.infinity;
        double hi = -double.infinity;
        void scan(List<List<double>> list) {
          for (final p in list) {
            lo = math.min(lo, p[0]);
            hi = math.max(hi, p[1]);
          }
        }

        scan(_asIntervals(v['intervals']));
        for (final st in _steps) {
          if (st['intervals'] != null) scan(_asIntervals(st['intervals']));
        }
        if (lo.isFinite && hi.isFinite) {
          rng = [lo.floorToDouble(), hi.ceilToDouble() + 1];
        }
      }
      // Reserve rows for the longest list of any step so the panel never jumps in height.
      int maxRows = _asIntervals(v['intervals']).length;
      for (final st in _steps) {
        if (st['intervals'] != null) {
          maxRows = math.max(maxRows, _asIntervals(st['intervals']).length);
        }
      }
      stage = _IntervalsView(
        intervals: _asIntervals(step['intervals'] ?? v['intervals']),
        rows: math.max(1, maxRows),
        range: rng ?? const [0, 10],
        hl: _asIntSet(step['hl']),
        ok: _asIntSet(step['ok']),
        bad: _asIntSet(step['bad']),
        tags: _asTagMap(step['tags']),
        marker: step['marker'] is num
            ? (step['marker'] as num).toDouble()
            : null,
        markerLabel: step['markerLabel']?.toString(),
      );
    } else if (type == 'graph') {
      stage = _GraphView(
        nodes: _asList(v['nodes']).map((e) => e.toString()).toList(),
        pos: _asList(v['pos']),
        edges: _asList(v['edges']),
        directed: v['directed'] == true,
        height: v['height'] is num ? (v['height'] as num).toDouble() : 210,
        hl: _asIntSet(step['hl']),
        ok: _asIntSet(step['ok']),
        bad: _asIntSet(step['bad']),
        hlE: _asCellSet(step['hlE']),
        okE: _asCellSet(step['okE']),
        badE: _asCellSet(step['badE']),
        tags: _asTagMap(step['tags']),
      );
    } else if (type == 'grid') {
      stage = _GridView(
        values: _asGrid(step['values'] ?? v['values']),
        rowLabels: _asList(v['rowLabels']).map((e) => e.toString()).toList(),
        colLabels: _asList(v['colLabels']).map((e) => e.toString()).toList(),
        hl: _asCellSet(step['hl']),
        ok: _asCellSet(step['ok']),
        bad: _asCellSet(step['bad']),
        dim: _asCellSet(step['dim'] ?? v['dim']),
        tags: _asCellTags(step['tags']),
      );
    } else if (type == 'list') {
      final names = _asList(v['names']).map((e) => e.toString()).toList();
      final arcBand = _hasArcs ? 54.0 : 4.0;

      final row1 = _ListRow(
        label: names.isNotEmpty ? names[0] : null,
        values: _asList(step['values'] ?? v['values']),
        hl: _asIntSet(step['hl']),
        ok: _asIntSet(step['ok']),
        bad: _asIntSet(step['bad']),
        tags: _asTagMap(step['tags']),
        ptrs: _asPtrMap(step['ptrs']),
        next: _asNextMap(step['next'] ?? v['next']),
        hlNext: _asIntSet(step['hlNext']),
        arcBand: arcBand,
      );

      if (v['values2'] != null) {
        final row2 = _ListRow(
          label: names.length > 1 ? names[1] : null,
          values: _asList(step['values2'] ?? v['values2']),
          hl: _asIntSet(step['hl2']),
          ok: _asIntSet(step['ok2']),
          bad: _asIntSet(step['bad2']),
          tags: _asTagMap(step['tags2']),
          ptrs: _asPtrMap(step['ptrs2']),
          next: _asNextMap(step['next2'] ?? v['next2']),
          hlNext: _asIntSet(step['hlNext2']),
          arcBand: arcBand,
        );
        stage = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [row1, const SizedBox(height: 10), row2],
        );
      } else {
        stage = row1;
      }
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

// ---------------------------------------------------------------------------
// LINKED LIST
// ---------------------------------------------------------------------------

class _ListRow extends StatelessWidget {
  final String? label;
  final List<dynamic> values;
  final Set<int> hl;
  final Set<int> ok;
  final Set<int> bad;
  final Map<int, String> tags;
  final Map<String, int> ptrs;
  final Map<int, int> next;
  final Set<int> hlNext;
  final double arcBand;

  const _ListRow({
    required this.label,
    required this.values,
    required this.hl,
    required this.ok,
    required this.bad,
    required this.tags,
    required this.ptrs,
    required this.next,
    required this.hlNext,
    required this.arcBand,
  });

  static const double nodeW = 40;
  static const double nodeH = 40;
  static const double gap = 30;
  static const double pitch = nodeW + gap;
  static const double tagH = 16;
  static const double ptrH = 52;

  @override
  Widget build(BuildContext context) {
    final n = values.length;
    if (n == 0) return const SizedBox.shrink();

    // n real nodes plus one "null" slot at index n.
    final width = n * pitch + nodeW;
    final height = arcBand + nodeH + tagH + ptrH;

    final targets = List<int>.generate(
      n,
      (i) => next.containsKey(i) ? next[i]! : i + 1,
    );

    final children = <Widget>[
      Positioned.fill(
        child: CustomPaint(
          painter: _ListEdgePainter(
            targets: targets,
            hlNext: hlNext,
            arcBand: arcBand,
          ),
        ),
      ),
    ];

    for (int i = 0; i <= n; i++) {
      final left = i * pitch;
      final isNull = i == n;

      children.add(
        Positioned(
          left: left,
          top: arcBand,
          child: _ListNode(
            label: isNull ? 'null' : (values[i]?.toString() ?? '∅'),
            isNull: isNull,
            hl: hl.contains(i),
            ok: ok.contains(i),
            bad: bad.contains(i),
          ),
        ),
      );

      if (tags.containsKey(i)) {
        children.add(
          Positioned(
            left: left - 15,
            width: nodeW + 30,
            top: arcBand + nodeH + 3,
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

      final names = ptrs.entries
          .where((e) => e.value == i)
          .map((e) => e.key)
          .toList();
      if (names.isNotEmpty) {
        children.add(
          Positioned(
            left: left - 15,
            width: nodeW + 30,
            top: arcBand + nodeH + tagH,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_drop_up_rounded, color: _cyan, size: 20),
                ...names.map(
                  (name) => Text(
                    name,
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
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label!,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Colors.white54,
              ),
            ),
          ),
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(clipBehavior: Clip.none, children: children),
            ),
          ),
        ),
      ],
    );
  }
}

class _ListEdgePainter extends CustomPainter {
  final List<int> targets;
  final Set<int> hlNext;
  final double arcBand;

  const _ListEdgePainter({
    required this.targets,
    required this.hlNext,
    required this.arcBand,
  });

  void _arrowHead(Canvas canvas, Offset tip, Offset dir, Color color) {
    final len = dir.distance;
    if (len == 0) return;
    final d = dir / len;
    final perp = Offset(-d.dy, d.dx);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - d.dx * 8 + perp.dx * 4, tip.dy - d.dy * 8 + perp.dy * 4)
      ..lineTo(tip.dx - d.dx * 8 - perp.dx * 4, tip.dy - d.dy * 8 - perp.dy * 4)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  void _drawText(Canvas canvas, String text, Offset at, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
  }

  @override
  void paint(Canvas canvas, Size size) {
    const nodeW = _ListRow.nodeW;
    const nodeH = _ListRow.nodeH;
    const pitch = _ListRow.pitch;
    final top = arcBand;
    final cy = top + nodeH / 2;
    final n = targets.length;

    for (int i = 0; i < n; i++) {
      final t = targets[i];
      final hot = hlNext.contains(i);
      final color = hot
          ? _cyan.withValues(alpha: 0.95)
          : Colors.white.withValues(alpha: 0.4);
      final line = Paint()
        ..color = color
        ..strokeWidth = hot ? 2.6 : 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (t == i + 1) {
        final x1 = i * pitch + nodeW;
        final x2 = (i + 1) * pitch;
        canvas.drawLine(Offset(x1, cy), Offset(x2 - 4, cy), line);
        _arrowHead(canvas, Offset(x2, cy), const Offset(1, 0), color);
      } else if (t == -1) {
        final x1 = i * pitch + nodeW;
        canvas.drawLine(Offset(x1, cy), Offset(x1 + 10, cy), line);
        _drawText(canvas, '∅', Offset(x1 + 13, cy - 9), color);
      } else if (t >= 0 && t <= n && t != i) {
        final x1 = i * pitch + nodeW / 2;
        final x2 = t * pitch + nodeW / 2;
        final d = (t - i).abs();
        final h = math.min(arcBand - 6, 14.0 + 9.0 * d);
        if (h <= 0) continue;
        final cx = (x1 + x2) / 2;
        final path = Path()
          ..moveTo(x1, top)
          ..quadraticBezierTo(cx, top - 2 * h, x2, top - 1);
        canvas.drawPath(path, line);
        _arrowHead(canvas, Offset(x2, top - 1), Offset(x2 - cx, 2 * h), color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ListNode extends StatelessWidget {
  final String label;
  final bool isNull;
  final bool hl;
  final bool ok;
  final bool bad;

  const _ListNode({
    required this.label,
    required this.isNull,
    required this.hl,
    required this.ok,
    required this.bad,
  });

  @override
  Widget build(BuildContext context) {
    Color border = Colors.white.withValues(alpha: isNull ? 0.14 : 0.28);
    Color fill = isNull ? Colors.transparent : _solid(Colors.white, 0.05);
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
      scale: hl ? 1.1 : 1,
      duration: const Duration(milliseconds: 250),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: _ListRow.nodeW,
        height: _ListRow.nodeH,
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
              style: TextStyle(
                fontSize: isNull ? 10 : 15,
                fontWeight: isNull ? FontWeight.normal : FontWeight.bold,
                fontFamily: isNull ? 'monospace' : null,
                color: isNull ? Colors.white38 : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GRID
// ---------------------------------------------------------------------------

class _GridView extends StatelessWidget {
  final List<List<dynamic>> values;
  final List<String> rowLabels;
  final List<String> colLabels;
  final Set<String> hl;
  final Set<String> ok;
  final Set<String> bad;
  final Set<String> dim;
  final Map<String, String> tags;

  const _GridView({
    required this.values,
    required this.rowLabels,
    required this.colLabels,
    required this.hl,
    required this.ok,
    required this.bad,
    required this.dim,
    required this.tags,
  });

  static const double cell = 46;
  static const double gap = 4;
  static const double rowLabelW = 26;

  Widget _label(String text, double w, double h) => SizedBox(
    width: w,
    height: h,
    child: Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          color: Colors.white54,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    int cols = 0;
    for (final row in values) {
      if (row.length > cols) cols = row.length;
    }
    final hasRowLabels = rowLabels.isNotEmpty;
    final hasColLabels = colLabels.isNotEmpty;

    final rows = <Widget>[];

    if (hasColLabels) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: gap),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasRowLabels) const SizedBox(width: rowLabelW + gap),
              for (int c = 0; c < cols; c++)
                Padding(
                  padding: EdgeInsets.only(right: c == cols - 1 ? 0 : gap),
                  child: _label(
                    c < colLabels.length ? colLabels[c] : '',
                    cell,
                    18,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    for (int r = 0; r < values.length; r++) {
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: r == values.length - 1 ? 0 : gap),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasRowLabels) ...[
                _label(
                  r < rowLabels.length ? rowLabels[r] : '',
                  rowLabelW,
                  cell,
                ),
                const SizedBox(width: gap),
              ],
              for (int c = 0; c < cols; c++)
                Padding(
                  padding: EdgeInsets.only(right: c == cols - 1 ? 0 : gap),
                  child: _GridCell(
                    label: c < values[r].length
                        ? (values[r][c]?.toString() ?? '')
                        : '',
                    tag: tags['$r,$c'],
                    hl: hl.contains('$r,$c'),
                    ok: ok.contains('$r,$c'),
                    bad: bad.contains('$r,$c'),
                    dim: dim.contains('$r,$c'),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(mainAxisSize: MainAxisSize.min, children: rows),
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  final String label;
  final String? tag;
  final bool hl;
  final bool ok;
  final bool bad;
  final bool dim;

  const _GridCell({
    required this.label,
    required this.tag,
    required this.hl,
    required this.ok,
    required this.bad,
    required this.dim,
  });

  @override
  Widget build(BuildContext context) {
    Color border = Colors.white.withValues(alpha: 0.28);
    Color fill = _solid(Colors.white, 0.05);
    Color textColor = Colors.white;
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
    } else if (dim) {
      border = Colors.white.withValues(alpha: 0.1);
      fill = Colors.transparent;
      textColor = Colors.white30;
    }

    return AnimatedScale(
      scale: hl ? 1.08 : 1,
      duration: const Duration(milliseconds: 250),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: _GridView.cell,
        height: _GridView.cell,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(8),
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
        child: Stack(
          children: [
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  label,
                  key: ValueKey(label),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
            if (tag != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 2,
                child: Text(
                  tag!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    fontFamily: 'monospace',
                    color: Colors.white60,
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
// GRAPH
// ---------------------------------------------------------------------------

class _GraphEdgeDraw {
  final int a;
  final int b;
  final String? label;
  final Color color;
  final double width;
  const _GraphEdgeDraw(this.a, this.b, this.label, this.color, this.width);
}

class _GraphEdgePainter extends CustomPainter {
  final List<_GraphEdgeDraw> edges;
  final List<Offset> pos;
  final bool directed;

  const _GraphEdgePainter({
    required this.edges,
    required this.pos,
    required this.directed,
  });

  void _arrowHead(Canvas canvas, Offset tip, Offset d, Color color) {
    final perp = Offset(-d.dy, d.dx);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - d.dx * 10 + perp.dx * 5,
        tip.dy - d.dy * 10 + perp.dy * 5,
      )
      ..lineTo(
        tip.dx - d.dx * 10 - perp.dx * 5,
        tip.dy - d.dy * 10 - perp.dy * 5,
      )
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    const r = _GraphView.r;
    for (final e in edges) {
      final pa = pos[e.a];
      final pb = pos[e.b];
      final dir = pb - pa;
      final len = dir.distance;
      if (len <= 2 * r) continue;
      final d = dir / len;
      final start = pa + d * r;
      final end = pb - d * (r + (directed ? 2 : 0));

      canvas.drawLine(
        start,
        directed ? end - d * 6 : end,
        Paint()
          ..color = e.color
          ..strokeWidth = e.width
          ..strokeCap = StrokeCap.round,
      );
      if (directed) _arrowHead(canvas, end, d, e.color);

      if (e.label != null) {
        final mid = (start + end) / 2;
        final perp = Offset(-d.dy, d.dx);
        final at = mid + perp * 11;
        final tp = TextPainter(
          text: TextSpan(
            text: e.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: Colors.white70,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final rect = Rect.fromCenter(
          center: at,
          width: tp.width + 8,
          height: tp.height + 2,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          Paint()..color = _panelBg,
        );
        tp.paint(canvas, Offset(at.dx - tp.width / 2, at.dy - tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GraphView extends StatelessWidget {
  final List<String> nodes;
  final List<dynamic> pos;
  final List<dynamic> edges;
  final bool directed;
  final double height;
  final Set<int> hl;
  final Set<int> ok;
  final Set<int> bad;
  final Set<String> hlE;
  final Set<String> okE;
  final Set<String> badE;
  final Map<int, String> tags;

  const _GraphView({
    required this.nodes,
    required this.pos,
    required this.edges,
    required this.directed,
    required this.height,
    required this.hl,
    required this.ok,
    required this.bad,
    required this.hlE,
    required this.okE,
    required this.badE,
    required this.tags,
  });

  static const double r = 19;
  static const double pad = 26;

  bool _marked(Set<String> s, int a, int b) =>
      s.contains('$a,$b') || (!directed && s.contains('$b,$a'));

  @override
  Widget build(BuildContext context) {
    final n = nodes.length;
    if (n == 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite ? c.maxWidth : 320.0;
        final usableH = height - 2 * pad - 14;

        Offset at(int i) {
          double px;
          double py;
          final p = i < pos.length ? pos[i] : null;
          if (p is List && p.length >= 2 && p[0] is num && p[1] is num) {
            px = (p[0] as num).toDouble();
            py = (p[1] as num).toDouble();
          } else {
            final ang = -math.pi / 2 + 2 * math.pi * i / n;
            px = 0.5 + 0.45 * math.cos(ang);
            py = 0.5 + 0.45 * math.sin(ang);
          }
          return Offset(pad + px * (w - 2 * pad), pad + py * usableH);
        }

        final positions = List<Offset>.generate(n, at);

        final draws = <_GraphEdgeDraw>[];
        for (final e in edges) {
          if (e is! List || e.length < 2 || e[0] is! num || e[1] is! num) {
            continue;
          }
          final a = (e[0] as num).toInt();
          final b = (e[1] as num).toInt();
          if (a < 0 || b < 0 || a >= n || b >= n) continue;

          Color col = Colors.white.withValues(alpha: 0.28);
          double wd = 2;
          if (_marked(badE, a, b)) {
            col = _danger.withValues(alpha: 0.9);
            wd = 3;
          } else if (_marked(hlE, a, b)) {
            col = _cyan.withValues(alpha: 0.95);
            wd = 3;
          } else if (_marked(okE, a, b)) {
            col = _accent.withValues(alpha: 0.9);
            wd = 3;
          }
          draws.add(
            _GraphEdgeDraw(
              a,
              b,
              e.length > 2 ? e[2].toString() : null,
              col,
              wd,
            ),
          );
        }

        final children = <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: _GraphEdgePainter(
                edges: draws,
                pos: positions,
                directed: directed,
              ),
            ),
          ),
        ];

        for (int i = 0; i < n; i++) {
          final p = positions[i];
          children.add(
            Positioned(
              left: p.dx - r,
              top: p.dy - r,
              child: _TreeNode(
                label: nodes[i],
                ghost: false,
                hl: hl.contains(i),
                ok: ok.contains(i),
                bad: bad.contains(i),
              ),
            ),
          );
          if (tags.containsKey(i)) {
            children.add(
              Positioned(
                left: p.dx - 44,
                width: 88,
                top: p.dy + r + 3,
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
          height: height,
          child: Stack(children: children),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// INTERVALS
// ---------------------------------------------------------------------------

class _IntervalsAxisPainter extends CustomPainter {
  final double lo;
  final double hi;
  final double padL;
  final double padR;
  final double axisY;
  final double topPad;
  final double? marker;
  final String? markerLabel;

  const _IntervalsAxisPainter({
    required this.lo,
    required this.hi,
    required this.padL,
    required this.padR,
    required this.axisY,
    required this.topPad,
    required this.marker,
    required this.markerLabel,
  });

  void _text(
    Canvas canvas,
    String text,
    Offset center,
    Color color, {
    double size = 10,
    bool bold = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          fontFamily: 'monospace',
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final span = math.max(1.0, hi - lo);
    final usable = size.width - padL - padR;
    double x(double v) => padL + (v - lo) / span * usable;

    final axis = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(padL, axisY), Offset(padL + usable, axisY), axis);

    final step = span <= 14 ? 1 : (span <= 28 ? 2 : 5);
    for (int v = lo.ceil(); v <= hi.floor(); v++) {
      if ((v - lo.ceil()) % step != 0) continue;
      final px = x(v.toDouble());
      canvas.drawLine(Offset(px, axisY), Offset(px, axisY + 4), axis);
      _text(canvas, '$v', Offset(px, axisY + 13), Colors.white54);
    }

    if (marker != null) {
      final mx = x(marker!);
      final dash = Paint()
        ..color = _cyan.withValues(alpha: 0.85)
        ..strokeWidth = 1.8;
      double y = topPad - 4;
      while (y < axisY) {
        canvas.drawLine(
          Offset(mx, y),
          Offset(mx, math.min(y + 5, axisY)),
          dash,
        );
        y += 9;
      }
      if (markerLabel != null) {
        _text(canvas, markerLabel!, Offset(mx, 7), _cyan, size: 10, bold: true);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _IntervalsView extends StatelessWidget {
  final List<List<double>> intervals;
  final int rows;
  final List<double> range;
  final Set<int> hl;
  final Set<int> ok;
  final Set<int> bad;
  final Map<int, String> tags;
  final double? marker;
  final String? markerLabel;

  const _IntervalsView({
    required this.intervals,
    required this.rows,
    required this.range,
    required this.hl,
    required this.ok,
    required this.bad,
    required this.tags,
    required this.marker,
    required this.markerLabel,
  });

  static const double padL = 12;
  static const double padR = 48;
  static const double topPad = 22;
  static const double barH = 28;
  static const double pitch = 36;
  static const double axisH = 28;

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  Widget build(BuildContext context) {
    final height = topPad + rows * pitch + axisH;
    final lo = range[0];
    final hi = range[1];
    final span = math.max(1.0, hi - lo);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite ? c.maxWidth : 320.0;
        final usable = w - padL - padR;
        double x(double v) => padL + (v - lo) / span * usable;

        final children = <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: _IntervalsAxisPainter(
                lo: lo,
                hi: hi,
                padL: padL,
                padR: padR,
                axisY: topPad + rows * pitch + 4,
                topPad: topPad,
                marker: marker,
                markerLabel: markerLabel,
              ),
            ),
          ),
        ];

        for (int i = 0; i < intervals.length; i++) {
          final s = intervals[i][0];
          final e = intervals[i][1];
          final left = x(s);
          final width = math.max(8.0, x(e) - x(s));
          final top = topPad + i * pitch;

          Color border = Colors.white.withValues(alpha: 0.3);
          Color fill = _solid(Colors.white, 0.07);
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

          children.add(
            AnimatedPositioned(
              key: ValueKey('bar$i'),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              left: left,
              top: top,
              width: width,
              height: barH,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: border, width: 1.6),
                  boxShadow: glow == null
                      ? null
                      : [
                          BoxShadow(
                            color: glow.withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ],
                ),
                child: OverflowBox(
                  maxWidth: 90,
                  child: Text(
                    '${_fmt(s)}–${_fmt(e)}',
                    maxLines: 1,
                    softWrap: false,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          );

          if (tags.containsKey(i)) {
            children.add(
              Positioned(
                left: left + width + 6,
                top: top + 8,
                child: Text(
                  tags[i]!,
                  maxLines: 1,
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
          height: height,
          child: Stack(clipBehavior: Clip.none, children: children),
        );
      },
    );
  }
}
