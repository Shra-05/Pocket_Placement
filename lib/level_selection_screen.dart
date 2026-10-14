import 'dart:math';
import 'package:flutter/material.dart';
import 'theme_selection_screen.dart';
import 'streak_screen.dart';
import 'subject_switcher.dart';
import 'services/auth_service.dart';
import 'level_detail_screen.dart';
import 'core_question_bank.dart';
import 'oops_core_level_screen.dart';
import 'os_core_level_screen.dart';
import 'dbms_core_level_screen.dart';
import 'cn_core_level_screen.dart';
import 'ml_core_level_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_notes_screen.dart';
class LevelSelectionScreen extends StatefulWidget {
  final AppTheme theme;
  final String topic;
  const LevelSelectionScreen({
    super.key,
    required this.topic,
    required this.theme,
  });
  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}
class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  String currentTopic = 'DSA';
  Set<int> completedLevels = {};
  int currentStreak = 0;
  bool _isLoadingStreak = true;
  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }
  // Use one canonical storage key per subject so aliases such as
  // 'Operating Systems' and 'OS' never share or lose progress accidentally.
  String _progressSubjectKey(String topic) {
    switch (topic.trim().toUpperCase()) {
      case 'OPERATING SYSTEMS':
      case 'OS':
        return 'OS';
      case 'COMPUTER NETWORKS':
      case 'CN':
        return 'CN';
      case 'MACHINE LEARNING':
      case 'ML':
        return 'ML';
      case 'OOPS':
        return 'OOPS';
      case 'DBMS':
        return 'DBMS';
      default:
        return topic.trim().toUpperCase();
    }
  }

  Future<void> _loadProgress([String? topic]) async {
    final requestedTopic = topic ?? currentTopic;
    final prefs = await SharedPreferences.getInstance();
    final key = 'completed_levels_${_progressSubjectKey(requestedTopic)}';
    final savedLevels = prefs.getStringList(key) ?? <String>[];
    final parsedLevels = savedLevels
        .map((value) => int.tryParse(value))
        .whereType<int>()
        .toSet();
    if (!mounted || _progressSubjectKey(currentTopic) !=
        _progressSubjectKey(requestedTopic)) return;
    setState(() {
      completedLevels = parsedLevels;
    });
  }
  Future<void> _loadStreak() async {
    final data = await AuthService.getStreak();
    if (!mounted) return;
    setState(() {
      currentStreak = (data?['streak'] ?? 0) as int;
      _isLoadingStreak = false;
    });
  }
  @override
  void initState() {
    super.initState();
    currentTopic = widget.topic;
    _loadProgress();
    _loadStreak();
  }
  bool _isLevelUnlocked(int level) {
    if (level == 1) {
      return true;
    }
    return completedLevels.contains(level - 1);
  }
  List<LevelData> _applyUnlockState(List<LevelData> levels) {
    return levels
        .map(
          (level) => LevelData(
            level.number,
            level.title,
            level.subtitle,
            _isLevelUnlocked(level.number),
          ),
        )
        .toList();
  }
  List<LevelData> _buildCoreLevels(String subject) {
    final questions = CoreQuestionBank.forSubject(subject);
    return _applyUnlockState(List.generate(100, (index) {
      final q = questions[index];
      return LevelData(
        index + 1,
        q.concept.toUpperCase(),
        'Level ${index + 1} • ${((index ~/ 20) + 1)}/5 quest',
        index == 0,
      );
    }));
  }
  List<LevelData> _buildLevels() {
    switch (currentTopic.toUpperCase()) {
      case 'OOPS':
        return _buildCoreLevels('OOPS');
      case 'DBMS':
        return _buildCoreLevels('DBMS');
      case 'OS':
      case 'OPERATING SYSTEMS':
        return _buildCoreLevels('OS');
      case 'CN':
      case 'COMPUTER NETWORKS':
        return _buildCoreLevels('CN');
      case 'ML':
      case 'MACHINE LEARNING':
        return _buildCoreLevels('ML');
      default:
        return _applyUnlockState([
          LevelData(
            1,
            'PROGRAMMING BASICS',
            'Variables • Loops • Functions',
            _isLevelUnlocked(1),
          ),
          LevelData(2, 'ARRAYS', 'Traversal • Searching', _isLevelUnlocked(2)),
          LevelData(
            3,
            'STRINGS',
            'Manipulation • Patterns',
            _isLevelUnlocked(3),
          ),
          LevelData(
            4,
            'SEARCHING',
            'Linear • Binary Search',
            _isLevelUnlocked(4),
          ),
          LevelData(
            5,
            'SORTING',
            'Bubble • Merge • Quick Sort',
            _isLevelUnlocked(5),
          ),
          LevelData(
            6,
            'LINKED LIST',
            'Nodes • Operations',
            _isLevelUnlocked(6),
          ),
          LevelData(7, 'STACK & QUEUE', 'LIFO • FIFO', _isLevelUnlocked(7)),
          LevelData(
            8,
            'RECURSION',
            'Base Cases • Backtracking',
            _isLevelUnlocked(8),
          ),
          LevelData(
            9,
            'TREES',
            'BST • Traversals • Heaps',
            _isLevelUnlocked(9),
          ),
          LevelData(
            10,
            'GRAPHS',
            'BFS • DFS • Shortest Path',
            _isLevelUnlocked(10),
          ),
        ]);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor(),
      body: Stack(
        children: [
          Positioned.fill(child: _buildThemeBackground()),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                // SUBJECT SWITCHER
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SubjectSwitcher(
                      selectedTopic: currentTopic,
                      onSubjectSelected: (newTopic) async {
                        if (_progressSubjectKey(newTopic) ==
                            _progressSubjectKey(currentTopic)) {
                          setState(() => currentTopic = newTopic);
                          return;
                        }
                        setState(() {
                          currentTopic = newTopic;
                          // Clear old subject's completion state immediately,
                          // then load only the newly selected subject's data.
                          completedLevels = <int>{};
                        });
                        await _loadProgress(newTopic);
                      },
                    ),
                  ),
                ),
                if (currentTopic.toUpperCase() == 'DSA')
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/dsa-world-home');
                        },
                        child: const Text(
                          '🌍 ENTER DSA WORLD',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _buildMap(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // THEME BACKGROUND
  // ============================================================
  Widget _buildThemeBackground() {
    switch (widget.theme) {
      case AppTheme.forest:
        return const ForestBackground();
      case AppTheme.cyberpunk:
        return const CyberpunkBackground();
      case AppTheme.kingdom:
        return const KingdomBackground();
    }
  }
  Color _backgroundColor() {
    switch (widget.theme) {
      case AppTheme.forest:
        return const Color(0xFF061713);
      case AppTheme.cyberpunk:
        return const Color(0xFF070313);
      case AppTheme.kingdom:
        return const Color(0xFF170B06);
    }
  }
  // ============================================================
  // TOP BAR
  // ============================================================
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        border: Border(
          bottom: BorderSide(color: _accentColor().withValues(alpha: 0.18)),
        ),
      ),
      child: Row(
        children: [
          _roundButton(Icons.arrow_back_rounded, () => Navigator.pop(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _worldName(),
                  style: TextStyle(
                    color: _titleColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Your placement journey',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _stat(
            Icons.local_fire_department_rounded,
            _isLoadingStreak ? '...' : '$currentStreak',
            const Color(0xFFFF6B35),
          ),
          const SizedBox(width: 8),
          _stat(Icons.star_rounded, '450', _accentColor()),
          const SizedBox(width: 8),
          if (currentTopic.toUpperCase() != 'DSA') ...[
            _roundButton(Icons.menu_book_rounded, () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyNotesScreen(theme: widget.theme),
                ),
              );
            }),
            const SizedBox(width: 8),
          ],
          _roundButton(Icons.local_fire_department_rounded, () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StreakScreen(theme: widget.theme),
              ),
            );
            if (!mounted) return;
            // Refresh streak after returning from Streak Screen
            await _loadStreak();
          }),
          const SizedBox(width: 8),
          _roundButton(Icons.logout_rounded, _logout),
        ],
      ),
    );
  }
  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
  Widget _stat(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // MAP
  // ============================================================
  bool get _isCoreTopic => const {
        'OOPS', 'DBMS', 'OS', 'OPERATING SYSTEMS',
        'CN', 'COMPUTER NETWORKS', 'ML', 'MACHINE LEARNING',
      }.contains(currentTopic.trim().toUpperCase());

  Widget _buildMap() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = min(constraints.maxWidth, 850.0);
        return Center(
          child: SizedBox(
            width: width,
            height: _isCoreTopic ? 17150 : 1850,
            child: Stack(
              children: [
                // TITLE
                Positioned(
                  top: 25,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      Text(
                        _mapTitle(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _titleColor(),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Complete challenges and unlock your path to placement.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // PATH
                Positioned.fill(
                  top: 125,
                  child: CustomPaint(
                    painter: _isCoreTopic
                        ? CoreMapPathPainter(theme: widget.theme)
                        : MapPathPainter(theme: widget.theme),
                  ),
                ),
                // LEVELS
                ..._buildLevelNodes(width),
                // BOSS
                Positioned(
                  top: _isCoreTopic ? 16900 : 1680,
                  left: width * 0.5 - 70,
                  child: BossNode(theme: widget.theme),
                ),
                // THEME DECORATIONS
                if (widget.theme == AppTheme.forest)
                  ..._forestDecorations(width),
                if (widget.theme == AppTheme.cyberpunk)
                  ..._cyberDecorations(width),
                if (widget.theme == AppTheme.kingdom)
                  ..._kingdomDecorations(width),
              ],
            ),
          ),
        );
      },
    );
  }
  List<Widget> _buildLevelNodes(double width) {
    final levels = _buildLevels();
    if (!_isCoreTopic) {
      final positions = [
        Offset(width * 0.50 - 45, 190),
        Offset(width * 0.68 - 45, 340),
        Offset(width * 0.35 - 45, 490),
        Offset(width * 0.62 - 45, 640),
        Offset(width * 0.30 - 45, 790),
        Offset(width * 0.60 - 45, 940),
        Offset(width * 0.34 - 45, 1090),
        Offset(width * 0.67 - 45, 1240),
        Offset(width * 0.38 - 45, 1390),
        Offset(width * 0.58 - 45, 1540),
      ];
      return List.generate(levels.length, (index) => Positioned(
        left: positions[index % positions.length].dx,
        top: positions[index % positions.length].dy,
        child: LevelNode(
          level: levels[index], theme: widget.theme,
          onTap: () => _handleLevelTap(levels[index]),
        ),
      ));
    }

    // Core CS map: repeat a winding, readable path for all 100 levels.
    const stepY = 165.0;
    return List.generate(levels.length, (index) {
      final y = 190.0 + index * stepY;
      final pattern = index % 6;
      final xFactors = [0.50, 0.70, 0.35, 0.62, 0.29, 0.48];
      final left = width * xFactors[pattern] - 58;
      return Positioned(
        left: left.clamp(8.0, max(8.0, width - 124)),
        top: y,
        child: LevelNode(
          level: levels[index], theme: widget.theme,
          large: true,
          onTap: () => _handleLevelTap(levels[index]),
        ),
      );
    });
  }

  // ============================================================
  // FOREST DECORATIONS
  // ============================================================
  List<Widget> _forestDecorations(double width) {
    return [
      const Positioned(top: 240, left: 15, child: ForestTree(size: 110)),
      const Positioned(top: 410, right: 15, child: ForestTree(size: 125)),
      const Positioned(top: 620, left: 10, child: ForestTree(size: 100)),
      const Positioned(top: 830, right: 10, child: ForestTree(size: 125)),
      const Positioned(top: 1060, left: 15, child: ForestTree(size: 115)),
      const Positioned(top: 1260, right: 10, child: ForestTree(size: 120)),
      const Positioned(top: 1460, left: 10, child: ForestTree(size: 110)),
      const Positioned(top: 1550, right: 20, child: Mushroom()),
    ];
  }
  // ============================================================
  // CYBER DECORATIONS
  // ============================================================
  List<Widget> _cyberDecorations(double width) {
    return [
      Positioned(
        top: 210,
        left: 12,
        child: NeonBuilding(height: 180, width: 75),
      ),
      Positioned(
        top: 430,
        right: 12,
        child: NeonBuilding(height: 220, width: 80),
      ),
      Positioned(
        top: 720,
        left: 15,
        child: NeonBuilding(height: 210, width: 80),
      ),
      Positioned(
        top: 1000,
        right: 10,
        child: NeonBuilding(height: 240, width: 85),
      ),
      Positioned(
        top: 1310,
        left: 12,
        child: NeonBuilding(height: 200, width: 75),
      ),
      Positioned(
        top: 1490,
        right: 15,
        child: NeonBuilding(height: 180, width: 70),
      ),
    ];
  }
  // ============================================================
  // KINGDOM DECORATIONS
  // ============================================================
  List<Widget> _kingdomDecorations(double width) {
    return [
      Positioned(top: 220, left: 10, child: CastleTower(height: 150)),
      Positioned(top: 430, right: 12, child: CastleTower(height: 180)),
      Positioned(top: 690, left: 10, child: CastleTower(height: 160)),
      Positioned(top: 940, right: 10, child: CastleTower(height: 190)),
      Positioned(top: 1200, left: 10, child: CastleTower(height: 170)),
      Positioned(top: 1430, right: 12, child: CastleTower(height: 180)),
    ];
  }
  // ============================================================
  // LEVEL TAP
  // ============================================================
  Future<void> _handleLevelTap(LevelData level) async {
    if (!level.unlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔒 Complete Level ${level.number - 1} first!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final topic = currentTopic.trim().toUpperCase();
    final isCoreCS = const {
      'OOPS', 'DBMS', 'OS', 'OPERATING SYSTEMS',
      'CN', 'COMPUTER NETWORKS', 'ML', 'MACHINE LEARNING',
    }.contains(topic);

    if (isCoreCS) {
      final normalizedTopic = switch (topic) {
        'OOPS' => 'OOPS',
        'DBMS' => 'DBMS',
        'OS' || 'OPERATING SYSTEMS' => 'OS',
        'CN' || 'COMPUTER NETWORKS' => 'CN',
        'ML' || 'MACHINE LEARNING' => 'ML',
        _ => topic,
      };

      final Widget? coreScreen = switch (normalizedTopic) {
        'OOPS' => OOPSCoreLevelScreen(
            level: level.number, title: level.title, subtitle: level.subtitle,
            topic: currentTopic, accentColor: _accentColor(), theme: widget.theme),
        'OS' => OSCoreLevelScreen(
            level: level.number, title: level.title, subtitle: level.subtitle,
            topic: currentTopic, accentColor: _accentColor(), theme: widget.theme),
        'DBMS' => DBMSCoreLevelScreen(
            level: level.number, title: level.title, subtitle: level.subtitle,
            topic: currentTopic, accentColor: _accentColor(), theme: widget.theme),
        'CN' => CNCoreLevelScreen(
            level: level.number, title: level.title, subtitle: level.subtitle,
            topic: currentTopic, accentColor: _accentColor(), theme: widget.theme),
        'ML' => MLCoreLevelScreen(
            level: level.number, title: level.title, subtitle: level.subtitle,
            topic: currentTopic, accentColor: _accentColor(), theme: widget.theme),
        _ => null,
      };

      if (coreScreen != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => coreScreen),
        );
      }
    } else {
      // Keep the existing DSA coding challenge flow unchanged.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LevelDetailScreen(
            level: level.number,
            title: level.title,
            subtitle: level.subtitle,
            topic: currentTopic,
            accentColor: _accentColor(),
            theme: widget.theme,
          ),
        ),
      );
    }

    await _loadProgress();
    await _loadStreak();

    if (!mounted) return;
    setState(() {});
  }

  // THEME HELPERS
  // ============================================================
  Color _accentColor() {
    switch (widget.theme) {
      case AppTheme.forest:
        return const Color(0xFF55F5D9);
      case AppTheme.cyberpunk:
        return const Color(0xFF00E5FF);
      case AppTheme.kingdom:
        return const Color(0xFFFFD166);
    }
  }
  Color _titleColor() {
    switch (widget.theme) {
      case AppTheme.forest:
        return const Color(0xFFE7D5A8);
      case AppTheme.cyberpunk:
        return const Color(0xFF00E5FF);
      case AppTheme.kingdom:
        return const Color(0xFFFFD98A);
    }
  }
  String _worldName() {
    switch (widget.theme) {
      case AppTheme.forest:
        return 'ENCHANTED FOREST';
      case AppTheme.cyberpunk:
        return 'CYBER CITY';
      case AppTheme.kingdom:
        return 'CODING KINGDOM';
    }
  }
  String _mapTitle() {
    switch (widget.theme) {
      case AppTheme.forest:
        return 'THE CODING FOREST';
      case AppTheme.cyberpunk:
        return 'THE NEON CIRCUIT';
      case AppTheme.kingdom:
        return 'THE CODING REALM';
    }
  }
}
// ============================================================
// LEVEL DATA
// ============================================================
class LevelData {
  final int number;
  final String title;
  final String subtitle;
  final bool unlocked;
  LevelData(this.number, this.title, this.subtitle, this.unlocked);
}
// ============================================================
// LEVEL NODE
// ============================================================
class LevelNode extends StatelessWidget {
  final LevelData level;
  final AppTheme theme;
  final VoidCallback onTap;
  final bool large;
  const LevelNode({
    super.key,
    required this.level,
    required this.theme,
    required this.onTap,
    this.large = false,
  });
  Color get primary {
    switch (theme) {
      case AppTheme.forest:
        return const Color(0xFF55F5D9);
      case AppTheme.cyberpunk:
        return const Color(0xFF00E5FF);
      case AppTheme.kingdom:
        return const Color(0xFFFFD166);
    }
  }
  Color get secondary {
    switch (theme) {
      case AppTheme.forest:
        return const Color(0xFF07534A);
      case AppTheme.cyberpunk:
        return const Color(0xFF7018C7);
      case AppTheme.kingdom:
        return const Color(0xFF814018);
    }
  }
  @override
  Widget build(BuildContext context) {
    final unlocked = level.unlocked;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: large ? 104 : 90,
            height: large ? 104 : 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: unlocked
                  ? RadialGradient(colors: [primary, secondary, Colors.black])
                  : const RadialGradient(
                      colors: [
                        Color(0xFF777777),
                        Color(0xFF444444),
                        Color(0xFF222222),
                      ],
                    ),
              border: Border.all(
                color: unlocked ? primary : Colors.white24,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: unlocked
                      ? primary.withValues(alpha: 0.45)
                      : Colors.black.withValues(alpha: 0.3),
                  blurRadius: unlocked ? 25 : 10,
                  spreadRadius: unlocked ? 5 : 0,
                ),
              ],
            ),
            child: unlocked
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_icon(), color: Colors.white, size: 20),
                      const SizedBox(height: 2),
                      Text(
                        '${level.number}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  )
                : const Icon(
                    Icons.lock_rounded,
                    color: Colors.white70,
                    size: 30,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: large ? 180 : 155,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.60),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: unlocked ? primary.withValues(alpha: 0.5) : Colors.white12,
            ),
          ),
          child: Column(
            children: [
              Text(
                'LEVEL ${level.number}',
                style: TextStyle(
                  color: unlocked ? primary : Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                level.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: unlocked ? Colors.white : Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                level.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.40),
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  IconData _icon() {
    switch (theme) {
      case AppTheme.forest:
        return Icons.auto_awesome_rounded;
      case AppTheme.cyberpunk:
        return Icons.bolt_rounded;
      case AppTheme.kingdom:
        return Icons.shield_rounded;
    }
  }
}
// ============================================================
// PATH
// ============================================================
class CoreMapPathPainter extends CustomPainter {
  final AppTheme theme;
  CoreMapPathPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final outerColor = switch (theme) {
      AppTheme.forest => const Color(0xFF8BCB78),
      AppTheme.cyberpunk => const Color(0xFF8A42FF),
      AppTheme.kingdom => const Color(0xFFD69A4A),
    };
    final innerColor = switch (theme) {
      AppTheme.forest => const Color(0xFF174C37),
      AppTheme.cyberpunk => const Color(0xFF21114D),
      AppTheme.kingdom => const Color(0xFF573018),
    };
    final outer = Paint()..color = outerColor.withValues(alpha: .85)
      ..style = PaintingStyle.stroke..strokeWidth = 34..strokeCap = StrokeCap.round;
    final inner = Paint()..color = innerColor
      ..style = PaintingStyle.stroke..strokeWidth = 25..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(size.width * .50, 130);
    for (var i = 0; i < 100; i++) {
      final y = 190.0 + i * 165.0;
      final x = size.width * [0.50, 0.70, 0.35, 0.62, 0.29, 0.48][i % 6];
      final nextY = y + 165;
      final nextX = size.width * [0.70, 0.35, 0.62, 0.29, 0.48, 0.50][i % 6];
      path.cubicTo(x, y + 35, nextX, nextY - 35, nextX, nextY);
    }
    canvas.drawPath(path, outer);
    canvas.drawPath(path, inner);
  }

  @override
  bool shouldRepaint(covariant CoreMapPathPainter oldDelegate) => oldDelegate.theme != theme;
}

class MapPathPainter extends CustomPainter {
  final AppTheme theme;
  MapPathPainter({required this.theme});
  @override
  void paint(Canvas canvas, Size size) {
    final outer = _outerColor();
    final inner = _innerColor();
    final outerPaint = Paint()
      ..color = outer.withValues(alpha: 0.70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 48
      ..strokeCap = StrokeCap.round;
    final innerPaint = Paint()
      ..color = inner
      ..style = PaintingStyle.stroke
      ..strokeWidth = 38
      ..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(size.width * 0.50, 80);
    path.cubicTo(
      size.width * 0.72,
      180,
      size.width * 0.75,
      270,
      size.width * 0.64,
      350,
    );
    path.cubicTo(
      size.width * 0.48,
      450,
      size.width * 0.25,
      460,
      size.width * 0.36,
      570,
    );
    path.cubicTo(
      size.width * 0.48,
      680,
      size.width * 0.75,
      700,
      size.width * 0.62,
      800,
    );
    path.cubicTo(
      size.width * 0.48,
      900,
      size.width * 0.25,
      920,
      size.width * 0.36,
      1030,
    );
    path.cubicTo(
      size.width * 0.48,
      1140,
      size.width * 0.76,
      1160,
      size.width * 0.62,
      1270,
    );
    path.cubicTo(
      size.width * 0.48,
      1380,
      size.width * 0.30,
      1440,
      size.width * 0.50,
      1580,
    );
    canvas.drawPath(path, outerPaint);
    canvas.drawPath(path, innerPaint);
    final markerPaint = Paint()..color = _markerColor();
    for (int i = 0; i < 65; i++) {
      final t = i / 65;
      final x = size.width * (0.5 + 0.18 * sin(t * 13));
      final y = 110 + t * 1450;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 20, height: 8),
        markerPaint,
      );
    }
  }
  Color _outerColor() {
    switch (theme) {
      case AppTheme.forest:
        return const Color(0xFF806B48);
      case AppTheme.cyberpunk:
        return const Color(0xFF8D4DFF);
      case AppTheme.kingdom:
        return const Color(0xFF9B713C);
    }
  }
  Color _innerColor() {
    switch (theme) {
      case AppTheme.forest:
        return const Color(0xFF3B4B39);
      case AppTheme.cyberpunk:
        return const Color(0xFF182A65);
      case AppTheme.kingdom:
        return const Color(0xFF4A3020);
    }
  }
  Color _markerColor() {
    switch (theme) {
      case AppTheme.forest:
        return const Color(0xFF9CCB75);
      case AppTheme.cyberpunk:
        return const Color(0xFF00E5FF);
      case AppTheme.kingdom:
        return const Color(0xFFFFD166);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
// ============================================================
// FOREST BACKGROUND
// ============================================================
class ForestBackground extends StatelessWidget {
  const ForestBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ForestPainter(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF071C1A),
              Color(0xFF0B3931),
              Color(0xFF09291F),
              Color(0xFF03100C),
            ],
          ),
        ),
      ),
    );
  }
}
class ForestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(25);
    final glow = Paint()
      ..color = const Color(0xFF54F0D7).withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.2), 150, glow);
    final firefly = Paint()
      ..color = const Color(0xFFE8FF72)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    for (int i = 0; i < 100; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        1.5,
        firefly,
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
// ============================================================
// FOREST TREE
// ============================================================
class ForestTree extends StatelessWidget {
  final double size;
  const ForestTree({super.key, required this.size});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size * 1.5), painter: TreePainter());
  }
}
class TreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final trunk = Paint()..color = const Color(0xFF38271B);
    final leaves = Paint()..color = const Color(0xFF123C2D);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.42,
          size.height * 0.35,
          size.width * 0.18,
          size.height * 0.60,
        ),
        const Radius.circular(8),
      ),
      trunk,
    );
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.30),
      size.width * 0.30,
      leaves,
    );
    canvas.drawCircle(
      Offset(size.width * 0.60, size.height * 0.25),
      size.width * 0.35,
      leaves,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.35),
      size.width * 0.25,
      leaves,
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
// ============================================================
// MUSHROOM
// ============================================================
class Mushroom extends StatelessWidget {
  const Mushroom({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(70, 90), painter: MushroomPainter());
  }
}
class MushroomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stem = Paint()..color = const Color(0xFFE6D4A7);
    final cap = Paint()..color = const Color(0xFFB64A5A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .40,
          size.height * .38,
          size.width * .20,
          size.height * .52,
        ),
        const Radius.circular(10),
      ),
      stem,
    );
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * .10,
        size.height * .15,
        size.width * .80,
        size.height * .45,
      ),
      cap,
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
// ============================================================
// CYBERPUNK BACKGROUND
// ============================================================
class CyberpunkBackground extends StatelessWidget {
  const CyberpunkBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CyberBackgroundPainter(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF07041A),
              Color(0xFF120B38),
              Color(0xFF240B3C),
              Color(0xFF03020A),
            ],
          ),
        ),
      ),
    );
  }
}
class CyberBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFF704DFF).withValues(alpha: 0.15)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 45) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 45) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final cyan = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.2), 130, cyan);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
// ============================================================
// NEON BUILDING
// ============================================================
class NeonBuilding extends StatelessWidget {
  final double height;
  final double width;
  const NeonBuilding({super.key, required this.height, required this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0D102C),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          7,
          (index) => Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 8,
                  height: 13,
                  color: index.isEven
                      ? const Color(0xFF00E5FF)
                      : const Color(0xFFCF4DFF),
                ),
                Container(
                  width: 8,
                  height: 13,
                  color: index.isEven
                      ? const Color(0xFFCF4DFF)
                      : const Color(0xFF00E5FF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// ============================================================
// KINGDOM BACKGROUND
// ============================================================
class KingdomBackground extends StatelessWidget {
  const KingdomBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: KingdomPainter(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF241009),
              Color(0xFF58351C),
              Color(0xFF24130B),
              Color(0xFF080403),
            ],
          ),
        ),
      ),
    );
  }
}
class KingdomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(80);
    final star = Paint()
      ..color = const Color(0xFFFFD76A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    for (int i = 0; i < 80; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        1.5,
        star,
      );
    }
    final castle = Paint()..color = const Color(0xFF170B07);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.35,
        size.height * 0.14,
        size.width * 0.30,
        100,
      ),
      castle,
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
// ============================================================
// CASTLE TOWER
// ============================================================
class CastleTower extends StatelessWidget {
  final double height;
  const CastleTower({super.key, required this.height});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF281711),
        border: Border.all(
          color: const Color(0xFFD29C4C).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Container(height: 18, color: const Color(0xFF6B3D20)),
          const SizedBox(height: 25),
          const Icon(
            Icons.local_fire_department_rounded,
            color: Color(0xFFFFA94D),
            size: 24,
          ),
        ],
      ),
    );
  }
}
// ============================================================
// BOSS
// ============================================================
class BossNode extends StatelessWidget {
  final AppTheme theme;
  const BossNode({super.key, required this.theme});
  Color get primary {
    switch (theme) {
      case AppTheme.forest:
        return const Color(0xFFFF9D35);
      case AppTheme.cyberpunk:
        return const Color(0xFFFF35D1);
      case AppTheme.kingdom:
        return const Color(0xFFFFD166);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [primary, Colors.black]),
            border: Border.all(color: primary, width: 4),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.45),
                blurRadius: 35,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_icon(), color: Colors.white, size: 38),
              const SizedBox(height: 5),
              const Text(
                'BOSS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _bossName(),
          style: TextStyle(
            color: primary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Complete all levels to unlock',
          style: TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
  IconData _icon() {
    switch (theme) {
      case AppTheme.forest:
        return Icons.castle_rounded;
      case AppTheme.cyberpunk:
        return Icons.smart_toy_rounded;
      case AppTheme.kingdom:
        return Icons.workspace_premium_rounded;
    }
  }
  String _bossName() {
    switch (theme) {
      case AppTheme.forest:
        return 'PLACEMENT CASTLE';
      case AppTheme.cyberpunk:
        return 'PLACEMENT AI';
      case AppTheme.kingdom:
        return 'PLACEMENT KING';
    }
  }
}
// ============================================================
// TEMPORARY CHALLENGE SCREEN
// ============================================================
class ChallengePlaceholder extends StatelessWidget {
  final int level;
  final String title;
  final AppTheme theme;
  const ChallengePlaceholder({
    super.key,
    required this.level,
    required this.title,
    required this.theme,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'LEVEL $level',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.code_rounded, size: 70, color: _accentColor()),
              const SizedBox(height: 25),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'The coding challenge screen will be built next.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 35),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('BACK TO MAP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Color _backgroundColor() {
    switch (theme) {
      case AppTheme.forest:
        return const Color(0xFF061713);
      case AppTheme.cyberpunk:
        return const Color(0xFF070313);
      case AppTheme.kingdom:
        return const Color(0xFF170B06);
    }
  }
  Color _accentColor() {
    switch (theme) {
      case AppTheme.forest:
        return const Color(0xFF55F5D9);
      case AppTheme.cyberpunk:
        return const Color(0xFF00E5FF);
      case AppTheme.kingdom:
        return const Color(0xFFFFD166);
    }
  }
}
