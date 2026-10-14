

import 'package:flutter/material.dart';

import 'theme_selection_screen.dart';

class LevelQuizScreen extends StatefulWidget {

  final int level;

  final Color accentColor;

  final AppTheme theme;

  final String topic;

  final String title;

  final String subtitle;

  const LevelQuizScreen({

    super.key,

    required this.level,

    required this.accentColor,

    required this.theme,

    this.topic = 'DSA',

    this.title = '',

    this.subtitle = '',

  });

  @override

  State<LevelQuizScreen> createState() => _LevelQuizScreenState();

}

class _LevelQuizScreenState extends State<LevelQuizScreen> {

  late ChallengeData challenge;

  late TextEditingController codeController;

  final ScrollController codeScrollController = ScrollController();

  bool hasRun = false;

  bool isPassed = false;

  final List<String> placedBlocks = <String>[];

  bool showQuestionOnMobile = true;

  @override

  void initState() {

    super.initState();

    challenge = ChallengeData.forLevel(

      widget.topic,

      widget.level,

      widget.title,

      widget.subtitle,

    );

    codeController = TextEditingController(text: challenge.starterCode);

  }

  @override

  void dispose() {

    codeController.dispose();

    codeScrollController.dispose();

    super.dispose();

  }

  static const Color cyan = Color(0xFF50E7FF);

  static const Color purple = Color(0xFFB989FF);

  static const Color dark = Color(0xFF07101B);

  bool get _isForest => widget.theme == AppTheme.forest;

  bool get _isCyberpunk => widget.theme == AppTheme.cyberpunk;

  bool get _isKingdom => widget.theme == AppTheme.kingdom;





  Color get _themeSurface => _isForest

      ? const Color(0xEE0D1424)

      : _isCyberpunk

          ? const Color(0xEE120E2A)

          : const Color(0xEE241A16);

  Color get _themeBorder => _isForest

      ? const Color(0xFF4B6282)

      : _isCyberpunk

          ? const Color(0xFF7B55B8)

          : const Color(0xFF8C643B);

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: dark,

      body: SafeArea(

        child: LayoutBuilder(

          builder: (context, constraints) {

            final compact = constraints.maxWidth < 950;

            return Stack(

              children: [

                Positioned.fill(child: _themeBackground()),

                Column(

                  children: [

                    _topBar(compact),

                    Expanded(

                      child: compact

                          ? _mobileLayout()

                          : _desktopLayout(),

                    ),

                  ],

                ),

              ],

            );

          },

        ),

      ),

    );

  }

  Widget _themeBackground() {

    return Stack(

      fit: StackFit.expand,

      children: [

        Container(

          decoration: BoxDecoration(

            gradient: LinearGradient(

              begin: Alignment.topCenter,

              end: Alignment.bottomCenter,

              colors: _isForest

                  ? const [Color(0xFF06152A), Color(0xFF0B2840), Color(0xFF123B32), Color(0xFF102D20)]

                  : _isCyberpunk

                      ? const [Color(0xFF09051B), Color(0xFF171044), Color(0xFF21105B), Color(0xFF070B20)]

                      : const [Color(0xFF17100C), Color(0xFF3A2111), Color(0xFF5B3219), Color(0xFF120C09)],

              stops: const [0, .35, .72, 1],

            ),

          ),

        ),

        CustomPaint(painter: _ThemeBackdropPainter(widget.theme)),

        if (_isForest) ...[

          Positioned(left: -18, top: 95, child: _treeDecoration(size: 170)),

          Positioned(right: -45, top: 70, child: _treeDecoration(size: 210)),

          Positioned(left: 8, bottom: 0, child: _mushroomCluster()),

          Positioned(right: 0, bottom: 0, child: _mushroomCluster(scale: .85)),

        ],

        if (_isCyberpunk) ...[

          Positioned(left: -40, top: 130, child: _cyberOrb(170, const Color(0xFFB968FF))),

          Positioned(right: -55, bottom: 80, child: _cyberOrb(210, const Color(0xFF35E6FF))),

        ],

        if (_isKingdom) ...[

          Positioned(left: -25, top: 110, child: _castleTower()),

          Positioned(right: -25, top: 95, child: _castleTower()),

        ],

      ],

    );

  }

  Widget _cyberOrb(double size, Color color) {

    return IgnorePointer(

      child: Container(

        width: size,

        height: size,

        decoration: BoxDecoration(

          shape: BoxShape.circle,

          color: color.withValues(alpha: .10),

          border: Border.all(color: color.withValues(alpha: .18), width: 2),

          boxShadow: [BoxShadow(color: color.withValues(alpha: .20), blurRadius: 55)],

        ),

      ),

    );

  }

  Widget _castleTower() {

    return IgnorePointer(

      child: SizedBox(

        width: 150,

        height: 260,

        child: CustomPaint(painter: _CastlePainter()),

      ),

    );

  }

  Widget _treeDecoration({double size = 170}) {

    return IgnorePointer(

      child: SizedBox(

        width: size,

        height: size,

        child: CustomPaint(painter: _TreePainter()),

      ),

    );

  }

  Widget _mushroomCluster({double scale = 1}) {

    return IgnorePointer(

      child: Transform.scale(

        scale: scale,

        alignment: Alignment.bottomRight,

        child: SizedBox(

          width: 150,

          height: 115,

          child: Stack(

            children: [

              Positioned(

                left: 20,

                bottom: 8,

                child: _mushroom(28, const Color(0xFFD95C9A)),

              ),

              Positioned(

                left: 65,

                bottom: 3,

                child: _mushroom(38, const Color(0xFF9E63E8)),

              ),

              Positioned(

                right: 4,

                bottom: 10,

                child: _mushroom(24, const Color(0xFFE48B49)),

              ),

            ],

          ),

        ),

      ),

    );

  }

  Widget _mushroom(double size, Color color) {

    return SizedBox(

      width: size,

      height: size * 1.45,

      child: CustomPaint(painter: _MushroomPainter(color)),

    );

  }

  Widget _topBar(bool compact) {

    return Container(

      height: compact ? 62 : 78,

      margin: EdgeInsets.symmetric(

        horizontal: compact ? 8 : 22,

        vertical: compact ? 5 : 8,

      ),

      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 16),

      decoration: BoxDecoration(

        color: _themeSurface.withValues(alpha: .92),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: _themeBorder),

        boxShadow: const [

          BoxShadow(

            color: Colors.black54,

            blurRadius: 22,

            offset: Offset(0, 8),

          ),

        ],

      ),

      child: Row(

        children: [

          if (!compact)

            Padding(

              padding: const EdgeInsets.only(right: 18),

              child: _brand(),

            ),

          IconButton(

            onPressed: () => Navigator.pop(context),

            icon: const Icon(

              Icons.arrow_back_rounded,

              color: Colors.white,

            ),

          ),

          if (compact)

            Text(

              'LEVEL ${widget.level}',

              style: const TextStyle(

                color: Colors.white,

                fontSize: 17,

                fontWeight: FontWeight.w900,

              ),

            ),

          if (!compact) const Spacer(),

          _navItem(Icons.menu_book_rounded, 'Quest', true),

          if (!compact) ...[

            _navItem(Icons.bar_chart_rounded, 'Progress', false),

            _navItem(Icons.pie_chart_rounded, 'Analytics', false),

            _navItem(Icons.person_rounded, 'Profile', false),

          ],

          const Spacer(),

          _streak(),

          if (!compact) const SizedBox(width: 18),

          _xp(),

          if (!compact) const SizedBox(width: 18),

          _avatar(),

        ],

      ),

    );

  }

  Widget _brand() {

    return Row(

      mainAxisSize: MainAxisSize.min,

      children: [

        Container(

          width: 47,

          height: 47,

          decoration: BoxDecoration(

            color: const Color(0xFF173D58),

            borderRadius: BorderRadius.circular(14),

            border: Border.all(color: const Color(0xFF49D7E8)),

          ),

          child: const Center(

            child: Text('🤖', style: TextStyle(fontSize: 28)),

          ),

        ),

        const SizedBox(width: 10),

        const Column(

          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(

              'Pocket',

              style: TextStyle(

                color: Colors.white,

                fontSize: 17,

                fontWeight: FontWeight.w900,

              ),

            ),

            Text(

              'Placement ✦',

              style: TextStyle(

                color: Color(0xFFF19BE5),

                fontSize: 16,

                fontWeight: FontWeight.w900,

              ),

            ),

          ],

        ),

      ],

    );

  }

  Widget _navItem(IconData icon, String label, bool active) {

    return Container(

      margin: const EdgeInsets.symmetric(horizontal: 3),

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),

      decoration: BoxDecoration(

        color: active ? const Color(0xFF1C5062) : Colors.transparent,

        borderRadius: BorderRadius.circular(11),

        border: active

            ? Border.all(color: const Color(0xFF3C8792))

            : null,

      ),

      child: Row(

        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(

            icon,

            size: 18,

            color: active ? cyan : Colors.white70,

          ),

          const SizedBox(width: 6),

          Text(

            label,

            style: TextStyle(

              color: active ? Colors.white : Colors.white70,

              fontSize: 12,

              fontWeight: FontWeight.w800,

            ),

          ),

        ],

      ),

    );

  }

  Widget _streak() {

    return const Row(

      mainAxisSize: MainAxisSize.min,

      children: [

        Text('🔥', style: TextStyle(fontSize: 22)),

        SizedBox(width: 4),

        Column(

          mainAxisAlignment: MainAxisAlignment.center,

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(

              '7',

              style: TextStyle(

                color: Colors.white,

                fontWeight: FontWeight.w900,

                fontSize: 16,

              ),

            ),

            Text(

              'Day Streak',

              style: TextStyle(color: Colors.white70, fontSize: 8),

            ),

          ],

        ),

      ],

    );

  }

  Widget _xp() {

    return const Row(

      mainAxisSize: MainAxisSize.min,

      children: [

        Text(

          '★',

          style: TextStyle(

            color: Color(0xFFFFD54F),

            fontSize: 25,

          ),

        ),

        SizedBox(width: 4),

        Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(

              '320',

              style: TextStyle(

                color: Colors.white,

                fontWeight: FontWeight.w900,

                fontSize: 16,

              ),

            ),

            Text(

              'XP',

              style: TextStyle(color: Colors.white70, fontSize: 8),

            ),

          ],

        ),

      ],

    );

  }

  Widget _avatar() {

    return Container(

      width: 43,

      height: 43,

      decoration: const BoxDecoration(

        shape: BoxShape.circle,

        gradient: LinearGradient(

          colors: [Color(0xFF4D7EA8), Color(0xFFE18CC9)],

        ),

      ),

      child: const Center(

        child: Text('👩🏻', style: TextStyle(fontSize: 25)),

      ),

    );

  }

  Widget _desktopLayout() {

    return Padding(

      padding: const EdgeInsets.fromLTRB(8, 10, 18, 12),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [

          SizedBox(

            width: 108,

            child: Stack(

              clipBehavior: Clip.none,

              children: [

                Positioned(

                  left: -24,

                  top: 150,

                  child: _woodenSigns(),

                ),

                Positioned(

                  left: -18,

                  bottom: 2,

                  child: Transform.scale(

                    scale: .76,

                    alignment: Alignment.bottomLeft,

                    child: _mochi(),

                  ),

                ),

                Positioned(

                  left: 18,

                  top: 14,

                  child: Transform.scale(

                    scale: .72,

                    child: _lantern(),

                  ),

                ),

              ],

            ),

          ),

          Expanded(

            flex: 45,

            child: _questionCard(),

          ),

          const SizedBox(width: 16),

          Expanded(

            flex: 55,

            child: _editorCard(),

          ),

        ],

      ),

    );

  }

  Widget _mobileLayout() {

    return Padding(

      padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),

      child: Column(

        children: [

          _mobileTabs(),

          const SizedBox(height: 8),

          Expanded(

            child: showQuestionOnMobile

                ? _questionCard()

                : _editorCard(),

          ),

        ],

      ),

    );

  }

  Widget _mobileTabs() {

    return Container(

      height: 48,

      padding: const EdgeInsets.all(4),

      decoration: BoxDecoration(

        color: _themeSurface.withValues(alpha: .92),

        borderRadius: BorderRadius.circular(13),

        border: Border.all(color: _themeBorder),

      ),

      child: Row(

        children: [

          Expanded(

            child: _mobileTabButton(

              icon: Icons.menu_book_rounded,

              label: 'Question',

              selected: showQuestionOnMobile,

              onTap: () => setState(() => showQuestionOnMobile = true),

            ),

          ),

          const SizedBox(width: 4),

          Expanded(

            child: _mobileTabButton(

              icon: Icons.code_rounded,

              label: 'Code',

              selected: !showQuestionOnMobile,

              onTap: () => setState(() => showQuestionOnMobile = false),

            ),

          ),

        ],

      ),

    );

  }

  Widget _mobileTabButton({

    required IconData icon,

    required String label,

    required bool selected,

    required VoidCallback onTap,

  }) {

    return Material(

      color: Colors.transparent,

      child: InkWell(

        borderRadius: BorderRadius.circular(9),

        onTap: onTap,

        child: AnimatedContainer(

          duration: const Duration(milliseconds: 160),

          decoration: BoxDecoration(

            color: selected ? const Color(0xFF1C5366) : Colors.transparent,

            borderRadius: BorderRadius.circular(9),

            border: selected

                ? Border.all(color: const Color(0xFF4C91A3))

                : null,

          ),

          child: Row(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Icon(

                icon,

                size: 18,

                color: selected ? cyan : Colors.white60,

              ),

              const SizedBox(width: 7),

              Text(

                label,

                style: TextStyle(

                  color: selected ? Colors.white : Colors.white.withValues(alpha: 0.65),

                  fontSize: 12,

                  fontWeight: FontWeight.w900,

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

  Widget _questionCard() {

    return Container(

      decoration: BoxDecoration(

        color: _isForest

            ? const Color(0xFFF7E8CC)

            : _isCyberpunk

                ? const Color(0xE51B1634)

                : const Color(0xF3E7D0B6),

        borderRadius: BorderRadius.circular(26),

        border: Border.all(

          color: _isForest

              ? const Color(0xFFA96C39)

              : _isCyberpunk

                  ? const Color(0xFF8D63D8)

                  : const Color(0xFF9C6B38),

          width: 3,

        ),

        boxShadow: const [

          BoxShadow(

            color: Colors.black54,

            blurRadius: 20,

            offset: Offset(0, 10),

          ),

        ],

      ),

      clipBehavior: Clip.antiAlias,

      child: Stack(

        children: [

          Positioned.fill(

            child: CustomPaint(painter: _PaperTexturePainter()),

          ),

          if (_isForest)

            Positioned(

              right: -20,

              top: 0,

              bottom: 0,

              child: IgnorePointer(

                child: CustomPaint(

                  size: const Size(55, 400),

                  painter: _LeafBorderPainter(),

                ),

              ),

            ),

          if (_isCyberpunk)

            Positioned.fill(

              child: IgnorePointer(

                child: CustomPaint(painter: _CyberPanelPainter()),

              ),

            ),

          SingleChildScrollView(

            padding: const EdgeInsets.fromLTRB(48, 28, 34, 28),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Row(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Transform.rotate(

                      angle: -.055,

                      child: Container(

                        padding: const EdgeInsets.symmetric(

                          horizontal: 24,

                          vertical: 11,

                        ),

                        decoration: BoxDecoration(

                          gradient: LinearGradient(

                            colors: _isCyberpunk

                                ? const [Color(0xFF8C4FE8), Color(0xFF3E247A)]

                                : _isKingdom

                                    ? const [Color(0xFFD19A4A), Color(0xFF8B5628)]

                                    : const [Color(0xFFD58A42), Color(0xFFB96D32)],

                          ),

                          borderRadius: BorderRadius.circular(8),

                          border: Border.all(

                            color: const Color(0xFF8A4E26),

                          ),

                          boxShadow: const [

                            BoxShadow(

                              color: Colors.black38,

                              blurRadius: 6,

                              offset: Offset(2, 4),

                            ),

                          ],

                        ),

                        child: Text(

                          'LEVEL ${widget.level}',

                          style: const TextStyle(

                            color: Color(0xFF25170C),

                            fontSize: 20,

                            fontWeight: FontWeight.w900,

                          ),

                        ),

                      ),

                    ),

                    const Spacer(),

                    _difficultyBadge(),

                  ],

                ),

                const SizedBox(height: 24),

                Text(

                  challenge.title,

                  style: TextStyle(

                    color: _isCyberpunk ? Colors.white : const Color(0xFF13233B),

                    fontSize: 26,

                    fontWeight: FontWeight.w900,

                  ),

                ),

                const SizedBox(height: 10),

                Text(

                  challenge.problem,

                  style: TextStyle(

                    color: _isCyberpunk ? const Color(0xFFF1ECFF) : const Color(0xFF342A20),

                    fontSize: 15,

                    height: 1.48,

                    fontWeight: FontWeight.w600,

                  ),

                ),

                const SizedBox(height: 20),

                _paperSection(

                  icon: Icons.menu_book_rounded,

                  title: 'Example',

                  iconColor: const Color(0xFFE92E8D),

                  background: _isCyberpunk ? const Color(0x332A1E58) : const Color(0xFFF4E6ED),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(

                        'Input: ${challenge.input}',

                        style: _paperMono(),

                      ),

                      const SizedBox(height: 6),

                      Text(

                        'Output: ${challenge.output}',

                        style: _paperMono(),

                      ),

                    ],

                  ),

                ),

                const SizedBox(height: 13),

                _paperSection(

                  icon: Icons.settings_suggest_rounded,

                  title: 'Constraints',

                  iconColor: const Color(0xFF2FA44F),

                  background: _isCyberpunk ? const Color(0x33205A63) : const Color(0xFFE8F1D7),

                  child: Text(

                    challenge.constraints,

                    style: TextStyle(

                      color: _isCyberpunk ? const Color(0xFFE8FFF3) : const Color(0xFF33462F),

                      fontSize: 13,

                      fontWeight: FontWeight.w800,

                    ),

                  ),

                ),

                const SizedBox(height: 13),

                _paperSection(

                  icon: Icons.lightbulb_rounded,

                  title: 'Hint',

                  iconColor: const Color(0xFFFFA313),

                  background: _isCyberpunk ? const Color(0x332E275A) : const Color(0xFFF8E7C8),

                  child: Text(

                    challenge.hint,

                    style: TextStyle(

                      color: _isCyberpunk ? const Color(0xFFFFF3D6) : const Color(0xFF473622),

                      fontSize: 13,

                      height: 1.4,

                      fontWeight: FontWeight.w600,

                    ),

                  ),

                ),

                const SizedBox(height: 85),

              ],

            ),

          ),

        ],

      ),

    );

  }

  TextStyle _paperMono() {

    return TextStyle(

      color: _isCyberpunk ? const Color(0xFFF5F0FF) : const Color(0xFF29251E),

      fontFamily: 'monospace',

      fontSize: 13,

      fontWeight: FontWeight.w700,

    );

  }

  Widget _difficultyBadge() {

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),

      decoration: BoxDecoration(

        color: const Color(0xFFDFF2CF),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: const Color(0xFF78AA5C)),

      ),

      child: Row(

        mainAxisSize: MainAxisSize.min,

        children: [

          const Icon(

            Icons.eco_rounded,

            color: Color(0xFF35863B),

            size: 16,

          ),

          const SizedBox(width: 5),

          Text(

            challenge.difficulty,

            style: const TextStyle(

              color: Color(0xFF356C37),

              fontWeight: FontWeight.w900,

              fontSize: 12,

            ),

          ),

        ],

      ),

    );

  }

  Widget _paperSection({

    required IconData icon,

    required String title,

    required Widget child,

    required Color iconColor,

    required Color background,

  }) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(

        color: background.withValues(alpha: .88),

        borderRadius: BorderRadius.circular(15),

        border: Border.all(color: const Color(0xFFE2CBAA)),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Icon(icon, color: iconColor, size: 21),

              const SizedBox(width: 9),

              Text(

                title,

                style: TextStyle(

                  color: _isCyberpunk ? Colors.white : const Color(0xFF18243A),

                  fontSize: 14,

                  fontWeight: FontWeight.w900,

                ),

              ),

            ],

          ),

          const SizedBox(height: 10),

          child,

        ],

      ),

    );

  }

  Widget _woodenSigns() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        _woodSign('DSA', -0.07),

        const SizedBox(height: 9),

        _woodSign('Core CS', 0.04),

      ],

    );

  }

  Widget _woodSign(String text, double angle) {

    return Transform.rotate(

      angle: angle,

      child: Container(

        width: 118,

        padding: const EdgeInsets.symmetric(

          horizontal: 18,

          vertical: 11,

        ),

        decoration: BoxDecoration(

          gradient: const LinearGradient(

            colors: [

              Color(0xFFC47A45),

              Color(0xFF8E512E),

            ],

          ),

          borderRadius: const BorderRadius.horizontal(

            right: Radius.circular(8),

          ),

          border: Border.all(color: const Color(0xFF5B321E)),

          boxShadow: const [

            BoxShadow(

              color: Colors.black45,

              blurRadius: 7,

              offset: Offset(3, 5),

            ),

          ],

        ),

        child: Text(

          text,

          textAlign: TextAlign.center,

          style: const TextStyle(

            color: Color(0xFF20150F),

            fontSize: 15,

            fontWeight: FontWeight.w900,

          ),

        ),

      ),

    );

  }

  Widget _lantern() {

    return Container(

      width: 50,

      height: 70,

      decoration: BoxDecoration(

        color: const Color(0xFFFFC44B).withValues(alpha: .13),

        borderRadius: BorderRadius.circular(24),

        boxShadow: const [

          BoxShadow(

            color: Color(0xFFFFA52B),

            blurRadius: 30,

          ),

        ],

      ),

      child: const Center(

        child: Text('🏮', style: TextStyle(fontSize: 38)),

      ),

    );

  }

  Widget _mochi() {

    return IgnorePointer(

      child: SizedBox(

        width: 175,

        height: 190,

        child: Stack(

          alignment: Alignment.bottomCenter,

          children: [

            Positioned(

              bottom: 5,

              child: Container(

                width: 150,

                height: 38,

                decoration: BoxDecoration(

                  color: const Color(0xFF70482E),

                  borderRadius: BorderRadius.circular(28),

                  boxShadow: const [

                    BoxShadow(

                      color: Colors.black54,

                      blurRadius: 9,

                      offset: Offset(0, 5),

                    ),

                  ],

                ),

              ),

            ),

            Positioned(

              bottom: 26,

              child: Container(

                width: 108,

                height: 125,

                decoration: BoxDecoration(

                  color: const Color(0xFFF4F0E7),

                  borderRadius: BorderRadius.circular(45),

                  border: Border.all(

                    color: const Color(0xFFB9B4A9),

                    width: 2,

                  ),

                  boxShadow: const [

                    BoxShadow(

                      color: Colors.black45,

                      blurRadius: 10,

                      offset: Offset(2, 7),

                    ),

                  ],

                ),

                child: Column(

                  children: [

                    const SizedBox(height: 22),

                    Container(

                      width: 78,

                      height: 50,

                      decoration: BoxDecoration(

                        color: const Color(0xFF071522),

                        borderRadius: BorderRadius.circular(23),

                        border: Border.all(

                          color: const Color(0xFF66D7E5),

                          width: 2,

                        ),

                      ),

                      child: const Center(

                        child: Text(

                          '•ᴗ•',

                          style: TextStyle(

                            color: Color(0xFF64E8FF),

                            fontSize: 22,

                            fontWeight: FontWeight.w900,

                          ),

                        ),

                      ),

                    ),

                    const SizedBox(height: 8),

                    const Text('📖', style: TextStyle(fontSize: 30)),

                  ],

                ),

              ),

            ),

            Positioned(

              left: 22,

              bottom: 61,

              child: _robotArm(),

            ),

            Positioned(

              right: 20,

              bottom: 61,

              child: Transform.rotate(

                angle: -.2,

                child: _robotArm(),

              ),

            ),

            Positioned(

              left: 18,

              bottom: 93,

              child: Container(

                width: 20,

                height: 20,

                decoration: const BoxDecoration(

                  color: Color(0xFF65E3F2),

                  shape: BoxShape.circle,

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

  Widget _robotArm() {

    return Container(

      width: 28,

      height: 58,

      decoration: BoxDecoration(

        color: const Color(0xFFEAE5DA),

        borderRadius: BorderRadius.circular(15),

        border: Border.all(color: const Color(0xFFAAA69D)),

      ),

    );

  }

  Widget _editorCard() {

    return Container(

      decoration: BoxDecoration(

        color: _themeSurface,

        borderRadius: BorderRadius.circular(21),

        border: Border.all(

          color: _themeBorder,

          width: 1.4,

        ),

        boxShadow: const [

          BoxShadow(

            color: Colors.black87,

            blurRadius: 24,

            offset: Offset(0, 10),

          ),

        ],

      ),

      clipBehavior: Clip.antiAlias,

      child: Column(

        children: [

          _editorToolbar(),

          Expanded(

            flex: 50,

            child: _dragDropEditor(),

          ),

          Expanded(

            flex: 50,

            child: _outputPanel(),

          ),

        ],

      ),

    );

  }

  Widget _dragDropEditor() {

    final blocks = _blocksForLevel();

    return Container(

      color: _isCyberpunk ? const Color(0xFF0C0920) : _isKingdom ? const Color(0xFF130D0A) : const Color(0xFF0C1321),

      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),

      child: Column(

        children: [

          Expanded(

            flex: 7,

            child: _dropCodeArea(),

          ),

          const SizedBox(height: 8),

          SizedBox(

            height: 108,

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const Padding(

                  padding: EdgeInsets.only(left: 5, bottom: 6),

                  child: Row(

                    children: [

                      Icon(

                        Icons.drag_indicator_rounded,

                        color: Color(0xFF63E8B7),

                        size: 18,

                      ),

                      SizedBox(width: 5),

                      Text(

                        'DRAG CODE BLOCKS',

                        style: TextStyle(

                          color: Colors.white70,

                          fontSize: 10,

                          fontWeight: FontWeight.w900,

                          letterSpacing: 1,

                        ),

                      ),

                    ],

                  ),

                ),

                Expanded(

                  child: ListView.separated(

                    scrollDirection: Axis.horizontal,

                    itemCount: blocks.length,

                    separatorBuilder: (_, _) => const SizedBox(width: 8),

                    itemBuilder: (context, index) {

                      final block = blocks[index];

                      return _draggableCodeBlock(block);

                    },

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

  Widget _dropCodeArea() {

    return DragTarget<String>(

      onWillAcceptWithDetails: (_) => true,

      onAcceptWithDetails: (details) {

        setState(() {

          placedBlocks.add(details.data);

          hasRun = false;

        });

      },

      builder: (context, candidateData, rejectedData) {

        return AnimatedContainer(

          duration: const Duration(milliseconds: 160),

          decoration: BoxDecoration(

            color: candidateData.isNotEmpty

                ? const Color(0xFF142A2B)

                : const Color(0xFF09111F),

            borderRadius: BorderRadius.circular(9),

            border: Border.all(

              color: candidateData.isNotEmpty

                  ? const Color(0xFF63E8B7)

                  : const Color(0xFF23324A),

              width: candidateData.isNotEmpty ? 1.5 : 1,

            ),

          ),

          child: Column(

            children: [

              Expanded(

                child: placedBlocks.isEmpty

                    ? _emptyDropState()

                    : _placedCodeList(),

              ),

              if (placedBlocks.isNotEmpty)

                Align(

                  alignment: Alignment.centerRight,

                  child: TextButton.icon(

                    onPressed: () {

                      setState(() {

                        placedBlocks.clear();

                        hasRun = false;

                        isPassed = false;

                      });

                    },

                    icon: const Icon(Icons.delete_outline_rounded, size: 15),

                    label: const Text('Clear'),

                    style: TextButton.styleFrom(

                      foregroundColor: Colors.white54,

                      padding: const EdgeInsets.only(right: 12),

                    ),

                  ),

                ),

            ],

          ),

        );

      },

    );

  }

  Widget _emptyDropState() {

    return Center(

      child: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(

            Icons.file_download_outlined,

            color: const Color(0xFF65738A),

            size: 31,

          ),

          const SizedBox(height: 7),

          const Text(

            'Drag code blocks here',

            style: TextStyle(

              color: Color(0xFF9AA5B7),

              fontSize: 12,

              fontWeight: FontWeight.w700,

            ),

          ),

          const SizedBox(height: 3),

          const Text(

            'Build the solution step by step',

            style: TextStyle(

              color: Color(0xFF566177),

              fontSize: 10,

            ),

          ),

        ],

      ),

    );

  }

  Widget _placedCodeList() {

    return ReorderableListView.builder(

      padding: const EdgeInsets.fromLTRB(9, 9, 9, 2),

      buildDefaultDragHandles: false,

      itemCount: placedBlocks.length,

      onReorderItem: (oldIndex, newIndex) {

        setState(() {

          final item = placedBlocks.removeAt(oldIndex);

          placedBlocks.insert(newIndex, item);

          hasRun = false;

        });

      },

      itemBuilder: (context, index) {

        final block = placedBlocks[index];

        return Container(

          key: ValueKey('${block}_$index'),

          margin: const EdgeInsets.only(bottom: 5),

          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),

          decoration: BoxDecoration(

            color: const Color(0xFF111C2E),

            borderRadius: BorderRadius.circular(6),

            border: Border.all(color: const Color(0xFF293A54)),

          ),

          child: Row(

            children: [

              ReorderableDragStartListener(

                index: index,

                child: const Icon(

                  Icons.drag_handle_rounded,

                  color: Color(0xFF718097),

                  size: 16,

                ),

              ),

              const SizedBox(width: 8),

              Expanded(

                child: Text(

                  '${index + 1}  $block',

                  style: const TextStyle(

                    color: Color(0xFFDCE6F5),

                    fontSize: 12,

                    fontFamily: 'monospace',

                  ),

                ),

              ),

              IconButton(

                visualDensity: VisualDensity.compact,

                padding: EdgeInsets.zero,

                constraints: const BoxConstraints(

                  minWidth: 25,

                  minHeight: 25,

                ),

                onPressed: () {

                  setState(() {

                    placedBlocks.removeAt(index);

                    hasRun = false;

                    isPassed = false;

                  });

                },

                icon: const Icon(

                  Icons.close_rounded,

                  color: Color(0xFF7B879A),

                  size: 15,

                ),

              ),

            ],

          ),

        );

      },

    );

  }

  Widget _draggableCodeBlock(String block) {

    return Draggable<String>(

      data: block,

      rootOverlay: true,

      feedback: Material(

        color: Colors.transparent,

        child: ConstrainedBox(

          constraints: const BoxConstraints(maxWidth: 270),

          child: _codeChip(block, dragging: true),

        ),

      ),

      childWhenDragging: Opacity(

        opacity: .35,

        child: _codeChip(block),

      ),

      child: _codeChip(block),

    );

  }

  Widget _codeChip(String block, {bool dragging = false}) {

    return Container(

      width: 210,

      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),

      decoration: BoxDecoration(

        gradient: LinearGradient(

          colors: dragging

              ? const [Color(0xFF29445A), Color(0xFF1B3145)]

              : const [Color(0xFF18253A), Color(0xFF111B2B)],

        ),

        borderRadius: BorderRadius.circular(9),

        border: Border.all(

          color: dragging

              ? const Color(0xFF63E8B7)

              : const Color(0xFF3A4E6A),

        ),

        boxShadow: dragging

            ? const [

                BoxShadow(

                  color: Color(0x554CE8C5),

                  blurRadius: 12,

                ),

              ]

            : null,

      ),

      child: Row(

        children: [

          const Icon(

            Icons.code_rounded,

            color: Color(0xFF63E8B7),

            size: 16,

          ),

          const SizedBox(width: 8),

          Expanded(

            child: Text(

              block,

              maxLines: 2,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(

                color: Color(0xFFE0E7F2),

                fontSize: 11,

                fontFamily: 'monospace',

                fontWeight: FontWeight.w600,

              ),

            ),

          ),

        ],

      ),

    );

  }

  List<String> _blocksForLevel() {

    switch (widget.level) {

      case 1:

        return const [

          'int total = 70 + 65 + 60;',

          'if (total >= 180) {',

          'System.out.println("Qualified");',

          '} else {',

          'System.out.println("Not Qualified");',

          '}',

        ];

      case 2:

        return const [

          'int target = 9;',

          'for (int i = 0; i < arr.length; i++) {',

          'if (arr[i] == target) {',

          'System.out.println(i);',

          '}',

          '}',

        ];

      case 3:

        return const [

          'char[] chars = s.toCharArray();',

          'Arrays.sort(chars);',

          'String sorted = new String(chars);',

          'System.out.println(sorted);',

        ];

      case 4:

        return const [

          'int left = 0, right = arr.length - 1;',

          'while (left <= right) {',

          'int mid = (left + right) / 2;',

          'if (arr[mid] == target) return mid;',

          'if (arr[mid] < target) left = mid + 1;',

          'else right = mid - 1;',

          '}',

        ];

      default:

        return const [

          'int answer = 0;',

          'for (int i = 0; i < n; i++) {',

          'answer += value;',

          '}',

          'System.out.println(answer);',

        ];

    }

  }

  Widget _outputTab(String label, bool active) {

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 15),

      height: 46,

      alignment: Alignment.center,

      decoration: BoxDecoration(

        border: active

            ? const Border(

                bottom: BorderSide(

                  color: purple,

                  width: 2.5,

                ),

              )

            : null,

      ),

      child: Text(

        label,

        style: TextStyle(

          color: active ? Colors.white : Colors.white54,

          fontSize: 12,

          fontWeight: FontWeight.w800,

        ),

      ),

    );

  }

  void _runCode() {

    bool pass = false;

    if (widget.level == 1) {

      const expected = [

        'int total = 70 + 65 + 60;',

        'if (total >= 180) {',

        'System.out.println("Qualified");',

        '} else {',

        'System.out.println("Not Qualified");',

        '}',

      ];

      pass = placedBlocks.length == expected.length;

      if (pass) {

        for (int i = 0; i < expected.length; i++) {

          if (placedBlocks[i] != expected[i]) {

            pass = false;

            break;

          }

        }

      }

    } else {

      pass = placedBlocks.length >= 3;

    }

    setState(() {

      hasRun = true;

      isPassed = pass;

    });

  }

  Widget _editorToolbar() {

    return Container(

      height: 54,

      padding: const EdgeInsets.symmetric(horizontal: 12),

      decoration: const BoxDecoration(color: Color(0xFF141C30), border: Border(bottom: BorderSide(color: Color(0xFF2B3950)))),

      child: Row(

        children: [

          Container(

            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),

            decoration: BoxDecoration(color: const Color(0xFF0E1525), borderRadius: BorderRadius.circular(9), border: Border.all(color: const Color(0xFF34435B))),

            child: const Row(

              children: [

                Text('☕', style: TextStyle(fontSize: 16)),

                SizedBox(width: 8),

                Text('Java', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),

                SizedBox(width: 18),

                Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white60, size: 18),

              ],

            ),

          ),

          const Spacer(),

          _editorIcon(Icons.light_mode_rounded),

          const SizedBox(width: 8),

          _editorIcon(Icons.data_object_rounded),

          const SizedBox(width: 8),

          _editorIcon(Icons.fullscreen_rounded),

        ],

      ),

    );

  }

  Widget _editorIcon(IconData icon) {

    return Container(

      width: 36,

      height: 36,

      decoration: BoxDecoration(color: const Color(0xFF1B2235), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF34435B))),

      child: Icon(icon, color: Colors.white70, size: 18),

    );

  }

  Widget _outputPanel() {

    return Container(

      color: const Color(0xFF10172A),

      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),

      child: Column(

        children: [

          SizedBox(

            height: 43,

            child: Row(

              children: [

                _outputTab('Output', true),

                _outputTab('Test Cases', false),

              ],

            ),

          ),

          Expanded(

            child: Container(

              width: double.infinity,

              decoration: const BoxDecoration(color: Color(0xFF0D1423), borderRadius: BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7))),

              child: Center(

                child: hasRun

                    ? Column(

                        mainAxisSize: MainAxisSize.min,

                        children: [

                          Icon(isPassed ? Icons.check_circle_rounded : Icons.error_rounded, color: isPassed ? const Color(0xFF61E6A5) : const Color(0xFFFF7186), size: 30),

                          const SizedBox(height: 7),

                          Text(isPassed ? challenge.output : 'Check your code and try again.', style: const TextStyle(color: Colors.white70, fontSize: 12)),

                        ],

                      )

                    : const Column(

                        mainAxisSize: MainAxisSize.min,

                        children: [

                          Text('>_', style: TextStyle(color: Color(0xFF6D778A), fontFamily: 'monospace', fontSize: 17)),

                          SizedBox(height: 8),

                          Text('Run your code to see the output here...', style: TextStyle(color: Color(0xFF687286), fontSize: 12)),

                        ],

                      ),

              ),

            ),

          ),

          const SizedBox(height: 10),

          Row(

            children: [

              SizedBox(

                width: 116,

                height: 43,

                child: OutlinedButton.icon(

                  onPressed: () {

                    setState(() {

                      codeController.text = challenge.starterCode;

                      hasRun = false;

                      isPassed = false;

                    });

                  },

                  icon: const Icon(Icons.refresh_rounded, size: 18),

                  label: const Text('Reset'),

                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white70, side: const BorderSide(color: Color(0xFF555E73)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),

                ),

              ),

              const Spacer(),

              SizedBox(

                width: 190,

                height: 43,

                child: ElevatedButton.icon(

                  onPressed: _runCode,

                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.black),

                  label: const Text('Run Code', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),

                  style: ElevatedButton.styleFrom(

                    backgroundColor: const Color(0xFF59E7B5),

                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

                  ),

                ),

              ),

            ],

          ),

        ],

      ),

    );

  }

}

class _PaperTexturePainter extends CustomPainter {

  @override

  void paint(Canvas canvas, Size size) {

    final paint = Paint()

      ..color = const Color(0xFF9D7C51).withValues(alpha: .065);

    for (double y = 0; y < size.height; y += 12) {

      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

    }

  }

  @override

  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}

class _ThemeBackdropPainter extends CustomPainter {

  final AppTheme theme;

  _ThemeBackdropPainter(this.theme);

  @override

  void paint(Canvas canvas, Size size) {

    final p = Paint();

    if (theme == AppTheme.cyberpunk) {

      p.color = const Color(0xFFB968FF).withValues(alpha: .14);

      for (double x = 0; x < size.width; x += 42) {

        canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);

      }

      p.color = const Color(0xFF35E6FF).withValues(alpha: .08);

      for (double y = 0; y < size.height; y += 42) {

        canvas.drawLine(Offset(0, y), Offset(size.width, y), p);

      }

      p.color = const Color(0xFFB968FF).withValues(alpha: .13);

      canvas.drawCircle(Offset(size.width * .78, size.height * .22), 180, p);

      p.color = const Color(0xFF35E6FF).withValues(alpha: .10);

      canvas.drawCircle(Offset(size.width * .20, size.height * .78), 220, p);

    } else if (theme == AppTheme.kingdom) {

      p.color = const Color(0xFFFFC857).withValues(alpha: .10);

      canvas.drawCircle(Offset(size.width * .78, size.height * .20), 130, p);

      p.color = const Color(0xFF7A4323).withValues(alpha: .28);

      for (double y = size.height * .68; y < size.height; y += 34) {

        canvas.drawRect(Rect.fromLTWH(0, y, size.width, 18), p);

      }

    } else {

      p.color = const Color(0xFFFFD86A).withValues(alpha: .07);

      canvas.drawCircle(Offset(size.width * .55, size.height * .18), size.width * .34, p);

    }

  }

  @override

  bool shouldRepaint(covariant _ThemeBackdropPainter oldDelegate) => oldDelegate.theme != theme;

}

class _CyberPanelPainter extends CustomPainter {

  @override

  void paint(Canvas canvas, Size size) {

    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 1;

    p.color = const Color(0xFFB968FF).withValues(alpha: .12);

    for (double y = 0; y < size.height; y += 26) {

      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);

    }

    p.color = const Color(0xFF35E6FF).withValues(alpha: .08);

    for (double x = 0; x < size.width; x += 26) {

      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);

    }

  }

  @override

  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}

class _CastlePainter extends CustomPainter {

  @override

  void paint(Canvas canvas, Size size) {

    final stone = Paint()..color = const Color(0xFF3A2A28);

    final roof = Paint()..color = const Color(0xFF7A4323);

    final gold = Paint()..color = const Color(0xFFFFC857);

    canvas.drawRect(Rect.fromLTWH(size.width * .25, size.height * .28, size.width * .5, size.height * .72), stone);

    canvas.drawRect(Rect.fromLTWH(size.width * .08, size.height * .42, size.width * .24, size.height * .58), stone);

    canvas.drawRect(Rect.fromLTWH(size.width * .68, size.height * .42, size.width * .24, size.height * .58), stone);

    for (final x in [size.width * .08, size.width * .25, size.width * .68, size.width * .84]) {

      canvas.drawRect(Rect.fromLTWH(x, size.height * .32, size.width * .16, size.height * .10), roof);

    }

    canvas.drawCircle(Offset(size.width * .50, size.height * .44), 6, gold);

  }

  @override

  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}

class _TreePainter extends CustomPainter {

  @override

  void paint(Canvas canvas, Size size) {

    final trunk = Paint()..color = const Color(0xFF241A1A);

    final leaves = Paint()..color = const Color(0xFF123F37);

    final leaves2 = Paint()..color = const Color(0xFF1B5A46);

    canvas.drawRect(

      Rect.fromLTWH(size.width * .42, 0, size.width * .16, size.height),

      trunk,

    );

    for (final o in [

      Offset(size.width * .25, size.height * .25),

      Offset(size.width * .55, size.height * .16),

      Offset(size.width * .72, size.height * .36),

      Offset(size.width * .38, size.height * .48),

      Offset(size.width * .75, size.height * .64),

    ]) {

      canvas.drawCircle(o, size.width * .22, leaves);

    }

    for (final o in [

      Offset(size.width * .20, size.height * .52),

      Offset(size.width * .58, size.height * .38),

      Offset(size.width * .70, size.height * .75),

    ]) {

      canvas.drawCircle(o, size.width * .15, leaves2);

    }

  }

  @override

  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}

class _MushroomPainter extends CustomPainter {

  final Color color;

  _MushroomPainter(this.color);

  @override

  void paint(Canvas canvas, Size size) {

    final stem = Paint()..color = const Color(0xFFF1E4C9);

    final cap = Paint()..color = color;

    final stemRect = RRect.fromRectAndRadius(

      Rect.fromLTWH(

        size.width * .32,

        size.height * .38,

        size.width * .36,

        size.height * .56,

      ),

      Radius.circular(size.width * .12),

    );

    canvas.drawRRect(stemRect, stem);

    final path = Path()

      ..moveTo(size.width * .05, size.height * .45)

      ..quadraticBezierTo(

        size.width * .5,

        size.height * .02,

        size.width * .95,

        size.height * .45,

      )

      ..close();

    canvas.drawPath(path, cap);

    final dot = Paint()..color = Colors.white.withValues(alpha: .75);

    canvas.drawCircle(

      Offset(size.width * .35, size.height * .27),

      size.width * .06,

      dot,

    );

    canvas.drawCircle(

      Offset(size.width * .62, size.height * .20),

      size.width * .05,

      dot,

    );

  }

  @override

  bool shouldRepaint(covariant _MushroomPainter oldDelegate) {

    return oldDelegate.color != color;

  }

}

class _LeafBorderPainter extends CustomPainter {

  @override

  void paint(Canvas canvas, Size size) {

    final leaf = Paint()..color = const Color(0xFF2B7A4B);

    for (int i = 0; i < 8; i++) {

      final y = 30.0 + i * 62;

      canvas.save();

      canvas.translate(size.width * .35, y);

      canvas.rotate(i.isEven ? -.5 : .5);

      canvas.drawOval(

        Rect.fromCenter(

          center: Offset.zero,

          width: 34,

          height: 17,

        ),

        leaf,

      );

      canvas.restore();

    }

  }

  @override

  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}

class ChallengeData {

  final String title;

  final String subtitle;

  final String problem;

  final String input;

  final String output;

  final String hint;

  final String constraints;

  final String difficulty;

  final String starterCode;

  const ChallengeData({

    required this.title,

    required this.subtitle,

    required this.problem,

    required this.input,

    required this.output,

    required this.hint,

    required this.constraints,

    required this.difficulty,

    required this.starterCode,

  });

  static ChallengeData forLevel(String topic, int level, String title, String subtitle) {

    if (topic.toUpperCase() == 'DSA') {

      switch (level) {

        case 1:

          return const ChallengeData(

            title: 'CODE AWAKENING',

            subtitle: 'Pass the Placement Gate',

            problem: 'A student has scores in three placement rounds. Calculate the total score. The student qualifies for the next round if the total score is 180 or more.',

            input: '70 65 60',

            output: 'Qualified',

            hint: 'Add all three scores and compare the total with 180.',

            constraints: '0 ≤ scores ≤ 100',

            difficulty: 'Easy',

            starterCode: '''class Solution {\n  public static void main(String[] args) {\n    // Write your code here\n  }\n}''',

          );

        case 2:

          return const ChallengeData(

            title: 'ARRAY VAULT', subtitle: 'Find the pair that unlocks the vault',

            problem: 'You are given an array of candidate scores and a target score. Find whether two different scores can combine to reach the target.',

            input: '[2, 7, 11, 15], target = 9', output: '[2, 7]',

            hint: 'For a current value, think about what other value is needed to reach the target.',

            constraints: 'Use different array elements.', difficulty: 'Easy',

            starterCode: '''class Solution {\n  public static void main(String[] args) {\n    // Write your code here\n  }\n}''',

          );

        case 3:

          return const ChallengeData(

            title: 'STRING CIPHER', subtitle: 'Decode the candidate identifier',

            problem: 'A company receives two strings representing candidate IDs. Determine whether the second string can be formed by rearranging the characters of the first.',

            input: 'listen, silent', output: 'True',

            hint: 'Compare how many times each character occurs.', constraints: 'Characters are case-sensitive.', difficulty: 'Easy',

            starterCode: '''class Solution {\n  public static void main(String[] args) {\n    // Write your code here\n  }\n}''',

          );

        case 4:

          return const ChallengeData(

            title: 'SEARCH PROTOCOL', subtitle: 'Locate the correct position',

            problem: 'You are given a sorted list of placement scores. Find the position of a target score efficiently.',

            input: '[10, 20, 30, 40, 50], target = 40', output: 'Index 3',

            hint: 'Look at the middle element first and eliminate half of the search space.', constraints: 'Array is sorted.', difficulty: 'Medium',

            starterCode: '''class Solution {\n  public static void main(String[] args) {\n    // Write your code here\n  }\n}''',

          );

        case 5:

          return const ChallengeData(

            title: 'SORTING ARENA', subtitle: 'Arrange the candidates',

            problem: 'Given a collection of candidate scores, arrange them from the lowest score to the highest score before ranking the candidates.',

            input: '[40, 10, 30, 20]', output: '[10, 20, 30, 40]',

            hint: 'Think about comparing elements and arranging them according to their values.', constraints: 'Return ascending order.', difficulty: 'Medium',

            starterCode: '''class Solution {\n  public static void main(String[] args) {\n    // Write your code here\n  }\n}''',

          );

        case 6:

          return const ChallengeData(

            title: 'LINKED CHAIN', subtitle: 'Repair the candidate chain',

            problem: 'Candidates are stored as nodes connected one after another. You need to move through this chain and locate a particular candidate.',

            input: '10 → 20 → 30 → 40, target = 30', output: 'Found at position 3',

            hint: 'Start at the head and follow the next reference until the value is found.', constraints: 'Traverse from the head.', difficulty: 'Medium',

            starterCode: '''class Solution {\n  public static void main(String[] args) {\n    // Write your code here\n  }\n}''',

          );

        case 7:

          return const ChallengeData(

            title: 'STACK FORTRESS', subtitle: 'Process candidates in order',

            problem: 'A system receives a sequence of operations where the most recently added item must be processed first. Identify the data structure that fits this behavior.',

            input: 'Push A, Push B, Pop', output: 'B',

            hint: 'Think about Last In, First Out.', constraints: 'Newest item is processed first.', difficulty: 'Medium',

            starterCode: '''class Solution {\n  public static void main(String[] args) {\n    // Write your code here\n  }\n}''',

          );

        case 8:

          return const ChallengeData(

            title: 'RECURSION DUNGEON', subtitle: 'Break the problem into smaller quests',

            problem: 'A problem can be solved by repeatedly solving a smaller version of the same problem. Identify the key structure required to make this approach work safely.',

            input: 'factorial(4)', output: '24',

            hint: 'Every recursive approach needs a stopping condition.', constraints: 'Use a valid base case.', difficulty: 'Medium',

            starterCode: '''class Solution {\n  public static void main(String[] args) {\n    // Write your code here\n  }\n}''',

          );

        case 9:

          return const ChallengeData(

            title: 'TREE KINGDOM', subtitle: 'Navigate the hierarchy',

            problem: 'Candidates are organized in a hierarchical structure. You need to understand how to visit nodes according to a specific traversal order.',

            input: 'Root: 4, Left: 2, Right: 6', output: '2, 4, 6',

            hint: 'For sorted output from a BST, think about in-order traversal.', constraints: 'Use the required traversal order.', difficulty: 'Hard',

            starterCode: '''class Solution {\n  public static void main(String[] args) {\n    // Write your code here\n  }\n}''',

          );

        case 10:

          return const ChallengeData(

            title: 'GRAPH BOSS', subtitle: 'Find the safest route',

            problem: 'A placement network contains multiple connected locations. Find an efficient way to explore the network and reason about reaching a destination.',

            input: 'A → B → C, A → D → C', output: 'A path to C exists',

            hint: 'For simple reachability, think about BFS or DFS.', constraints: 'Graph may contain multiple paths.', difficulty: 'Challenge',

            starterCode: '''class Solution {\n  public static void main(String[] args) {\n    // Write your code here\n  }\n}''',

          );

      }

    }

    return ChallengeData(

      title: title.isEmpty ? 'NEW QUEST' : title,

      subtitle: subtitle,

      problem: 'Complete this coding challenge using the concept covered in this level.',

      input: 'Given input',

      output: 'Expected output',

      hint: 'Read the problem carefully, identify the input, then build the solution step by step.',

      constraints: 'Follow the problem requirements.',

      difficulty: 'Easy',

      starterCode: '''class Solution {\n  public static void main(String[] args) {\n    // Write your code here\n  }\n}''',

    );

  }

}