import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'theme_selection_screen.dart';

class AssessmentScreen extends StatefulWidget {
  final String goal;
  final List<String> subjects;

  const AssessmentScreen({
    super.key,
    required this.goal,
    required this.subjects,
  });

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen>
    with TickerProviderStateMixin {
  int currentQuestion = 0;
  int score = 0;

  int? selectedAnswer;
  bool? answerCorrect;
  bool showFeedback = false;

  late AnimationController floatingController;
  late AnimationController particleController;

  final List<Map<String, dynamic>> questions = [
    {
      'question':
          'Which concept allows a class to acquire properties of another class?',
      'options': [
        'Encapsulation',
        'Inheritance',
        'Abstraction',
        'Polymorphism',
      ],
      'answer': 1,
    },
    {
      'question': 'Which data structure follows the LIFO principle?',
      'options': [
        'Queue',
        'Stack',
        'Array',
        'Tree',
      ],
      'answer': 1,
    },
    {
      'question': 'What is the time complexity of Binary Search?',
      'options': [
        'O(n)',
        'O(log n)',
        'O(n²)',
        'O(1)',
      ],
      'answer': 1,
    },
    {
      'question': 'Which SQL command is used to retrieve data?',
      'options': [
        'INSERT',
        'UPDATE',
        'SELECT',
        'DELETE',
      ],
      'answer': 2,
    },
    {
      'question': 'Which protocol is connection-oriented?',
      'options': [
        'UDP',
        'TCP',
        'IP',
        'HTTP',
      ],
      'answer': 1,
    },
  ];

  @override
  void initState() {
    super.initState();

    floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    floatingController.dispose();
    particleController.dispose();
    super.dispose();
  }

  // ======================================================
  // SELECT ANSWER
  // ======================================================

  Future<void> selectAnswer(int index) async {
    if (showFeedback) return;

    final correct = index == questions[currentQuestion]['answer'];

    setState(() {
      selectedAnswer = index;
      answerCorrect = correct;
      showFeedback = true;

      if (correct) {
        score++;
      }
    });

    // Keep the existing feedback delay
    await Future.delayed(
      const Duration(milliseconds: 1100),
    );

    if (!mounted) return;

    // ======================================================
    // MOVE TO NEXT QUESTION
    // ======================================================

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        answerCorrect = null;
        showFeedback = false;
      });

      return;
    }

    // ======================================================
    // QUESTION 5 COMPLETED
    // SAVE COMPLETION TO DATABASE
    // ======================================================

    final completed = await AuthService.completeSkillTest();

    if (!mounted) return;

    // ======================================================
    // IF SAVE FAILED
    // ======================================================

    if (!completed) {
      setState(() {
        selectedAnswer = null;
        answerCorrect = null;
        showFeedback = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save your skill test. Please try again.',
          ),
        ),
      );

      return;
    }

    // ======================================================
    // SKILL TEST COMPLETED
    // GO TO THEME SELECTION
    // ======================================================

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ThemeSelectionScreen(
          topic: _topicName,
        ),
      ),
    );
  }

  // ======================================================
  // TOPIC NAME
  // ======================================================

  String get _topicName {
    if (widget.subjects.isNotEmpty) {
      return widget.subjects.first;
    }

    if (widget.goal.toUpperCase().contains('OOPS')) {
      return 'OOPS';
    }

    if (widget.goal.toUpperCase().contains('DBMS')) {
      return 'DBMS';
    }

    if (widget.goal.toUpperCase().contains('OS')) {
      return 'OS';
    }

    if (widget.goal.toUpperCase().contains('CN')) {
      return 'CN';
    }

    if (widget.goal.toUpperCase().contains('ML')) {
      return 'ML';
    }

    return 'DSA';
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EA),
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackground(),

            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  15,
                  20,
                  25,
                ),
                child: Column(
                  children: [
                    _buildHeader(),

                    const SizedBox(height: 20),

                    _buildQuestionCounter(),

                    const SizedBox(height: 20),

                    _buildQuestionCard(
                      question['question'],
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      '✨  CHOOSE YOUR ANSWER  ✨',
                      style: TextStyle(
                        color: Color(0xFF7B5A32),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),

                    const SizedBox(height: 10),

                    _buildAnswers(question['options']),

                    const SizedBox(height: 15),

                    _buildProgress(),

                    const SizedBox(height: 5),

                    _buildCat(),

                    const SizedBox(height: 10),

                    const Text(
                      'Keep going, coder! 🐾',
                      style: TextStyle(
                        color: Color(0xFF876F54),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (showFeedback) _buildFeedback(),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // BACKGROUND
  // ======================================================

  Widget _buildBackground() {
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
                  Color(0xFFFFE6B7),
                ],
              ),
            ),
          ),

          Positioned(
            top: -100,
            left: -100,
            child: _glow(
              const Color(0xFFFFB52E),
              280,
            ),
          ),

          Positioned(
            bottom: -120,
            right: -100,
            child: _glow(
              const Color(0xFFFF8C21),
              300,
            ),
          ),

          AnimatedBuilder(
            animation: particleController,
            builder: (context, _) {
              return CustomPaint(
                painter: _ParticlePainter(
                  particleController.value,
                ),
                size: Size.infinite,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: .16),
            color.withValues(alpha: .04),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // ======================================================
  // HEADER
  // ======================================================

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: showFeedback
              ? null
              : () => Navigator.pop(context),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .72),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE7A11A),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF70421C),
            ),
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚔️  SKILL QUEST',
                style: TextStyle(
                  color: Color(0xFF653B1D),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Prove your coding skills',
                style: TextStyle(
                  color: Color(0xFF8A735B),
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
                color: Color(0xFFD47B00),
                size: 17,
              ),
              SizedBox(width: 3),
              Text(
                '+20 XP',
                style: TextStyle(
                  color: Color(0xFF9A5C00),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ======================================================
  // QUESTION COUNTER
  // ======================================================

  Widget _buildQuestionCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .75),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: const Color(0xFFE7A11A),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1AE7A11A),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        'QUESTION ${currentQuestion + 1} / ${questions.length}',
        style: const TextStyle(
          color: Color(0xFF75491F),
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // ======================================================
  // QUESTION
  // ======================================================

  Widget _buildQuestionCard(String question) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 28,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .62),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFFFFC35C),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                '🐾  ${_topicName.toUpperCase()} CHALLENGE',
                style: const TextStyle(
                  color: Color(0xFFE18A00),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF653B1D),
                  fontSize: 21,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 9),

              const Text(
                'Think carefully, coder!',
                style: TextStyle(
                  color: Color(0xFF876F54),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // ANSWERS
  // ======================================================

  Widget _buildAnswers(List options) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth > 800;

        if (desktop) {
          return SizedBox(
            height: 410,
            child: Stack(
              children: [
                Positioned(
                  left: 40,
                  top: 70,
                  child: _bubble(
                    0,
                    options[0],
                  ),
                ),

                Positioned(
                  left: constraints.maxWidth * .25,
                  top: 5,
                  child: _bubble(
                    1,
                    options[1],
                  ),
                ),

                Positioned(
                  right: constraints.maxWidth * .25,
                  top: 85,
                  child: _bubble(
                    2,
                    options[2],
                  ),
                ),

                Positioned(
                  right: 35,
                  top: 35,
                  child: _bubble(
                    3,
                    options[3],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: _bubble(
                      0,
                      options[0],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _bubble(
                      1,
                      options[1],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: Center(
                    child: _bubble(
                      2,
                      options[2],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _bubble(
                      3,
                      options[3],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ======================================================
  // ANSWER BUBBLE
  // ======================================================

  Widget _bubble(int index, String text) {
    final correctIndex =
        questions[currentQuestion]['answer'];

    final isSelected = selectedAnswer == index;

    final isCorrect =
        showFeedback && index == correctIndex;

    final isWrong =
        showFeedback &&
        isSelected &&
        answerCorrect == false;

    Color accent = const Color(0xFFFFA726);

    if (isCorrect) {
      accent = const Color(0xFF65A64D);
    }

    if (isWrong) {
      accent = const Color(0xFFE46A5F);
    }

    return AnimatedBuilder(
      animation: floatingController,
      builder: (context, child) {
        final offset =
            math.sin(
                  floatingController.value *
                      math.pi *
                      2 +
                  index,
                ) *
                7;

        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: showFeedback
            ? null
            : () => selectAnswer(index),
        child: SizedBox(
          width: 180,
          height: 180,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 9,
                sigmaY: 9,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(
                        alpha: .82,
                      ),
                      const Color(0xFFFFE9C8)
                          .withValues(alpha: .55),
                      const Color(0xFFFFB74D)
                          .withValues(alpha: .22),
                    ],
                  ),
                  border: Border.all(
                    color: accent.withValues(alpha: .8),
                    width: isSelected ? 3 : 1.7,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(
                        alpha: .25,
                      ),
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 28,
                      top: 20,
                      child: Container(
                        width: 50,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(
                                alpha: .75,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      right: 30,
                      top: 30,
                      child: Container(
                        width: 17,
                        height: 17,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: .55,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white
                                    .withValues(alpha: .55),
                                border: Border.all(
                                  color: accent,
                                  width: 1.4,
                                ),
                              ),
                              child: Center(
                                child: isCorrect
                                    ? const Icon(
                                        Icons.check,
                                        color:
                                            Color(0xFF4E8B3C),
                                      )
                                    : isWrong
                                        ? const Icon(
                                            Icons.close,
                                            color:
                                                Color(0xFFC84F46),
                                          )
                                        : Text(
                                            String.fromCharCode(
                                              65 + index,
                                            ),
                                            style:
                                                TextStyle(
                                              color: accent,
                                              fontWeight:
                                                  FontWeight.w900,
                                              fontSize: 17,
                                            ),
                                          ),
                              ),
                            ),

                            const SizedBox(height: 9),

                            Text(
                              text,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF653B1D),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ======================================================
  // PROGRESS
  // ======================================================

  Widget _buildProgress() {
    final progress =
        (currentQuestion + 1) / questions.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFCF7B),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'QUEST PROGRESS',
                style: TextStyle(
                  color: Color(0xFF876F54),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),

              Text(
                '${currentQuestion + 1} / ${questions.length}',
                style: const TextStyle(
                  color: Color(0xFFD77A00),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  const Color(0xFFFFE3B3),
              valueColor:
                  const AlwaysStoppedAnimation(
                Color(0xFFFFA726),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // CAT
  // ======================================================

  Widget _buildCat() {
    return SizedBox(
      height: 150,
      child: Image.asset(
        'assets/images/cat1.png',
        fit: BoxFit.contain,
      ),
    );
  }

  // ======================================================
  // FEEDBACK
  // ======================================================

  Widget _buildFeedback() {
    final correct = answerCorrect == true;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: .14),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10,
                sigmaY: 10,
              ),
              child: Container(
                width: 290,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: .88,
                  ),
                  borderRadius:
                      BorderRadius.circular(30),
                  border: Border.all(
                    color: correct
                        ? const Color(0xFF75A957)
                        : const Color(0xFFE46A5F),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      correct ? '🎉' : '🐾',
                      style: const TextStyle(
                        fontSize: 42,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      correct
                          ? 'CORRECT!'
                          : 'NOT QUITE!',
                      style: TextStyle(
                        color: correct
                            ? const Color(0xFF5B923F)
                            : const Color(0xFFC64F46),
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      correct
                          ? '+20 XP'
                          : 'Keep learning, coder!',
                      style: const TextStyle(
                        color: Color(0xFF876F54),
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      currentQuestion ==
                              questions.length - 1
                          ? 'Preparing your skill analysis...'
                          : 'Loading next challenge...',
                      style: const TextStyle(
                        color: Color(0xFF9A8975),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// PARTICLES
// ================================================================

class _ParticlePainter extends CustomPainter {
  final double animation;

  _ParticlePainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(22);

    for (int i = 0; i < 55; i++) {
      final x = random.nextDouble() * size.width;

      final baseY =
          random.nextDouble() * size.height;

      final y =
          (baseY -
                  animation *
                      size.height *
                      .08) %
              size.height;

      final radius =
          random.nextDouble() * 1.4 + .4;

      final paint = Paint()
        ..color = const Color(
          0xFFD8891A,
        ).withValues(
          alpha: random.nextDouble() * .18 + .04,
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
    covariant _ParticlePainter oldDelegate,
  ) {
    return oldDelegate.animation != animation;
  }
}