import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'theme_selection_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String topic;

  const AnalyticsScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.topic,
  });

  double get percentage {
    if (totalQuestions == 0) {
      return 0;
    }

    return score / totalQuestions;
  }

  String get skillLevel {
    final percent = percentage * 100;

    if (percent <= 40) {
      return 'BEGINNER';
    }

    if (percent < 100) {
      return 'INTERMEDIATE';
    }

    return 'ADVANCED';
  }

  String get skillEmoji {
    switch (skillLevel) {
      case 'ADVANCED':
        return '🔥';
      case 'INTERMEDIATE':
        return '⚡';
      default:
        return '🌱';
    }
  }

  String get message {
    switch (skillLevel) {
      case 'ADVANCED':
        return 'Excellent! You are ready for challenging levels.';
      case 'INTERMEDIATE':
        return 'Great progress! Let’s strengthen your skills.';
      default:
        return 'Everyone starts somewhere. Let’s build your foundation!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EA),
      body: SafeArea(
        child: Stack(
          children: [
            _background(),

            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                15,
                20,
                30,
              ),
              child: Column(
                children: [
                  _header(),

                  const SizedBox(height: 24),

                  const Text(
                    'YOUR QUEST IS COMPLETE! 🎉',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF653B1D),
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    'Here is your current skill level in $topic.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF876F54),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 25),

                  _scoreCard(),

                  const SizedBox(height: 20),

                  _levelCard(),

                  const SizedBox(height: 24),

                  _performance(),

                  const SizedBox(height: 20),

                  _questComplete(),

                  const SizedBox(height: 25),

                  _continueButton(context),

                  const SizedBox(height: 12),

                  const Text(
                    '✨ Your coding journey continues...',
                    style: TextStyle(
                      color: Color(0xFF876F54),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  // ------------------------------------------------------------
  // BACKGROUND
  // ------------------------------------------------------------

  Widget _background() {
    return Positioned.fill(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFBF2),
                  Color(0xFFFFF1D7),
                  Color(0xFFFFE5B4),
                ],
              ),
            ),
          ),

          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFB52E)
                        .withValues(alpha: .16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -120,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF8C21)
                        .withValues(alpha: .14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          CustomPaint(
            painter: _AnalyticsParticles(),
            size: Size.infinite,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .75),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE5A01B),
              width: 1.5,
            ),
          ),
          child: const Center(
            child: Text(
              '📊',
              style: TextStyle(fontSize: 21),
            ),
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'SKILL ANALYSIS',
                style: TextStyle(
                  color: Color(0xFF653B1D),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Your quest results are ready!',
                style: TextStyle(
                  color: Color(0xFF876F54),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0C9),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: const Color(0xFFE6A11B),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.bolt,
                color: Color(0xFFD77A00),
                size: 17,
              ),
              SizedBox(width: 3),
              Text(
                'XP',
                style: TextStyle(
                  color: Color(0xFF9A5C00),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // SCORE CARD
  // ------------------------------------------------------------

  Widget _scoreCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 25,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .62),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0xFFFFBF4F),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              const Text(
                'SKILL SCORE',
                style: TextStyle(
                  color: Color(0xFF876F54),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: percentage,
                        strokeWidth: 12,
                        backgroundColor:
                            const Color(0xFFFFE4B5),
                        valueColor:
                            const AlwaysStoppedAnimation(
                          Color(0xFFFF9F1C),
                        ),
                      ),
                    ),

                    Container(
                      width: 142,
                      height: 142,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white
                            .withValues(alpha: .78),
                        border: Border.all(
                          color: const Color(0xFFFFCA66),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            '$score / $totalQuestions',
                            style: const TextStyle(
                              color: Color(0xFF653B1D),
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            '${(percentage * 100).round()}%',
                            style: const TextStyle(
                              color: Color(0xFFD67A00),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'ACCURACY',
                style: TextStyle(
                  color: Color(0xFF876F54),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // LEVEL CARD + CAT2
  // ------------------------------------------------------------

  Widget _levelCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        15,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFA726),
            Color(0xFFFF8C18),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x35FF9800),
            blurRadius: 22,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 175,
            child: Image.asset(
              'assets/images/cat2.png',
              fit: BoxFit.contain,
            ),
          ),

          Text(
            skillEmoji,
            style: const TextStyle(
              fontSize: 27,
            ),
          ),

          const SizedBox(height: 3),

          const Text(
            'YOUR CURRENT LEVEL',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            skillLevel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PERFORMANCE
  // ------------------------------------------------------------

  Widget _performance() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              '📈',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(width: 8),
            Text(
              'PERFORMANCE OVERVIEW',
              style: TextStyle(
                color: Color(0xFF653B1D),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        _performanceItem(
          '💡',
          'Concept Knowledge',
        ),

        const SizedBox(height: 11),

        _performanceItem(
          '🧩',
          'Problem Solving',
        ),

        const SizedBox(height: 11),

        _performanceItem(
          '🎓',
          'Fundamentals',
        ),
      ],
    );
  }

  Widget _performanceItem(
    String icon,
    String title,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .68),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD28A),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 23),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF653B1D),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              Text(
                '${(percentage * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xFFD67A00),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor:
                  const Color(0xFFFFE6C0),
              valueColor:
                  const AlwaysStoppedAnimation(
                Color(0xFFFFA21A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // QUEST COMPLETE
  // ------------------------------------------------------------

  Widget _questComplete() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1D0),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: const Color(0xFFFFC34D),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD76D),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🏆',
                style: TextStyle(fontSize: 25),
              ),
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'QUEST COMPLETE',
                  style: TextStyle(
                    color: Color(0xFF9B5C00),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'You completed all 5 questions!',
                  style: TextStyle(
                    color: Color(0xFF74563B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '+${score * 20} XP',
            style: const TextStyle(
              color: Color(0xFFD27300),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BUTTON
  // ------------------------------------------------------------

  Widget _continueButton(
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ThemeSelectionScreen(
                topic: topic,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9818),
          foregroundColor: Colors.white,
          elevation: 5,
          shadowColor:
              const Color(0x45FF8C00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Text(
              'CHOOSE YOUR THEME',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(width: 9),
            Icon(
              Icons.arrow_forward_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// PARTICLES
// ================================================================

class _AnalyticsParticles
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final random = math.Random(31);

    for (int i = 0; i < 50; i++) {
      final x =
          random.nextDouble() * size.width;

      final y =
          random.nextDouble() * size.height;

      final radius =
          random.nextDouble() * 1.5 + .4;

      final paint = Paint()
        ..color = const Color(0xFFE49A21)
            .withValues(
          alpha:
              random.nextDouble() * .16 + .04,
        );

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}