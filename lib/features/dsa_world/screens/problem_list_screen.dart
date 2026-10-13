import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/dsa_service.dart';

const Color _green = Color(0xFF55D68A);
const Color _amber = Color(0xFFFFB44D);
const Color _red = Color(0xFFFF6B6B);
const Color _bgColor = Color(0xFF090D0B);
const Color _cardColor = Color(0xFF101713);
const Color _borderColor = Color(0xFF315743);

Color _difficultyColor(String difficulty) {
  switch (difficulty) {
    case 'Easy':
      return _green;
    case 'Medium':
      return _amber;
    case 'Hard':
      return _red;
    default:
      return Colors.grey;
  }
}

class ProblemListScreen extends StatefulWidget {
  const ProblemListScreen({super.key});

  @override
  State<ProblemListScreen> createState() => _ProblemListScreenState();
}

class _ProblemListScreenState extends State<ProblemListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<Map<String, dynamic>> _problems = [];
  bool _loading = true;
  String? _error;
  String? _topic;
  String _query = '';
  String _difficulty = 'All';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    // A topic row on the home screen passes {'topic': 'Arrays'}.
    // Without arguments, every problem is listed.
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['topic'] is String) {
      _topic = args['topic'] as String;
    }
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await DSAService.getProblems(topic: _topic);
      for (var i = 0; i < data.length; i++) {
        data[i]['_n'] = i + 1; // stable number, even while filtering
      }
      if (!mounted) return;
      setState(() {
        _problems = data;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      // When refreshing after a lesson, keep showing the list we already have.
      if (_problems.isNotEmpty) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _load();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _difficulty = 'All';
    });
  }

  Future<void> _openProblem(Map<String, dynamic> problem) async {
    await Navigator.of(context).pushNamed(
      '/dsa-problem-display',
      arguments: {'problemId': problem['_id']},
    );
    // Refresh so newly completed problems get their check mark.
    if (mounted) _load();
  }

  List<Map<String, dynamic>> get _filtered {
    final query = _query.trim().toLowerCase();
    return _problems.where((problem) {
      if (_difficulty != 'All' && problem['difficulty'] != _difficulty) {
        return false;
      }
      if (query.isEmpty) return true;
      final title = (problem['title'] ?? '').toString().toLowerCase();
      final topics = List<String>.from(
        problem['topics'] ?? [],
      ).join(' ').toLowerCase();
      return title.contains(query) || topics.contains(query);
    }).toList();
  }

  int _countFor(String difficulty) {
    if (difficulty == 'All') return _problems.length;
    return _problems.where((p) => p['difficulty'] == difficulty).length;
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 650;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _searchFocus.requestFocus,
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            _searchFocus.requestFocus,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: _bgColor,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF153522).withValues(alpha: 0.55),
                  _bgColor,
                ],
                stops: const [0, 0.42],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            wide ? 24 : 16,
                            16,
                            wide ? 24 : 16,
                            8,
                          ),
                          child: _buildHeader(wide),
                        ),
                      ),
                      ..._buildListSlivers(wide),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool wide) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.62);
    final done = _problems.where((p) => p['completed'] == true).length;
    final showProgress = !_loading && _error == null && _problems.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _BackButton(onTap: () => Navigator.of(context).maybePop()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 54),
              child: Column(
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Choose a '),
                        TextSpan(
                          text: 'Problem',
                          style: TextStyle(color: _green),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: wide ? 34 : 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pick a challenge and build your intuition.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: wide ? 14 : 12),
                  ),
                  if (_topic != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _green.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.folder_open_rounded,
                            color: _green,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _topic!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _green,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (showProgress) ...[
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _problems.isEmpty ? 0 : done / _problems.length,
                    minHeight: 5,
                    backgroundColor: const Color(0xFF20382A),
                    valueColor: const AlwaysStoppedAnimation<Color>(_green),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$done of ${_problems.length} completed',
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        _buildSearchField(wide),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final level in const ['All', 'Easy', 'Medium', 'Hard'])
              _FilterChipButton(
                label: level,
                count: _problems.isEmpty ? null : _countFor(level),
                color: level == 'All' ? _green : _difficultyColor(level),
                selected: _difficulty == level,
                onTap: () => setState(() => _difficulty = level),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField(bool wide) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.5);

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    Widget? suffix;
    if (_query.isNotEmpty) {
      suffix = IconButton(
        tooltip: 'Clear search',
        icon: Icon(Icons.close_rounded, color: muted, size: 20),
        onPressed: () {
          _searchController.clear();
          setState(() => _query = '');
        },
      );
    } else if (wide) {
      suffix = Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Center(
          widthFactor: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor),
            ),
            child: Text(
              'Ctrl K',
              style: TextStyle(
                color: muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    return TextField(
      controller: _searchController,
      focusNode: _searchFocus,
      onChanged: (value) => setState(() => _query = value),
      cursorColor: _green,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search problems or topics…',
        hintStyle: TextStyle(color: muted, fontSize: 14),
        prefixIcon: Icon(Icons.search_rounded, color: muted, size: 22),
        suffixIcon: suffix,
        filled: true,
        fillColor: _cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: border(_borderColor),
        focusedBorder: border(_green, 1.4),
        border: border(_borderColor),
      ),
    );
  }

  List<Widget> _buildListSlivers(bool wide) {
    final sidePadding = wide ? 24.0 : 16.0;

    if (_loading) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (_error != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _MessageCard(
            icon: Icons.error_outline_rounded,
            iconColor: _red,
            message: 'Could not load problems.\n$_error',
            actionLabel: 'Try again',
            onAction: _retry,
          ),
        ),
      ];
    }

    final items = _filtered;

    if (_problems.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _MessageCard(
            icon: Icons.inbox_rounded,
            iconColor: _green,
            message: 'No problems found yet.',
          ),
        ),
      ];
    }

    if (items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _MessageCard(
            icon: Icons.search_off_rounded,
            iconColor: _amber,
            message: 'No problems match your search or filter.',
            actionLabel: 'Clear filters',
            onAction: _clearFilters,
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(sidePadding, 8, sidePadding, 32),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final problem = items[index];
            final row = _ProblemRow(
              number: (problem['_n'] as int?) ?? index + 1,
              title: (problem['title'] ?? '').toString(),
              difficulty: (problem['difficulty'] ?? '').toString(),
              topics: List<String>.from(problem['topics'] ?? []),
              completed: problem['completed'] == true,
              onTap: () => _openProblem(problem),
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: index < 12 ? _FadeIn(index: index, child: row) : row,
            );
          }, childCount: items.length),
        ),
      ),
    ];
  }
}

// ============================================================
// WIDGETS
// ============================================================

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor),
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 22),
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final int? count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.16) : _cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.35),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? color : onSurface.withValues(alpha: 0.85),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 7),
              Text(
                '$count',
                style: TextStyle(
                  color: (selected ? color : onSurface).withValues(alpha: 0.6),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProblemRow extends StatefulWidget {
  final int number;
  final String title;
  final String difficulty;
  final List<String> topics;
  final bool completed;
  final VoidCallback onTap;

  const _ProblemRow({
    required this.number,
    required this.title,
    required this.difficulty,
    required this.topics,
    required this.completed,
    required this.onTap,
  });

  @override
  State<_ProblemRow> createState() => _ProblemRowState();
}

class _ProblemRowState extends State<_ProblemRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final color = _difficultyColor(widget.difficulty);
    final highlighted = _hovered;

    Color borderColor = _borderColor;
    if (widget.completed) borderColor = _green.withValues(alpha: 0.55);
    if (highlighted) borderColor = _green;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onTap,
        onHover: (value) => setState(() => _hovered = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: highlighted ? const Color(0xFF13201A) : _cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: highlighted ? 1.4 : 1,
            ),
            boxShadow: highlighted
                ? [
                    BoxShadow(
                      color: _green.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.completed
                      ? _green.withValues(alpha: 0.16)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: widget.completed
                        ? _green.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: widget.completed
                    ? const Icon(Icons.check_rounded, color: _green, size: 24)
                    : Text(
                        '${widget.number}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: onSurface.withValues(alpha: 0.75),
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.topics.join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  border: Border.all(color: color.withValues(alpha: 0.7)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.difficulty,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: highlighted ? _green : onSurface.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageCard({
    required this.icon,
    required this.iconColor,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.65);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: iconColor),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 14, height: 1.5),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: const Color(0xFF07130B),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FadeIn extends StatelessWidget {
  final int index;
  final Widget child;

  const _FadeIn({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + index * 45),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
