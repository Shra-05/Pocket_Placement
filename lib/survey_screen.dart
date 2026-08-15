import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'assessment_screen.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  String? goal;
  String? selectedCoreSubject;

  final List<String> coreSubjects = [
    'OOPS',
    'DBMS',
    'Operating Systems',
    'Computer Networks',
    'Machine Learning',
  ];

  void continueSurvey() {
    if (goal == null) {
      _showMessage('Choose your coding world first! 🚀');
      return;
    }

    if (goal == 'CORE_CS' && selectedCoreSubject == null) {
      _showCoreSubjectDialog();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssessmentScreen(
          goal: goal!,
          subjects: goal == 'DSA'
              ? ['DSA']
              : [selectedCoreSubject!],
        ),
      ),
    );
  }

  void selectDSA() {
    setState(() {
      goal = 'DSA';
      selectedCoreSubject = null;
    });

    continueSurvey();
  }

  void selectCoreCS() {
    setState(() {
      goal = 'CORE_CS';
    });

    _showCoreSubjectDialog();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF17172B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  void _showCoreSubjectDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10152A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      '🧠 CHOOSE YOUR CORE QUEST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Choose one subject to begin your adventure.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .6),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 20),

                    ...coreSubjects.map(
                      (subject) {
                        final selected =
                            selectedCoreSubject == subject;

                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              selectedCoreSubject = subject;
                            });

                            setState(() {});
                          },
                          child: Container(
                            width: double.infinity,
                            margin:
                                const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFFFA62B)
                                      .withValues(alpha: .13)
                                  : Colors.white
                                      .withValues(alpha: .035),
                              borderRadius:
                                  BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFFFFA62B)
                                    : Colors.white12,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _subjectEmoji(subject),
                                  style: const TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Text(
                                    subject,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Icon(
                                  selected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: selected
                                      ? const Color(0xFFFFA62B)
                                      : Colors.white30,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed:
                            selectedCoreSubject == null
                                ? null
                                : () {
                                    Navigator.pop(
                                      sheetContext,
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AssessmentScreen(
                                          goal: 'CORE_CS',
                                          subjects: [
                                            selectedCoreSubject!
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFFFA62B),
                          foregroundColor: Colors.black,
                          disabledBackgroundColor:
                              Colors.white10,
                          disabledForegroundColor:
                              Colors.white30,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'ENTER CORE CS WORLD →',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _subjectEmoji(String subject) {
    switch (subject) {
      case 'OOPS':
        return '🧩';
      case 'DBMS':
        return '🗄️';
      case 'Operating Systems':
        return '⚙️';
      case 'Computer Networks':
        return '🌐';
      case 'Machine Learning':
        return '🤖';
      default:
        return '📚';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 900;

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _AdventureBackgroundPainter(),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: desktop ? 45 : 18,
                      vertical: 18,
                    ),
                    child: Column(
                      children: [
                        _buildTopBar(),
                        SizedBox(height: desktop ? 12 : 20),
                        _buildHero(),
                        const SizedBox(height: 25),
                        _buildWorlds(desktop),
                        const SizedBox(height: 20),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .22),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFB85CFF),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x553F00FF),
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),

        const Spacer(),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF11152A)
                .withValues(alpha: .85),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFB85CFF),
            ),
          ),
          child: const Row(
            children: [
              Text(
                '🎮',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(width: 7),
              Text(
                'CODING ADVENTURE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _floatingCharacter(
              '🤖',
              const Color(0xFF00D9FF),
              48,
            ),

            const SizedBox(width: 10),

            _mainCharacter(),

            const SizedBox(width: 10),

            _floatingCharacter(
              '🐉',
              const Color(0xFF43E47A),
              48,
            ),
          ],
        ),

        const SizedBox(height: 8),

        const Text(
          'HEY CODER! 👋',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 8),

        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFFB65CFF),
                Color(0xFF00D9FF),
                Color(0xFFFFB52E),
              ],
            ).createShader(bounds);
          },
          child: const Text(
            'CHOOSE YOUR PATH',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        const SizedBox(height: 7),

        Text(
          'Two amazing worlds. One epic journey.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .82),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _mainCharacter() {
    return Container(
      width: 78,
      height: 78,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF7D4CFF)
            .withValues(alpha: .18),
        border: Border.all(
          color: const Color(0xFFB55CFF),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x664F00FF),
            blurRadius: 28,
            spreadRadius: 3,
          ),
        ],
      ),
      child: const Text(
        '🧑‍💻',
        style: TextStyle(fontSize: 45),
      ),
    );
  }

  Widget _floatingCharacter(
    String emoji,
    Color color,
    double size,
  ) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: .13),
        border: Border.all(
          color: color.withValues(alpha: .55),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .25),
            blurRadius: 20,
          ),
        ],
      ),
      child: Text(
        emoji,
        style: TextStyle(
          fontSize: size * .52,
        ),
      ),
    );
  }

  Widget _buildWorlds(bool desktop) {
    if (desktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildDSAWorld(),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: _buildCoreWorld(),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildDSAWorld(),
        const SizedBox(height: 25),
        _buildCoreWorld(),
      ],
    );
  }

  Widget _buildDSAWorld() {
    return _worldContainer(
      color: const Color(0xFF8C43FF),
      glow: const Color(0xFF7C25FF),
      title: 'DSA WORLD',
      subtitle:
          'Sharpen your problem solving skills\n'
          'and become unstoppable.',
      icon: Icons.code,
      worldArt: const _CyberCityArt(),
      buttonText: 'ENTER DSA WORLD',
      selected: goal == 'DSA',
      badge: '★  MAIN ADVENTURE',
      onTap: selectDSA,
    );
  }

  Widget _buildCoreWorld() {
    return _worldContainer(
      color: const Color(0xFFFFA62B),
      glow: const Color(0xFFFF8A00),
      title: 'CORE CS WORLD',
      subtitle:
          'Explore core computer science subjects\n'
          'and build strong foundations.',
      icon: Icons.psychology,
      worldArt: const _KingdomArt(),
      buttonText: 'EXPLORE CORE CS',
      selected: goal == 'CORE_CS',
      badge: null,
      onTap: selectCoreCS,
    );
  }

  Widget _worldContainer({
    required Color color,
    required Color glow,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget worldArt,
    required String buttonText,
    required bool selected,
    required String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        constraints: const BoxConstraints(
          minHeight: 455,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF091126)
              .withValues(alpha: .90),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: .55),
            width: selected ? 3 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: glow.withValues(
                alpha: selected ? .42 : .20,
              ),
              blurRadius: selected ? 35 : 24,
              spreadRadius: selected ? 3 : 0,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            SizedBox(
              height: 245,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: worldArt,
                  ),

                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0xCC091126),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (badge != null)
                    Positioned(
                      top: 14,
                      left: 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF211337),
                          borderRadius:
                              BorderRadius.circular(20),
                          border: Border.all(
                            color: color,
                          ),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    bottom: 15,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF081022),
                          border: Border.all(
                            color: color,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: glow.withValues(alpha: .5),
                              blurRadius: 25,
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                22,
                10,
                22,
                22,
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .6,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .72),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _worldFeatures(
                    color: color,
                    dsa: title == 'DSA WORLD',
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        elevation: 10,
                        shadowColor:
                            color.withValues(alpha: .5),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.arrow_forward,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _worldFeatures({
    required Color color,
    required bool dsa,
  }) {
    final icons = dsa
        ? [
            Icons.lightbulb_outline,
            Icons.code,
            Icons.bar_chart,
            Icons.emoji_events,
          ]
        : [
            Icons.storage,
            Icons.settings,
            Icons.account_tree,
            Icons.smart_toy,
          ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: icons.map(
        (icon) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: .4),
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 19,
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildFooter() {
    return Text(
      '✨  Let’s make coding fun! 💜  ✨',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withValues(alpha: .9),
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _AdventureBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    final sky = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF1764D7),
        const Color(0xFF6CAAE8),
        const Color(0xFFB9E4FF),
      ],
    );

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = sky.createShader(
          Offset.zero & size,
        ),
    );

    // Soft clouds
    _cloud(
      canvas,
      Offset(size.width * .08, size.height * .18),
      95,
    );

    _cloud(
      canvas,
      Offset(size.width * .50, size.height * .28),
      80,
    );

    _cloud(
      canvas,
      Offset(size.width * .88, size.height * .18),
      105,
    );

    // Stars / particles
    final random = math.Random(8);

    paint.color = Colors.white.withValues(alpha: .65);

    for (int i = 0; i < 45; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * .72;

      canvas.drawCircle(
        Offset(x, y),
        random.nextDouble() * 1.8 + .4,
        paint,
      );
    }

    // Floating islands
    _floatingIsland(
      canvas,
      Offset(size.width * .16, size.height * .48),
      145,
      const Color(0xFF20204A),
    );

    _floatingIsland(
      canvas,
      Offset(size.width * .83, size.height * .48),
      150,
      const Color(0xFF365A32),
    );

    _floatingIsland(
      canvas,
      Offset(size.width * .50, size.height * .75),
      75,
      const Color(0xFF334B42),
    );

    // Cyber city
    _drawCyberCity(
      canvas,
      Offset(size.width * .13, size.height * .39),
    );

    // Castle
    _drawCastle(
      canvas,
      Offset(size.width * .79, size.height * .36),
    );
  }

  void _cloud(
    Canvas canvas,
    Offset center,
    double radius,
  ) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .45);

    canvas.drawCircle(
      center,
      radius,
      paint,
    );

    canvas.drawCircle(
      center.translate(radius * .8, radius * .15),
      radius * .7,
      paint,
    );

    canvas.drawCircle(
      center.translate(-radius * .8, radius * .15),
      radius * .65,
      paint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, radius * .25),
        width: radius * 3,
        height: radius * 1.2,
      ),
      paint,
    );
  }

  void _floatingIsland(
    Canvas canvas,
    Offset center,
    double width,
    Color color,
  ) {
    final paint = Paint()..color = color;

    final path = Path();

    path.moveTo(
      center.dx - width / 2,
      center.dy,
    );

    path.lineTo(
      center.dx + width / 2,
      center.dy,
    );

    path.lineTo(
      center.dx + width * .22,
      center.dy + width * .45,
    );

    path.lineTo(
      center.dx,
      center.dy + width * .62,
    );

    path.lineTo(
      center.dx - width * .25,
      center.dy + width * .43,
    );

    path.close();

    canvas.drawPath(path, paint);

    final top = Paint()
      ..color = Colors.white.withValues(alpha: .13);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy - 3,
        ),
        width: width,
        height: width * .25,
      ),
      top,
    );
  }

  void _drawCyberCity(
    Canvas canvas,
    Offset base,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final buildings = [
      [0.0, 85.0],
      [35.0, 130.0],
      [70.0, 100.0],
      [105.0, 155.0],
      [145.0, 110.0],
    ];

    for (final building in buildings) {
      final x = base.dx + building[0];
      final height = building[1];

      paint.color = const Color(0xFF16113B);

      canvas.drawRect(
        Rect.fromLTWH(
          x,
          base.dy - height,
          30,
          height,
        ),
        paint,
      );

      paint.color = const Color(0xFF4E35D8);

      canvas.drawRect(
        Rect.fromLTWH(
          x + 7,
          base.dy - height + 15,
          5,
          8,
        ),
        paint,
      );

      paint.color = const Color(0xFF00D9FF);

      canvas.drawRect(
        Rect.fromLTWH(
          x + 18,
          base.dy - height + 15,
          5,
          8,
        ),
        paint,
      );
    }

    // Neon sword
    final swordPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      base.translate(62, -180),
      base.translate(108, -225),
      swordPaint,
    );

    canvas.drawLine(
      base.translate(52, -190),
      base.translate(73, -169),
      swordPaint,
    );
  }

  void _drawCastle(
    Canvas canvas,
    Offset base,
  ) {
    final stone = Paint()
      ..color = const Color(0xFFFFE4A8);

    final roof = Paint()
      ..color = const Color(0xFF38528B);

    // Main castle
    canvas.drawRect(
      Rect.fromCenter(
        center: base.translate(0, -90),
        width: 100,
        height: 130,
      ),
      stone,
    );

    // Towers
    for (final dx in [-55.0, 55.0]) {
      canvas.drawRect(
        Rect.fromCenter(
          center: base.translate(dx, -100),
          width: 38,
          height: 150,
        ),
        stone,
      );

      final path = Path();

      path.moveTo(
        base.dx + dx - 23,
        base.dy - 175,
      );

      path.lineTo(
        base.dx + dx,
        base.dy - 215,
      );

      path.lineTo(
        base.dx + dx + 23,
        base.dy - 175,
      );

      path.close();

      canvas.drawPath(path, roof);
    }

    // Central roof
    final centerRoof = Path();

    centerRoof.moveTo(
      base.dx - 50,
      base.dy - 150,
    );

    centerRoof.lineTo(
      base.dx,
      base.dy - 205,
    );

    centerRoof.lineTo(
      base.dx + 50,
      base.dy - 150,
    );

    centerRoof.close();

    canvas.drawPath(
      centerRoof,
      roof,
    );

    // Book
    final bookPaint = Paint()
      ..color = const Color(0xFFFFF1C7);

    canvas.drawRect(
      Rect.fromCenter(
        center: base.translate(0, -20),
        width: 70,
        height: 48,
      ),
      bookPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

class _CyberCityArt extends StatelessWidget {
  const _CyberCityArt();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MiniCyberPainter(),
    );
  }
}

class _KingdomArt extends StatelessWidget {
  const _KingdomArt();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MiniKingdomPainter(),
    );
  }
}

class _MiniCyberPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.color = const Color(0xFF121C48);

    for (int i = 0; i < 7; i++) {
      final x = 20.0 + i * 55;

      final height =
          70.0 + (i % 3) * 35;

      canvas.drawRect(
        Rect.fromLTWH(
          x,
          size.height - height - 20,
          40,
          height,
        ),
        paint,
      );

      paint.color = const Color(0xFF5B3FFF);

      canvas.drawRect(
        Rect.fromLTWH(
          x + 8,
          size.height - height,
          7,
          10,
        ),
        paint,
      );

      paint.color = const Color(0xFF00D9FF);
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

class _MiniKingdomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stone = Paint()
      ..color = const Color(0xFFB9A36D);

    final roof = Paint()
      ..color = const Color(0xFF304B82);

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .28,
        size.height * .38,
        size.width * .44,
        size.height * .52,
      ),
      stone,
    );

    for (final dx in [
      size.width * .18,
      size.width * .72,
    ]) {
      canvas.drawRect(
        Rect.fromLTWH(
          dx,
          size.height * .25,
          size.width * .16,
          size.height * .65,
        ),
        stone,
      );

      final roofPath = Path();

      roofPath.moveTo(
        dx - 5,
        size.height * .25,
      );

      roofPath.lineTo(
        dx + size.width * .08,
        size.height * .02,
      );

      roofPath.lineTo(
        dx + size.width * .21,
        size.height * .25,
      );

      roofPath.close();

      canvas.drawPath(
        roofPath,
        roof,
      );
    }

    final centerRoof = Path();

    centerRoof.moveTo(
      size.width * .24,
      size.height * .38,
    );

    centerRoof.lineTo(
      size.width * .50,
      size.height * .05,
    );

    centerRoof.lineTo(
      size.width * .76,
      size.height * .38,
    );

    centerRoof.close();

    canvas.drawPath(
      centerRoof,
      roof,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}