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



class _LossCurvePainter extends CustomPainter {
  final CoreTheme colors;
  final int activeStep;
  _LossCurvePainter({required this.colors, required this.activeStep});

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()..color = colors.border..strokeWidth = 1.2;
    canvas.drawLine(Offset(8, size.height - 8), Offset(size.width - 5, size.height - 8), axis);
    canvas.drawLine(const Offset(8, 8), Offset(8, size.height - 8), axis);
    final curve = Path()..moveTo(12, 15)..cubicTo(size.width * .18, 20, size.width * .23, size.height * .82, size.width * .42, size.height * .78)..cubicTo(size.width * .58, size.height * .73, size.width * .67, size.height * .88, size.width * .9, size.height * .88);
    canvas.drawPath(curve, Paint()..color = colors.accent.withValues(alpha: .85)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round);
    final x = [12.0, size.width * .22, size.width * .4, size.width * .62, size.width * .86][activeStep];
    final y = [15.0, size.height * .42, size.height * .75, size.height * .78, size.height * .88][activeStep];
    canvas.drawCircle(Offset(x, y), 7, Paint()..color = colors.secondary);
    canvas.drawCircle(Offset(x, y), 12, Paint()..color = colors.secondary.withValues(alpha: .18));
  }
  @override
  bool shouldRepaint(covariant _LossCurvePainter oldDelegate) => oldDelegate.activeStep != activeStep || oldDelegate.colors.accent != colors.accent;
}

class CoreSubjectLevelScreen extends StatefulWidget {

  final AppTheme theme;



  final int level;



  final String subject;



  final String title;



  final String subtitle;



  final Color accentColor;



  final List<CoreLearningQuestion> questions;



  final String nextTitle;

  final VoidCallback? onLevelComplete;

  final VoidCallback? onPreviousLevel;



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

    this.onLevelComplete,

    this.onPreviousLevel,

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

  // Core CS progression is stored separately from DSA.
  int coreXp = 0;
  int coreStreak = 0;
  int bestCoreStreak = 0;
  int correctAnswersThisLevel = 0;
  final Set<String> coreBadges = <String>{};
  bool _progressLoaded = false;

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

    _loadCoreProgress();
    _startAnimation();

  }





  // ==========================================================
  // CORE CS XP, STREAKS AND REWARDS (separate from DSA)
  // ==========================================================

  String get _corePrefix => 'core_progress_${widget.subject.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}';

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadCoreProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      coreXp = prefs.getInt('${_corePrefix}_xp') ?? 0;
      coreStreak = prefs.getInt('${_corePrefix}_streak') ?? 0;
      bestCoreStreak = prefs.getInt('${_corePrefix}_best_streak') ?? 0;
      coreBadges.addAll(prefs.getStringList('${_corePrefix}_badges') ?? const <String>[]);
      _progressLoaded = true;
    });
  }

  Future<void> _recordCoreActivity({required bool correct, required bool levelFinished}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final lastDay = prefs.getString('${_corePrefix}_last_day');
    var nextStreak = prefs.getInt('${_corePrefix}_streak') ?? 0;
    var best = prefs.getInt('${_corePrefix}_best_streak') ?? 0;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey = '${yesterday.year.toString().padLeft(4, '0')}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    if (lastDay != today) {
      nextStreak = lastDay == yesterdayKey ? nextStreak + 1 : 1;
    }
    best = nextStreak > best ? nextStreak : best;

    var gained = correct ? 10 : 2; // participation XP; correct answer earns more.
    if (levelFinished) gained += 50;
    var nextXp = (prefs.getInt('${_corePrefix}_xp') ?? 0) + gained;
    final badges = (prefs.getStringList('${_corePrefix}_badges') ?? <String>[]).toSet();
    final newlyUnlocked = <String>[];
    void unlock(String id) {
      if (badges.add(id)) newlyUnlocked.add(id);
    }
    if (correct) unlock('first_correct');
    if (correctAnswersThisLevel >= 5) unlock('five_correct');
    if (levelFinished && correctAnswersThisLevel == widget.questions.length) unlock('perfect_level');
    if (nextStreak >= 3) unlock('three_day_streak');
    if (nextStreak >= 7) unlock('seven_day_streak');

    await prefs.setInt('${_corePrefix}_xp', nextXp);
    await prefs.setInt('${_corePrefix}_streak', nextStreak);
    await prefs.setInt('${_corePrefix}_best_streak', best);
    await prefs.setString('${_corePrefix}_last_day', today);
    await prefs.setStringList('${_corePrefix}_badges', badges.toList());
    if (!mounted) return;
    setState(() {
      coreXp = nextXp;
      coreStreak = nextStreak;
      bestCoreStreak = best;
      coreBadges
        ..clear()
        ..addAll(badges);
    });
    if (newlyUnlocked.isNotEmpty) {
      final names = newlyUnlocked.map(_badgeName).join(', ');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.panel,
        content: Text('🏅 Badge unlocked: $names', style: TextStyle(color: colors.text, fontWeight: FontWeight.w800)),
      ));
    } else if (gained > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(correct ? '+$gained Core XP! Great answer!' : '+$gained Core XP for trying again!'),
        duration: const Duration(milliseconds: 900),
      ));
    }
  }

  String _badgeName(String id) {
    const names = <String, String>{
      'first_correct': 'First Spark',
      'five_correct': 'Concept Crusher',
      'perfect_level': 'Perfect Quest',
      'three_day_streak': '3-Day Flame',
      'seven_day_streak': 'Week Warrior',
    };
    return names[id] ?? id;
  }

  Widget _buildCoreRewards() {
    final items = <(String, String, IconData)>[
      ('first_correct', 'First Spark', Icons.bolt_rounded),
      ('five_correct', 'Concept Crusher', Icons.psychology_alt_rounded),
      ('perfect_level', 'Perfect Quest', Icons.workspace_premium_rounded),
      ('three_day_streak', '3-Day Flame', Icons.local_fire_department_rounded),
      ('seven_day_streak', 'Week Warrior', Icons.military_tech_rounded),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colors.panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: colors.accent.withValues(alpha: .4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('CORE QUEST REWARDS', style: TextStyle(color: colors.accent, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
        const SizedBox(height: 6),
        Text('Earn XP by learning. Keep your Core streak alive. Unlock badges as you improve.', style: TextStyle(color: colors.muted, fontSize: 12)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: items.map((item) {
          final unlocked = coreBadges.contains(item.$1);
          return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9), decoration: BoxDecoration(color: unlocked ? colors.accent.withValues(alpha: .16) : colors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: unlocked ? colors.accent : colors.border)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(item.$3, size: 17, color: unlocked ? colors.accent : colors.muted), const SizedBox(width: 6), Text(item.$2, style: TextStyle(color: unlocked ? colors.text : colors.muted, fontSize: 11, fontWeight: FontWeight.w800)), if (!unlocked) ...[const SizedBox(width: 4), Icon(Icons.lock_outline, size: 12, color: colors.muted)]]));
        }).toList()),
        const SizedBox(height: 10),
        Text('Core XP: $coreXp   •   Current streak: $coreStreak days   •   Best: $bestCoreStreak days', style: TextStyle(color: colors.text, fontSize: 12, fontWeight: FontWeight.w800)),
      ]),
    );
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





  Future<void> _openNotes() async {

    final prefs = await SharedPreferences.getInstance();

    final key = 'core_notes_${widget.subject.toUpperCase()}_${widget.level}';

    final controller = TextEditingController(text: prefs.getString(key) ?? '');

    if (!mounted) return;

    await showDialog<void>(

      context: context,

      builder: (dialogContext) => AlertDialog(

        backgroundColor: colors.panel,

        title: Text('Quest Notes • Level ${widget.level}',

            style: TextStyle(color: colors.text)),

        content: SizedBox(

          width: 520,

          child: TextField(

            controller: controller,

            maxLines: 8,

            style: TextStyle(color: colors.text),

            decoration: InputDecoration(

              hintText: 'Write key points, formulas, examples...',

              hintStyle: TextStyle(color: colors.muted),

              enabledBorder: OutlineInputBorder(

                borderSide: BorderSide(color: colors.border),

              ),

              focusedBorder: OutlineInputBorder(

                borderSide: BorderSide(color: colors.accent),

              ),

            ),

          ),

        ),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(dialogContext),

            child: const Text('CANCEL'),

          ),

          ElevatedButton(

            onPressed: () async {

              await prefs.setString(key, controller.text);

              if (dialogContext.mounted) Navigator.pop(dialogContext);

            },

            child: const Text('SAVE NOTES'),

          ),

        ],

      ),

    );

    controller.dispose();

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



    final isLastQuestion = currentQuestion == widget.questions.length - 1;
    setState(() {
      submitted = true;
      if (correct) {
        score++;
        correctAnswersThisLevel++;
      }
    });

    // Persist Core CS XP/streak independently of DSA progression.
    _recordCoreActivity(correct: correct, levelFinished: isLastQuestion);

    if (isLastQuestion) {
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



            return Stack(

              children: [

                Positioned.fill(

                  child: IgnorePointer(

                    child: _buildThemeAtmosphere(),

                  ),

                ),

                SingleChildScrollView(

              padding: EdgeInsets.symmetric(

                horizontal: wide ? 28 : 14,

                vertical: 16,

              ),



              child: Column(

                children: [



                  // TOP BAR

                  _buildTopBar(),



                  SizedBox(height: wide ? 12 : 18),



                  // PROGRESS

                  _buildProgress(progress),



                  const SizedBox(height: 18),



                  // Core CS levels open directly into the learning interface.

                  // The separate Topics / Rewards / Instructions overview is intentionally omitted.

                  _buildQuizArea(wide: wide),



                  const SizedBox(height: 18),



                  _buildBottomNavigation(),

                ],

              ),

            ),

              ],

            );

          },

        ),

      ),

    );

  }



  Widget _buildThemeAtmosphere() {

    final isForest = widget.theme == AppTheme.forest;

    final isCyber = widget.theme == AppTheme.cyberpunk;

    final symbols = isForest

        ? const ['✦', '🍃', '✧', '🌿']

        : isCyber

            ? const ['✦', '⌁', '◇', '⚡']

            : const ['✦', '♛', '⚜', '✧'];

    return Stack(

      children: [

        Positioned(

          top: 28,

          right: 24,

          child: Opacity(

            opacity: .10,

            child: Icon(

              isForest

                  ? Icons.forest_rounded

                  : isCyber

                      ? Icons.memory_rounded

                      : Icons.castle_rounded,

              size: 190,

              color: colors.accent,

            ),

          ),

        ),

        Positioned(

          bottom: 65,

          left: 20,

          child: Opacity(

            opacity: .08,

            child: Icon(

              isForest

                  ? Icons.eco_rounded

                  : isCyber

                      ? Icons.bolt_rounded

                      : Icons.shield_moon_rounded,

              size: 115,

              color: colors.secondary,

            ),

          ),

        ),

        Positioned(

          top: 175,

          right: 75,

          child: Text(

            symbols[0],

            style: TextStyle(color: colors.accent, fontSize: 30),

          ),

        ),

      ],

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

                  .withValues(alpha: .12),



              borderRadius:

                  BorderRadius.circular(13),



              border: Border.all(

                color: colors.accent

                    .withValues(alpha: .35),

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

            _progressLoaded ? '$coreStreak' : '…',

            'CORE STREAK',

          ),



          const SizedBox(width: 10),



          // XP

          _topStat(

            Icons.star_rounded,

            _progressLoaded ? '$coreXp' : '…',

            'CORE XP',

          ),



          const SizedBox(width: 6),

          IconButton(

            tooltip: 'Quest notes',

            onPressed: _openNotes,

            icon: const Icon(Icons.edit_note_rounded),

            color: colors.accent,

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

                Colors.white.withValues(alpha: .08),



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

  // QUIZ AREA

  // ==========================================================



  Widget _buildQuizArea({required bool wide}) {

    // The MCQ and lesson animation share one row on desktop/tablet.

    // On narrow screens they stack to avoid overflow.

    return Column(

      children: [

        _buildQuizHeader(),

        const SizedBox(height: 14),

        if (wide)

          Row(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Expanded(

                flex: 5,

                child: _buildQuestionCard(),

              ),

              const SizedBox(width: 16),

              Expanded(

                flex: 6,

                child: _buildAnimationPanel(compact: true),

              ),

            ],

          )

        else ...[

          _buildQuestionCard(),

          const SizedBox(height: 14),

          _buildAnimationPanel(compact: true),

        ],

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

            '${widget.subject.toUpperCase()} • LEVEL ${widget.level}',

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

                      .withValues(alpha: .16),



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

                      .withValues(alpha: .12),



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

          if (completed) ...[
            const SizedBox(height: 16),
            _buildCoreRewards(),
          ],

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

              .withValues(alpha: .15);



      border =

          colors.accent;

    }





    if (isWrong) {

      background =

          Colors.red

              .withValues(alpha: .12);



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

                            .withValues(alpha: .08),

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

                .withValues(alpha: .08)

            : Colors.red

                .withValues(alpha: .08),



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



  Widget _buildAnimationPanel({bool compact = false}) {



    final steps =

        question.animationSteps;



    return Container(

      width: double.infinity,



      padding: EdgeInsets.all(compact ? 14 : 18),



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

                  'LEVEL ${widget.level} ANIMATION',



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



          SizedBox(height: compact ? 8 : 15),



          // ANIMATION SCENE

          _buildAnimationScene(steps, compact: compact),



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



  Widget _buildAnimationScene(List<String> steps, {bool compact = false}) {
    if (steps.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(18)),
        child: Center(child: Text('Animation coming soon...', style: TextStyle(color: colors.muted))),
      );
    }

    final safeStep = animationStep % steps.length;
    final text = '${question.title} ${question.concept} ${question.question}'.toLowerCase();
    final subject = widget.subject.trim().toUpperCase();
    final isOS = subject == 'OS' || subject.contains('OPERATING');
    final isDB = subject == 'DBMS';
    final isCN = subject == 'CN' || subject.contains('NETWORK');
    final isML = subject == 'ML' || subject.contains('MACHINE LEARNING');

    Widget visual;
    String label;
    if (isCN) {
      label = _hasConcept(text, ['dns', 'domain name']) ? 'DNS LOOKUP' :
          _hasConcept(text, ['tcp', 'handshake', 'syn']) ? 'TCP CONNECTION' : 'PACKET ROUTING';
      visual = _networkSimulation(safeStep, text, compact);
    } else if (isDB) {
      label = _hasConcept(text, ['normalization', '1nf', '2nf', '3nf']) ? 'TABLE NORMALIZATION' :
          _hasConcept(text, ['primary key', 'foreign key']) ? 'KEY RELATIONSHIP' : 'DATABASE QUERY';
      visual = _databaseSimulation(safeStep, text, compact);
    } else if (isOS) {
      label = _hasConcept(text, ['deadlock', 'mutex', 'semaphore', 'critical section']) ? 'RESOURCE SYNCHRONIZATION' :
          _hasConcept(text, ['paging', 'virtual memory', 'page fault']) ? 'VIRTUAL MEMORY' : 'PROCESS SCHEDULING';
      visual = _osSimulation(safeStep, text, compact);
    } else if (isML) {
      label = _hasConcept(text, ['gradient descent', 'loss', 'learning rate']) ? 'OPTIMIZATION SIMULATION' :
          _hasConcept(text, ['decision tree', 'random forest']) ? 'MODEL DECISION PATH' : 'MODEL TRAINING';
      visual = _mlSimulation(safeStep, text, compact);
    } else {
      label = _hasConcept(text, ['inheritance', 'parent class', 'child class']) ? 'CLASS INHERITANCE' :
          _hasConcept(text, ['polymorphism', 'overriding', 'overloading', 'dynamic binding']) ? 'RUNTIME METHOD SELECTION' : 'OBJECT LIFECYCLE';
      visual = _oopSimulation(safeStep, text, compact);
    }

    return Container(
      height: compact ? 330 : 300,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [colors.background, colors.panel.withValues(alpha: .98)]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.accent.withValues(alpha: .38)),
        boxShadow: [BoxShadow(color: colors.accent.withValues(alpha: .08), blurRadius: 20)],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.auto_awesome_rounded, color: colors.secondary, size: 16),
          const SizedBox(width: 7),
          Flexible(child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(color: colors.muted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))),
        ]),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.accent.withValues(alpha: .25)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.public_rounded, color: colors.accent, size: 15),
            const SizedBox(width: 6),
            Expanded(child: Text('REAL-LIFE EXAMPLE  •  ${_realWorldExample(text, subject)}',
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.text, fontSize: 10, height: 1.25, fontWeight: FontWeight.w700))),
          ]),
        ),
        const SizedBox(height: 6),
        Expanded(child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOutBack,
          child: KeyedSubtree(key: ValueKey('$label-$safeStep'), child: visual),
        )),
        const SizedBox(height: 8),
        AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: Container(
          key: ValueKey('explanation-$safeStep'), width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.border)),
          child: Text(steps[safeStep], textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.text, fontSize: compact ? 11 : 12, height: 1.3, fontWeight: FontWeight.w700)),
        )),
      ]),
    );
  }

  bool _hasConcept(String text, List<String> words) => words.any(text.contains);

  String _realWorldExample(String text, String subject) {
    if (subject == 'CN' || subject.contains('NETWORK')) {
      if (_hasConcept(text, ['dns', 'domain name'])) return 'Typing a website name and finding the server IP address.';
      if (_hasConcept(text, ['tcp', 'handshake', 'syn'])) return 'Your phone confirms a connection before sending a message.';
      if (_hasConcept(text, ['routing', 'router', 'packet'])) return 'A parcel passes through sorting hubs to reach your home.';
      if (_hasConcept(text, ['http', 'https', 'client', 'server'])) return 'A browser requests a page and the website sends it back.';
      return 'A WhatsApp message travels across networks to another phone.';
    }
    if (subject == 'DBMS') {
      if (_hasConcept(text, ['normalization', '1nf', '2nf', '3nf'])) return 'A college keeps student details once and links them to course records.';
      if (_hasConcept(text, ['primary key', 'foreign key', 'referential integrity'])) return 'A student ID connects a student record to their course enrollment.';
      if (_hasConcept(text, ['acid', 'transaction', 'commit', 'rollback'])) return 'A bank transfer must debit and credit accounts together—or cancel safely.';
      if (_hasConcept(text, ['index', 'b+ tree'])) return 'A book index helps find a topic without reading every page.';
      if (_hasConcept(text, ['join'])) return 'A restaurant combines customer details with their order history.';
      return 'A restaurant app saves an order and retrieves matching records.';
    }
    if (subject == 'OS' || subject.contains('OPERATING')) {
      if (_hasConcept(text, ['deadlock', 'mutex', 'semaphore', 'critical section'])) return 'Two people each hold one key and wait for the other key.';
      if (_hasConcept(text, ['paging', 'virtual memory', 'page fault'])) return 'A desk keeps current papers nearby and fetches stored files when needed.';
      if (_hasConcept(text, ['round robin'])) return 'People at a help desk each get a short turn before the next person.';
      if (_hasConcept(text, ['thread'])) return 'A music app plays audio while another task loads the playlist.';
      if (_hasConcept(text, ['context switching'])) return 'A chef pauses one order, remembers its progress, and handles another.';
      return 'Your laptop shares CPU time between a browser, music, and an editor.';
    }
    if (subject == 'ML' || subject.contains('MACHINE LEARNING')) {
      if (_hasConcept(text, ['precision', 'recall', 'f1', 'confusion matrix'])) return 'A medical test is judged by correct alerts and missed cases.';
      if (_hasConcept(text, ['gradient descent', 'loss', 'learning rate'])) return 'A delivery driver repeatedly adjusts a route to reduce travel time.';
      if (_hasConcept(text, ['k-means', 'clustering'])) return 'A shop groups customers with similar buying habits.';
      if (_hasConcept(text, ['decision tree', 'random forest'])) return 'A loan system asks questions such as income and repayment history.';
      if (_hasConcept(text, ['regression'])) return 'Past house prices help estimate the price of a new house.';
      if (_hasConcept(text, ['spam', 'classification', 'classifier'])) return 'An email app learns to separate spam from genuine messages.';
      return 'A shopping app learns from past examples to suggest a relevant item.';
    }
    if (_hasConcept(text, ['inheritance'])) return 'An ElectricCar reuses shared fields and methods from a Vehicle class.';
    if (_hasConcept(text, ['polymorphism', 'overrid', 'overload', 'dynamic binding'])) return 'The same pay() action behaves differently for card and cash payments.';
    if (_hasConcept(text, ['encapsulation', 'access modifier'])) return 'A bank account changes its balance through validated deposit and withdraw methods.';
    if (_hasConcept(text, ['interface', 'abstract'])) return 'Different payment methods follow the same payment contract.';
    if (_hasConcept(text, ['constructor'])) return 'A new student profile is initialized with a name, ID, and course.';
    return 'A class is a blueprint; individual objects represent real items such as cars or students.';
  }

  Widget _simNode(String title, IconData icon, {bool active = false, double width = 94}) {
    return AnimatedContainer(duration: const Duration(milliseconds: 350), width: width, padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
      decoration: BoxDecoration(color: active ? colors.accent.withValues(alpha: .19) : colors.card,
        borderRadius: BorderRadius.circular(13), border: Border.all(color: active ? colors.accent : colors.border, width: active ? 2 : 1),
        boxShadow: active ? [BoxShadow(color: colors.accent.withValues(alpha: .22), blurRadius: 12)] : []),
      child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 25, color: active ? colors.accent : colors.muted), const SizedBox(height: 6),
        Text(title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.text, fontSize: 10, fontWeight: FontWeight.w800))]));
  }

  Widget _osSimulation(int step, String text, bool compact) {
    if (_hasConcept(text, ['deadlock', 'mutex', 'semaphore', 'critical section'])) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _simNode('Process A', Icons.memory_rounded, active: step % 3 == 0, width: 88),
          Icon(Icons.sync_alt_rounded, color: colors.secondary),
          _simNode('Resource', Icons.lock_rounded, active: step % 3 == 1, width: 88),
          Icon(Icons.sync_alt_rounded, color: colors.secondary),
          _simNode('Process B', Icons.memory_rounded, active: step % 3 == 2, width: 88),
        ]), const SizedBox(height: 16), Text(step % 3 == 0 ? 'A requests a resource' : step % 3 == 1 ? 'Resource is held / awaited' : 'Check for circular waiting', style: TextStyle(color: colors.accent, fontWeight: FontWeight.w800, fontSize: 11)),
      ]);
    }
    if (_hasConcept(text, ['paging', 'virtual memory', 'page fault'])) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children: [
        _simNode('Virtual page', Icons.description_rounded, active: step % 3 == 0), Icon(Icons.arrow_forward_rounded, color: colors.secondary),
        _simNode('Page table', Icons.table_chart_rounded, active: step % 3 == 1), Icon(Icons.arrow_forward_rounded, color: colors.secondary),
        _simNode('RAM frame', Icons.memory_rounded, active: step % 3 == 2),
      ]);
    }
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _simNode('Ready queue', Icons.queue_rounded, active: step % 3 == 0, width: 88), Icon(Icons.arrow_forward_rounded, color: colors.secondary),
        _simNode('Scheduler', Icons.tune_rounded, active: step % 3 == 1, width: 88), Icon(Icons.arrow_forward_rounded, color: colors.secondary),
        _simNode('CPU', Icons.memory_rounded, active: step % 3 == 2, width: 78),
      ]), const SizedBox(height: 15), _progressDots(step),
    ]);
  }

  Widget _databaseSimulation(int step, String text, bool compact) {
    final normalize = _hasConcept(text, ['normalization', '1nf', '2nf', '3nf', 'redundancy', 'functional dependency']);
    final keys = _hasConcept(text, ['primary key', 'foreign key', 'referential integrity']);
    if (normalize) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _tableVisual(step == 0 ? 'STUDENT' : 'STUDENT', ['ID', 'Name', 'Course', 'Instructor'], step == 0),
        Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Icon(Icons.arrow_downward_rounded, color: colors.secondary)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _tableVisual('STUDENT', ['ID', 'Name'], step == 1), _tableVisual('COURSE', ['Course', 'Instructor'], step == 2),
        ]),
      ]);
    }
    if (keys) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _tableVisual('STUDENT', ['ID 🔑', 'Name'], step % 3 == 0),
        Icon(Icons.link_rounded, color: colors.secondary, size: 24),
        _tableVisual('ENROLLMENT', ['Student_ID', 'Course_ID'], step % 3 != 0),
      ]);
    }
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _simNode('SQL query', Icons.code_rounded, active: step % 3 == 0), Icon(Icons.arrow_forward_rounded, color: colors.secondary),
        _simNode('Database', Icons.storage_rounded, active: step % 3 == 1), Icon(Icons.arrow_forward_rounded, color: colors.secondary),
        _simNode('Result rows', Icons.table_view_rounded, active: step % 3 == 2),
      ]), const SizedBox(height: 12), _tableVisual('RESULT', ['ID', 'VALUE'], step % 3 == 2),
    ]);
  }

  Widget _tableVisual(String name, List<String> columns, bool active) {
    return Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: active ? colors.accent.withValues(alpha: .12) : colors.card,
      borderRadius: BorderRadius.circular(9), border: Border.all(color: active ? colors.accent : colors.border)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [Text(name, style: TextStyle(color: colors.accent, fontSize: 9, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4), Row(mainAxisSize: MainAxisSize.min, children: columns.map((c) => Container(margin: const EdgeInsets.all(2), padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(4)), child: Text(c, style: TextStyle(color: colors.text, fontSize: 8, fontWeight: FontWeight.w700)))).toList())]));
  }

  Widget _networkSimulation(int step, String text, bool compact) {
    final dns = _hasConcept(text, ['dns', 'domain name']);
    final handshake = _hasConcept(text, ['tcp', 'handshake', 'syn']);
    final names = dns ? ['Domain', 'DNS server', 'IP address'] : handshake ? ['Client: SYN', 'Server: SYN-ACK', 'Client: ACK'] : ['Source', 'Router', 'Destination'];
    final icons = dns ? [Icons.language_rounded, Icons.dns_rounded, Icons.pin_drop_rounded] : [Icons.devices_rounded, Icons.router_rounded, Icons.laptop_chromebook_rounded];
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(3, (i) => Expanded(child: Column(children: [
        _simNode(names[i], icons[i], active: step % 3 == i, width: 88), if (i < 2) Icon(Icons.arrow_forward_rounded, color: step % 3 == i ? colors.accent : colors.secondary, size: 18),
      ])))),
      const SizedBox(height: 18),
      Container(height: 5, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(9)), child: Align(alignment: Alignment(step % 3 == 0 ? -1 : step % 3 == 1 ? 0 : 1, 0), child: Container(width: 18, decoration: BoxDecoration(color: colors.accent, borderRadius: BorderRadius.circular(9), boxShadow: [BoxShadow(color: colors.accent.withValues(alpha: .5), blurRadius: 8)])))),
    ]);
  }

  Widget _oopSimulation(int step, String text, bool compact) {
    final hierarchy = _hasConcept(text, ['inheritance', 'parent class', 'child class', 'class and object']);
    if (hierarchy) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _simNode('Parent class', Icons.account_tree_rounded, active: step % 3 == 0, width: 118),
        Icon(Icons.south_east_rounded, color: colors.secondary, size: 26),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _simNode('Child A', Icons.category_rounded, active: step % 3 == 1, width: 100),
          _simNode('Child B', Icons.extension_rounded, active: step % 3 == 2, width: 100),
        ]),
      ]);
    }
    if (_hasConcept(text, ['polymorphism', 'overriding', 'overloading', 'dynamic binding'])) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _simNode('Method call', Icons.touch_app_rounded, active: step % 3 == 0, width: 120),
        Icon(Icons.alt_route_rounded, color: colors.secondary, size: 27),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _simNode('Method A', Icons.play_arrow_rounded, active: step % 3 == 1, width: 100),
          _simNode('Method B', Icons.play_circle_rounded, active: step % 3 == 2, width: 100),
        ]),
      ]);
    }
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _simNode('Blueprint', Icons.description_rounded, active: step % 3 == 0), Icon(Icons.arrow_forward_rounded, color: colors.secondary),
      _simNode('Object', Icons.widgets_rounded, active: step % 3 == 1), Icon(Icons.arrow_forward_rounded, color: colors.secondary),
      _simNode('Behavior', Icons.play_circle_rounded, active: step % 3 == 2),
    ]);
  }

  Widget _mlSimulation(int step, String text, bool compact) {
    final gradient = _hasConcept(text, ['gradient descent', 'loss', 'learning rate', 'optimization']);
    if (gradient) {
      final points = [Offset(12, 18), Offset(38, 30), Offset(64, 49), Offset(90, 67), Offset(118, 76)];
      final active = points[step % points.length];
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(height: 120, child: CustomPaint(size: const Size(300, 120), painter: _LossCurvePainter(colors: colors, activeStep: step % points.length))),
        Text('Parameter update ${step + 1}  •  Loss ${['0.92', '0.61', '0.38', '0.19', '0.08'][step % 5]}', style: TextStyle(color: colors.accent, fontSize: 11, fontWeight: FontWeight.w900)),
      ]);
    }
    if (_hasConcept(text, ['decision tree', 'random forest'])) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _simNode('Feature', Icons.dataset_rounded, active: step % 3 == 0, width: 105), Icon(Icons.call_split_rounded, color: colors.secondary, size: 25),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_simNode('Branch A', Icons.account_tree_rounded, active: step % 3 == 1), _simNode('Branch B', Icons.account_tree_rounded, active: step % 3 == 2)]),
      ]);
    }
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _simNode('Training data', Icons.dataset_rounded, active: step % 3 == 0), Icon(Icons.arrow_forward_rounded, color: colors.secondary),
      _simNode('Model', Icons.psychology_rounded, active: step % 3 == 1), Icon(Icons.arrow_forward_rounded, color: colors.secondary),
      _simNode('Prediction', Icons.insights_rounded, active: step % 3 == 2),
    ]);
  }

  Widget _progressDots(int step) => Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) => AnimatedContainer(duration: const Duration(milliseconds: 250), margin: const EdgeInsets.symmetric(horizontal: 4), width: i == step % 3 ? 22 : 7, height: 7, decoration: BoxDecoration(color: i == step % 3 ? colors.accent : colors.border, borderRadius: BorderRadius.circular(9)))));

  // Choose a small visual story for the current MCQ, not just its subject.
  // This lets two questions in the same subject show different simulations.
  (List<String>, List<IconData>) _questionSimulation() {
    final text = '${question.title} ${question.concept} ${question.question}'.toLowerCase();
    bool hasAny(List<String> words) => words.any(text.contains);

    if (hasAny(['tcp', 'handshake', 'syn-ack', 'syn ack'])) {
      return (['SYN', 'SYN-ACK', 'ACK'], [Icons.send_rounded, Icons.swap_horiz_rounded, Icons.check_circle_rounded]);
    }
    if (hasAny(['dns', 'domain name', 'domain-to-ip', 'ip address'])) {
      return (['Domain', 'DNS Server', 'IP Address'], [Icons.language_rounded, Icons.dns_rounded, Icons.pin_drop_rounded]);
    }
    if (hasAny(['routing', 'router', 'packet', 'transmission', 'network layer'])) {
      return (['Source', 'Router', 'Destination'], [Icons.devices_rounded, Icons.router_rounded, Icons.laptop_chromebook_rounded]);
    }
    if (hasAny(['http', 'https', 'client', 'server', 'request', 'response'])) {
      return (['Client Request', 'Server', 'Response'], [Icons.web_rounded, Icons.dns_rounded, Icons.mark_email_read_rounded]);
    }
    if (hasAny(['primary key', 'foreign key', 'referential integrity'])) {
      return (['Primary Key', 'Reference', 'Related Row'], [Icons.key_rounded, Icons.link_rounded, Icons.table_rows_rounded]);
    }
    if (hasAny(['normalization', '1nf', '2nf', '3nf', 'redundancy', 'functional dependency'])) {
      return (['Raw Table', 'Split Tables', 'Clean Data'], [Icons.table_chart_rounded, Icons.call_split_rounded, Icons.checklist_rounded]);
    }
    if (hasAny(['sql', 'select query', 'query', 'join', 'database transaction'])) {
      return (['SQL Query', 'Database', 'Result Set'], [Icons.code_rounded, Icons.storage_rounded, Icons.table_view_rounded]);
    }
    if (hasAny(['deadlock', 'semaphore', 'mutex', 'synchronization', 'critical section'])) {
      return (['Processes', 'Shared Resource', 'Safe Access'], [Icons.account_tree_rounded, Icons.lock_rounded, Icons.verified_user_rounded]);
    }
    if (hasAny(['scheduling', 'round robin', 'fcfs', 'sjf', 'cpu burst', 'process state'])) {
      return (['Ready Queue', 'CPU Scheduler', 'Running Process'], [Icons.queue_rounded, Icons.tune_rounded, Icons.memory_rounded]);
    }
    if (hasAny(['paging', 'page table', 'virtual memory', 'page fault'])) {
      return (['Virtual Page', 'Page Table', 'RAM Frame'], [Icons.description_rounded, Icons.table_chart_rounded, Icons.memory_rounded]);
    }
    if (hasAny(['inheritance', 'parent class', 'child class', 'extends'])) {
      return (['Parent Class', 'Inherits', 'Child Class'], [Icons.account_tree_rounded, Icons.south_east_rounded, Icons.category_rounded]);
    }
    if (hasAny(['polymorphism', 'overriding', 'overloading', 'dynamic binding'])) {
      return (['Method Call', 'Choose Method', 'Run Behavior'], [Icons.touch_app_rounded, Icons.alt_route_rounded, Icons.play_circle_rounded]);
    }
    if (hasAny(['encapsulation', 'data hiding', 'access modifier', 'private member'])) {
      return (['Private Data', 'Public Method', 'Controlled Access'], [Icons.lock_rounded, Icons.functions_rounded, Icons.verified_user_rounded]);
    }
    if (hasAny(['gradient descent', 'loss function', 'learning rate', 'optimization'])) {
      return (['Initial Weights', 'Update Weights', 'Lower Loss'], [Icons.flag_rounded, Icons.trending_down_rounded, Icons.check_circle_rounded]);
    }
    if (hasAny(['classification', 'classifier', 'class label', 'prediction'])) {
      return (['Input Features', 'Trained Model', 'Predicted Class'], [Icons.dataset_rounded, Icons.psychology_rounded, Icons.label_rounded]);
    }
    if (hasAny(['overfitting', 'underfitting', 'regularization', 'validation'])) {
      return (['Training Data', 'Model Fit', 'Validation'], [Icons.dataset_rounded, Icons.show_chart_rounded, Icons.fact_check_rounded]);
    }

    // Subject-specific fallback for concepts without a recognized keyword.
    return (_simulationStageNames(widget.subject.trim().toUpperCase()),
        _simulationStageIcons(widget.subject.trim().toUpperCase()));
  }

  List<String> _simulationStageNames(String subject) {
    if (subject == 'CN' || subject == 'COMPUTER NETWORKS') {
      return ['Sender', 'Network', 'Receiver'];
    }
    if (subject == 'DBMS') return ['Query', 'Database', 'Result'];
    if (subject == 'OS' || subject == 'OPERATING SYSTEMS') {
      return ['Program', 'Memory / CPU', 'Output'];
    }
    if (subject == 'ML' || subject == 'MACHINE LEARNING') {
      return ['Training Data', 'Model', 'Prediction'];
    }
    if (subject == 'OOPS' || subject == 'OBJECT ORIENTED PROGRAMMING') {
      return ['Class', 'Object', 'Method'];
    }
    return ['Input', 'Process', 'Output'];
  }

  List<IconData> _simulationStageIcons(String subject) {
    if (subject == 'CN' || subject == 'COMPUTER NETWORKS') {
      return [Icons.devices_rounded, Icons.router_rounded, Icons.laptop_chromebook_rounded];
    }
    if (subject == 'DBMS') {
      return [Icons.search_rounded, Icons.storage_rounded, Icons.table_chart_rounded];
    }
    if (subject == 'OS' || subject == 'OPERATING SYSTEMS') {
      return [Icons.description_rounded, Icons.memory_rounded, Icons.terminal_rounded];
    }
    if (subject == 'ML' || subject == 'MACHINE LEARNING') {
      return [Icons.dataset_rounded, Icons.psychology_rounded, Icons.insights_rounded];
    }
    if (subject == 'OOPS' || subject == 'OBJECT ORIENTED PROGRAMMING') {
      return [Icons.account_tree_rounded, Icons.extension_rounded, Icons.play_arrow_rounded];
    }
    return [Icons.input_rounded, Icons.settings_rounded, Icons.check_circle_outline_rounded];
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

        OutlinedButton.icon(

          onPressed: widget.onPreviousLevel,

          icon: const Icon(Icons.chevron_left_rounded),

          label: const Text('PREVIOUS LEVEL'),

          style: OutlinedButton.styleFrom(

            foregroundColor: colors.text,

            side: BorderSide(color: colors.border),

            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),

          ),

        ),

        const Spacer(),

        Text(

          completed ? 'COMPLETED ✓' : 'LEVEL ${widget.level}/100',

          style: TextStyle(color: colors.muted, fontWeight: FontWeight.w800),

        ),

        const Spacer(),

        ElevatedButton.icon(

          onPressed: completed ? widget.onLevelComplete : null,

          icon: const Icon(Icons.chevron_right_rounded),

          label: Text(widget.nextTitle),

          style: ElevatedButton.styleFrom(

            backgroundColor: colors.accent,

            foregroundColor: colors.background,

            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),

          ),

        ),

      ],

    );

  }

}
