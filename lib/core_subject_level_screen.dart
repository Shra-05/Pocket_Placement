import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_selection_screen.dart';


// ============================================================
// CORE QUESTION MODEL
// ============================================================

class CoreLearningQuestion {
  final String title;
  final String concept;

  // Core CS is MCQ based.
  final String type;

  final String question;
  final List<String> options;
  final int correctOption;

  // Kept for compatibility with your existing question files.
  final String code;
  final List<String> answers;

  final String explanation;

  // Animation data
  final String animationTitle;
  final List<String> animationSteps;

  const CoreLearningQuestion({
    required this.title,
    required this.concept,
    required this.type,
    required this.question,

    this.options = const [],
    this.correctOption = -1,

    this.code = '',
    this.answers = const [],

    required this.explanation,

    required this.animationTitle,
    required this.animationSteps,
  });
}


// ============================================================
// THEME COLORS
// ============================================================

class CoreTheme {
  final Color background;
  final Color panel;
  final Color card;

  final Color accent;
  final Color secondary;

  final Color text;
  final Color muted;

  final Color selected;
  final Color border;

  const CoreTheme({
    required this.background,
    required this.panel,
    required this.card,
    required this.accent,
    required this.secondary,
    required this.text,
    required this.muted,
    required this.selected,
    required this.border,
  });

  factory CoreTheme.fromTheme(AppTheme theme) {
    switch (theme) {

      // --------------------------------------------------------
      // FOREST
      // --------------------------------------------------------

      case AppTheme.forest:
        return const CoreTheme(
          background: Color(0xFF061713),
          panel: Color(0xFF0D241B),
          card: Color(0xFF112D22),

          accent: Color(0xFF55F5D9),
          secondary: Color(0xFFFFD166),

          text: Color(0xFFF3FFF9),
          muted: Color(0xFF9CB5AD),

          selected: Color(0xFF155342),
          border: Color(0xFF285A4C),
        );

      // --------------------------------------------------------
      // CYBERPUNK
      // --------------------------------------------------------

      case AppTheme.cyberpunk:
        return const CoreTheme(
          background: Color(0xFF080313),
          panel: Color(0xFF15102B),
          card: Color(0xFF1D1538),

          accent: Color(0xFF00E5FF),
          secondary: Color(0xFFFF4FD8),

          text: Color(0xFFF5F3FF),
          muted: Color(0xFFA9A2C5),

          selected: Color(0xFF33205B),
          border: Color(0xFF604AA0),
        );

      // --------------------------------------------------------
      // KINGDOM
      // --------------------------------------------------------

      case AppTheme.kingdom:
        return const CoreTheme(
          background: Color(0xFF170B06),
          panel: Color(0xFF2B180C),
          card: Color(0xFF38200E),

          accent: Color(0xFFFFD166),
          secondary: Color(0xFFFF8C42),

          text: Color(0xFFFFF8E7),
          muted: Color(0xFFC9B49A),

          selected: Color(0xFF5A3516),
          border: Color(0xFF79502A),
        );
    }
  }
}


// ============================================================
// CORE SUBJECT LEVEL SCREEN
// ============================================================

class CoreSubjectLevelScreen extends StatefulWidget {
  final AppTheme theme;

  final int level;

  final String subject;

  final String title;

  final String subtitle;

  final Color accentColor;

  final List<CoreLearningQuestion> questions;

  final String nextTitle;

  const CoreSubjectLevelScreen({
    super.key,

    required this.theme,
    required this.level,
    required this.subject,

    required this.title,
    required this.subtitle,

    required this.accentColor,

    required this.questions,

    required this.nextTitle,
  });

  @override
  State<CoreSubjectLevelScreen> createState() =>
      _CoreSubjectLevelScreenState();
}


// ============================================================
// STATE
// ============================================================

class _CoreSubjectLevelScreenState
    extends State<CoreSubjectLevelScreen> {

  late CoreTheme colors;

  int currentQuestion = 0;

  int? selectedAnswer;

  int score = 0;

  bool submitted = false;

  bool completed = false;

  // Animation
  bool animationPlaying = true;

  int animationStep = 0;

  Timer? animationTimer;


  // ----------------------------------------------------------
  // CURRENT QUESTION
  // ----------------------------------------------------------

  CoreLearningQuestion get question {
    if (widget.questions.isEmpty) {
      return const CoreLearningQuestion(
        title: 'Core CS',
        concept: 'Core CS',
        type: 'mcq',
        question: 'No question available.',
        options: [],
        correctOption: -1,
        explanation: 'No question data is available.',
        animationTitle: 'Concept Animation',
        animationSteps: ['No animation'],
      );
    }

    return widget.questions[currentQuestion];
  }


  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    colors = CoreTheme.fromTheme(widget.theme);

    _startAnimation();
  }


  // ==========================================================
  // ANIMATION
  // ==========================================================

  void _startAnimation() {
    animationTimer?.cancel();

    animationTimer = Timer.periodic(
      const Duration(milliseconds: 1200),
      (_) {
        if (!mounted || !animationPlaying) return;

        if (question.animationSteps.isEmpty) return;

        setState(() {
          animationStep++;

          if (animationStep >=
              question.animationSteps.length) {
            animationStep = 0;
          }
        });
      },
    );
  }


  void _toggleAnimation() {
    setState(() {
      animationPlaying = !animationPlaying;
    });
  }


  void _resetAnimation() {
    setState(() {
      animationStep = 0;
    });
  }


  @override
  void dispose() {
    animationTimer?.cancel();

    super.dispose();
  }


  // ==========================================================
  // ANSWER SELECTION
  // ==========================================================

  void _selectAnswer(int index) {
    if (submitted) return;

    setState(() {
      selectedAnswer = index;
    });
  }


  // ==========================================================
  // SUBMIT ANSWER
  // ==========================================================

  void _submitAnswer() {
    if (selectedAnswer == null) return;

    if (submitted) return;

    final correct =
        selectedAnswer == question.correctOption;

    setState(() {
      submitted = true;

      if (correct) {
        score++;
      }
    });

    if (currentQuestion ==
        widget.questions.length - 1) {

      setState(() {
        completed = true;
      });

      _saveCompletion();
    }
  }


  // ==========================================================
  // NEXT QUESTION
  // ==========================================================

  void _nextQuestion() {
    if (!submitted) return;

    if (currentQuestion >=
        widget.questions.length - 1) {
      return;
    }

    setState(() {
      currentQuestion++;

      selectedAnswer = null;

      submitted = false;

      animationStep = 0;
    });
  }


  // ==========================================================
  // PREVIOUS QUESTION
  // ==========================================================

  void _previousQuestion() {
    if (currentQuestion == 0) return;

    setState(() {
      currentQuestion--;

      selectedAnswer = null;

      submitted = false;

      animationStep = 0;
    });
  }


  // ==========================================================
  // RESTART CURRENT QUESTION
  // ==========================================================

  void _restartQuestion() {
    setState(() {
      selectedAnswer = null;

      submitted = false;

      animationStep = 0;
    });
  }


  // ==========================================================
  // SAVE COMPLETION
  // ==========================================================

  Future<void> _saveCompletion() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final key =
          'completed_levels_${widget.subject.toUpperCase()}';

      final completedLevels =
          prefs.getStringList(key) ?? <String>[];

      final value = '${widget.level}';

      if (!completedLevels.contains(value)) {
        completedLevels.add(value);

        await prefs.setStringList(
          key,
          completedLevels,
        );
      }
    } catch (_) {}
  }


  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {

    final totalQuestions =
        widget.questions.length;

    final progress = totalQuestions == 0
        ? 0.0
        : (currentQuestion + 1) /
            totalQuestions;

    return Scaffold(
      backgroundColor: colors.background,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {

            final wide =
                constraints.maxWidth >= 1100;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),

              child: Column(
                children: [

                  // TOP BAR
                  _buildTopBar(),

                  const SizedBox(height: 18),

                  // PROGRESS
                  _buildProgress(progress),

                  const SizedBox(height: 18),

                  // MAIN CONTENT
                  if (wide)
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        // LEFT
                        Expanded(
                          flex: 4,
                          child: _buildLevelInfo(),
                        ),

                        const SizedBox(width: 18),

                        // RIGHT
                        Expanded(
                          flex: 6,
                          child: _buildQuizArea(),
                        ),
                      ],
                    )

                  else
                    Column(
                      children: [

                        _buildLevelInfo(),

                        const SizedBox(height: 18),

                        _buildQuizArea(),
                      ],
                    ),

                  const SizedBox(height: 18),

                  _buildBottomNavigation(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }


  // ==========================================================
  // TOP BAR
  // ==========================================================

  Widget _buildTopBar() {

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),

      decoration: BoxDecoration(
        color: colors.panel,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: colors.border,
        ),
      ),

      child: Row(
        children: [

          // BACK
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },

            icon: const Icon(
              Icons.arrow_back_rounded,
            ),

            color: colors.accent,
          ),

          const SizedBox(width: 8),

          // LOGO
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color: colors.accent
                  .withOpacity(.12),

              borderRadius:
                  BorderRadius.circular(13),

              border: Border.all(
                color: colors.accent
                    .withOpacity(.35),
              ),
            ),

            child: Icon(
              Icons.menu_book_rounded,
              color: colors.accent,
            ),
          ),

          const SizedBox(width: 12),

          // TITLE
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  'POCKET PLACEMENT',
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                Text(
                  '${widget.subject.toUpperCase()} • CORE SUBJECT',
                  style: TextStyle(
                    color: colors.accent,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // STREAK
          _topStat(
            Icons.local_fire_department_rounded,
            '7',
            'STREAK',
          ),

          const SizedBox(width: 10),

          // XP
          _topStat(
            Icons.star_rounded,
            '${score * 50}',
            'XP',
          ),
        ],
      ),
    );
  }


  Widget _topStat(
    IconData icon,
    String value,
    String label,
  ) {

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: colors.card,
        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Row(
        children: [

          Icon(
            icon,
            color: colors.secondary,
            size: 20,
          ),

          const SizedBox(width: 6),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                value,
                style: TextStyle(
                  color: colors.text,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              Text(
                label,
                style: TextStyle(
                  color: colors.muted,
                  fontSize: 8,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // ==========================================================
  // PROGRESS
  // ==========================================================

  Widget _buildProgress(double progress) {

    return Column(
      children: [

        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

          children: [

            Text(
              'QUESTION ${currentQuestion + 1}/${widget.questions.length}',
              style: TextStyle(
                color: colors.muted,
                fontSize: 11,
                fontWeight:
                    FontWeight.w900,
                letterSpacing: 1,
              ),
            ),

            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                color: colors.accent,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius:
              BorderRadius.circular(10),

          child: LinearProgressIndicator(
            value: progress,

            minHeight: 8,

            backgroundColor:
                Colors.white.withOpacity(.08),

            valueColor:
                AlwaysStoppedAnimation(
              colors.accent,
            ),
          ),
        ),
      ],
    );
  }


  // ==========================================================
  // LEVEL INFORMATION
  // ==========================================================

  Widget _buildLevelInfo() {

    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: colors.card,

        borderRadius:
            BorderRadius.circular(24),

        border: Border.all(
          color: colors.border,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // LEVEL BADGE
          Row(
            children: [

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: colors.secondary
                      .withOpacity(.18),

                  borderRadius:
                      BorderRadius.circular(12),

                  border: Border.all(
                    color: colors.secondary
                        .withOpacity(.5),
                  ),
                ),

                child: Text(
                  'LEVEL ${widget.level}',
                  style: TextStyle(
                    color: colors.secondary,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),

              const Spacer(),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),

                decoration: BoxDecoration(
                  color: colors.accent
                      .withOpacity(.12),

                  borderRadius:
                      BorderRadius.circular(20),

                  border: Border.all(
                    color: colors.accent
                        .withOpacity(.3),
                  ),
                ),

                child: Text(
                  'MCQ',
                  style: TextStyle(
                    color: colors.accent,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // TITLE
          Text(
            widget.title,
            style: TextStyle(
              color: colors.text,
              fontSize: 25,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Test your understanding with '
            '${widget.questions.length} MCQs. '
            'Choose the correct answer and earn XP.',
            style: TextStyle(
              color: colors.muted,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 22),

          // TOPICS
          _infoCard(
            icon: Icons.menu_book_rounded,
            title: 'TOPICS COVERED',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [

                _topicChip(
                  widget.subtitle,
                ),

                _topicChip(
                  question.concept,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // REWARDS
          _infoCard(
            icon: Icons.card_giftcard_rounded,
            title: 'REWARDS',
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,

              children: [

                _reward(
                  Icons.star_rounded,
                  '+50 XP',
                ),

                _reward(
                  Icons.local_fire_department_rounded,
                  '+1 Streak',
                ),

                _reward(
                  Icons.lock_open_rounded,
                  'Next Level',
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // INSTRUCTIONS
          _infoCard(
            icon: Icons.lightbulb_rounded,
            title: 'INSTRUCTIONS',
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                _instruction(
                  'There are ${widget.questions.length} MCQs.',
                ),

                _instruction(
                  'Each question has one correct answer.',
                ),

                _instruction(
                  'Select the best option.',
                ),

                _instruction(
                  'Complete all questions to finish the level.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // ==========================================================
  // INFO CARD
  // ==========================================================

  Widget _infoCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: colors.panel,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: colors.border
              .withOpacity(.65),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(
            children: [

              Icon(
                icon,
                color: colors.accent,
                size: 19,
              ),

              const SizedBox(width: 8),

              Text(
                title,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: .8,
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


  // ==========================================================
  // TOPIC CHIP
  // ==========================================================

  Widget _topicChip(String text) {

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: colors.accent
            .withOpacity(.08),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: colors.accent
              .withOpacity(.25),
        ),
      ),

      child: Text(
        text,
        style: TextStyle(
          color: colors.accent,
          fontSize: 10,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }


  // ==========================================================
  // REWARD
  // ==========================================================

  Widget _reward(
    IconData icon,
    String text,
  ) {

    return Column(
      children: [

        Icon(
          icon,
          color: colors.secondary,
          size: 25,
        ),

        const SizedBox(height: 5),

        Text(
          text,
          style: TextStyle(
            color: colors.text,
            fontSize: 10,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ],
    );
  }


  // ==========================================================
  // INSTRUCTION
  // ==========================================================

  Widget _instruction(String text) {

    return Padding(
      padding:
          const EdgeInsets.only(bottom: 7),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            '• ',
            style: TextStyle(
              color: colors.accent,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colors.muted,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ==========================================================
  // QUIZ AREA
  // ==========================================================

  Widget _buildQuizArea() {

    return Column(
      children: [

        // QUIZ HEADER
        _buildQuizHeader(),

        const SizedBox(height: 14),

        // QUESTION
        _buildQuestionCard(),

        const SizedBox(height: 14),

        // SEPARATE ANIMATION
        _buildAnimationPanel(),
      ],
    );
  }


  // ==========================================================
  // QUIZ HEADER
  // ==========================================================

  Widget _buildQuizHeader() {

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),

      decoration: BoxDecoration(
        color: colors.panel,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: colors.border,
        ),
      ),

      child: Row(
        children: [

          Icon(
            Icons.coffee_rounded,
            color: colors.secondary,
          ),

          const SizedBox(width: 8),

          Text(
            'JAVA',
            style: TextStyle(
              color: colors.text,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white54,
          ),

          const Spacer(),

          // ANIMATION BUTTON
          ElevatedButton.icon(
            onPressed: _toggleAnimation,

            icon: Icon(
              animationPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              size: 17,
            ),

            label: Text(
              animationPlaying
                  ? 'Animation'
                  : 'Play Animation',
            ),

            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  colors.accent
                      .withOpacity(.16),

              foregroundColor:
                  colors.accent,

              elevation: 0,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ==========================================================
  // QUESTION CARD
  // ==========================================================

  Widget _buildQuestionCard() {

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: colors.panel,

        borderRadius:
            BorderRadius.circular(22),

        border: Border.all(
          color: colors.border,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // QUESTION HEADER
          Row(
            children: [

              Container(
                width: 40,
                height: 40,

                decoration: BoxDecoration(
                  color: colors.accent
                      .withOpacity(.12),

                  borderRadius:
                      BorderRadius.circular(12),
                ),

                child: Icon(
                  Icons.quiz_rounded,
                  color: colors.accent,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                question.concept
                    .toUpperCase(),

                style: TextStyle(
                  color: colors.accent,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // QUESTION
          Text(
            question.question,

            style: TextStyle(
              color: colors.text,
              fontSize: 17,
              height: 1.45,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(height: 18),

          // OPTIONS
          ...List.generate(
            question.options.length,
            (index) {
              return _buildOption(
                index,
                question.options[index],
              );
            },
          ),

          // EXPLANATION
          if (submitted)
            _buildExplanation(),

          const SizedBox(height: 10),

          // SUBMIT / NEXT
          Row(
            children: [

              Expanded(
                child: ElevatedButton(
                  onPressed:
                      completed
                          ? null
                          : submitted
                              ? _nextQuestion
                              : _submitAnswer,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        colors.accent,

                    foregroundColor:
                        colors.background,

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 15,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),

                  child: Text(
                    completed
                        ? 'LEVEL COMPLETED ✓'
                        : submitted
                            ? 'NEXT QUESTION →'
                            : 'SUBMIT ANSWER',

                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              IconButton(
                onPressed:
                    _restartQuestion,

                icon: const Icon(
                  Icons.replay_rounded,
                ),

                color: colors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }


  // ==========================================================
  // MCQ OPTION
  // ==========================================================

  Widget _buildOption(
    int index,
    String text,
  ) {

    final isSelected =
        selectedAnswer == index;

    final isCorrect =
        submitted &&
        index == question.correctOption;

    final isWrong =
        submitted &&
        isSelected &&
        !isCorrect;


    Color background =
        colors.card;

    Color border =
        colors.border;


    if (isSelected) {
      background =
          colors.selected;

      border =
          colors.accent;
    }


    if (isCorrect) {
      background =
          colors.accent
              .withOpacity(.15);

      border =
          colors.accent;
    }


    if (isWrong) {
      background =
          Colors.red
              .withOpacity(.12);

      border =
          Colors.redAccent;
    }


    return GestureDetector(
      onTap: submitted
          ? null
          : () {
              _selectAnswer(index);
            },

      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 220,
        ),

        margin:
            const EdgeInsets.only(
          bottom: 11,
        ),

        padding:
            const EdgeInsets.all(14),

        decoration:
            BoxDecoration(
          color: background,

          borderRadius:
              BorderRadius.circular(15),

          border: Border.all(
            color: border,

            width:
                isSelected ||
                        isCorrect ||
                        isWrong
                    ? 2
                    : 1,
          ),
        ),

        child: Row(
          children: [

            // LETTER
            Container(
              width: 34,
              height: 34,

              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,

                color:
                    isSelected ||
                            isCorrect
                        ? colors.accent
                        : Colors.white
                            .withOpacity(.08),
              ),

              child: Center(
                child: Text(
                  String.fromCharCode(
                    65 + index,
                  ),

                  style: TextStyle(
                    color:
                        isSelected ||
                                isCorrect
                            ? colors
                                .background
                            : colors.text,

                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // TEXT
            Expanded(
              child: Text(
                text,

                style: TextStyle(
                  color: colors.text,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ),

            // RESULT ICON
            if (isCorrect)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.greenAccent,
              ),

            if (isWrong)
              const Icon(
                Icons.cancel_rounded,
                color: Colors.redAccent,
              ),
          ],
        ),
      ),
    );
  }


  // ==========================================================
  // EXPLANATION
  // ==========================================================

  Widget _buildExplanation() {

    final correct =
        selectedAnswer ==
        question.correctOption;

    return Container(
      width: double.infinity,

      margin:
          const EdgeInsets.only(
        top: 8,
      ),

      padding:
          const EdgeInsets.all(14),

      decoration:
          BoxDecoration(
        color: correct
            ? colors.accent
                .withOpacity(.08)
            : Colors.red
                .withOpacity(.08),

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color: correct
              ? colors.accent
              : Colors.redAccent,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            correct
                ? '✓ CORRECT ANSWER'
                : '✗ INCORRECT ANSWER',

            style: TextStyle(
              color: correct
                  ? colors.accent
                  : Colors.redAccent,

              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            question.explanation,

            style: TextStyle(
              color: colors.muted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }


  // ==========================================================
  // ANIMATION PANEL
  // ==========================================================

  Widget _buildAnimationPanel() {

    final steps =
        question.animationSteps;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration:
          BoxDecoration(
        color: colors.panel,

        borderRadius:
            BorderRadius.circular(22),

        border: Border.all(
          color: colors.border,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // HEADER
          Row(
            children: [

              Icon(
                Icons.auto_awesome_rounded,
                color: colors.accent,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  'LEVEL ${widget.level} VISUALIZER',

                  style: TextStyle(
                    color: colors.accent,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),

              IconButton(
                onPressed:
                    _toggleAnimation,

                icon: Icon(
                  animationPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                ),

                color: colors.text,
              ),

              IconButton(
                onPressed:
                    _resetAnimation,

                icon: const Icon(
                  Icons.replay_rounded,
                ),

                color: colors.text,
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            question.animationTitle,

            style: TextStyle(
              color: colors.text,
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(height: 15),

          // ANIMATION SCENE
          _buildAnimationScene(steps),

          const SizedBox(height: 12),

          // STEP
          if (steps.isNotEmpty)
            Center(
              child: Text(
                'STEP ${animationStep + 1} / ${steps.length}',

                style: TextStyle(
                  color: colors.accent,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }


  // ==========================================================
  // ANIMATION SCENE
  // ==========================================================

  Widget _buildAnimationScene(
    List<String> steps,
  ) {

    if (steps.isEmpty) {
      return Container(
        height: 220,

        decoration:
            BoxDecoration(
          color: colors.background,

          borderRadius:
              BorderRadius.circular(18),
        ),

        child: Center(
          child: Text(
            'Animation coming soon...',
            style: TextStyle(
              color: colors.muted,
            ),
          ),
        ),
      );
    }


    final safeStep =
        animationStep % steps.length;


    return Container(
      height: 230,

      width: double.infinity,

      decoration:
          BoxDecoration(
        color: colors.background,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: colors.border
              .withOpacity(.7),
        ),
      ),

      child: Center(
        child: AnimatedSwitcher(
          duration:
              const Duration(
            milliseconds: 450,
          ),

          child: Column(
            key: ValueKey(
              safeStep,
            ),

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              // ICON
              AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 400,
                ),

                width: 78,
                height: 78,

                decoration:
                    BoxDecoration(
                  shape:
                      BoxShape.circle,

                  color:
                      colors.accent
                          .withOpacity(.12),

                  border: Border.all(
                    color:
                        colors.accent,

                    width: 2,
                  ),
                ),

                child: Icon(
                  _animationIcon(),
                  color:
                      colors.accent,
                  size: 40,
                ),
              ),

              const SizedBox(height: 18),

              // STEP TEXT
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Text(
                  steps[safeStep],

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    color: colors.text,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              if (safeStep <
                  steps.length - 1)
                Icon(
                  Icons
                      .arrow_downward_rounded,
                  color:
                      colors.accent,
                ),
            ],
          ),
        ),
      ),
    );
  }


  // ==========================================================
  // ANIMATION ICON
  // ==========================================================

  IconData _animationIcon() {

    switch (
        widget.subject
            .trim()
            .toUpperCase()) {

      case 'CN':
      case 'COMPUTER NETWORKS':
        return Icons
            .account_tree_rounded;

      case 'DBMS':
        return Icons.storage_rounded;

      case 'OS':
      case 'OPERATING SYSTEMS':
        return Icons.memory_rounded;

      case 'ML':
      case 'MACHINE LEARNING':
        return Icons.psychology_rounded;

      case 'OOPS':
      case 'OBJECT ORIENTED PROGRAMMING':
        return Icons.category_rounded;

      default:
        return Icons.code_rounded;
    }
  }


  // ==========================================================
  // BOTTOM NAVIGATION
  // ==========================================================

  Widget _buildBottomNavigation() {

    return Row(
      children: [

        // PREVIOUS
        OutlinedButton.icon(
          onPressed:
              currentQuestion == 0
                  ? null
                  : _previousQuestion,

          icon: const Icon(
            Icons.chevron_left_rounded,
          ),

          label: const Text(
            'PREVIOUS',
          ),

          style:
              OutlinedButton.styleFrom(
            foregroundColor:
                colors.text,

            side: BorderSide(
              color: colors.border,
            ),

            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
          ),
        ),

        const Spacer(),

        // SCORE
        Text(
          'Score $score/${widget.questions.length}',

          style: TextStyle(
            color: colors.muted,
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const Spacer(),

        // NEXT
        OutlinedButton.icon(
          onPressed:
              submitted &&
                      currentQuestion <
                          widget.questions.length -
                              1
                  ? _nextQuestion
                  : null,

          icon: const Icon(
            Icons.chevron_right_rounded,
          ),

          label: const Text(
            'NEXT',
          ),

          style:
              OutlinedButton.styleFrom(
            foregroundColor:
                colors.text,

            side: BorderSide(
              color: colors.border,
            ),

            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}