import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'theme_selection_screen.dart';

import 'theme_config.dart';

class LevelQuizScreen extends StatefulWidget {

  final int level;

  final Color accentColor;

  final AppTheme theme;

  const LevelQuizScreen({

    super.key,

    required this.level,

    required this.accentColor,

    required this.theme,

  });

  @override

  State<LevelQuizScreen> createState() => _LevelQuizScreenState();

}

class _LevelQuizScreenState extends State<LevelQuizScreen> {

  late final AppThemeConfig themeConfig;

  int currentQuestion = 0;

  int score = 0;

  List<String> selectedAnswers = [];

  bool answered = false;

  bool showSolution = false;

  @override

  void initState() {

    super.initState();

    themeConfig = AppThemeConfig.fromTheme(widget.theme);

    _resetAnswers();

  }

  // ============================================================\*

  // DSA QUESTIONS\*

  // ============================================================\*

  final List<DSAQuestion> questions = [

    DSAQuestion(

      topic: 'ARRAYS',

      difficulty: 'EASY',

      question:

          'Given an array of integers, find the maximum element in the array.',

      input: '[3, 7, 2, 9, 4]',

      output: '9',

      hint:

          'Start with one element as the current maximum and compare the remaining elements with it.',

      code: [

        'int max = {{0}};',

        '',

        'for (int i = 1; i < arr.length; i++) {',

        '',

        '    if (arr[i] > {{1}}) {',

        '        max = arr[i];',

        '    }',

        '}',

        '',

        'return {{2}};',

      ],

      keywords: [

        'arr[0]',

        'max',

        'i',

        'arr.length',

      ],

      correctAnswers: [

        'arr[0]',

        'max',

        'max',

      ],

    ),

    DSAQuestion(

      topic: 'STRINGS',

      difficulty: 'EASY',

      question:

          'Given a string, check whether it is a palindrome.',

      input: '"madam"',

      output: 'true',

      hint:

          'Compare characters from the beginning and the end while moving toward the center.',

      code: [

        'int left = {{0}};',

        'int right = str.length() - 1;',

        '',

        'while (left < right) {',

        '    if (str.charAt(left) != {{1}}) {',

        '        return false;',

        '    }',

        '    left++;',

        '    right--;',

        '}',

        '',

        'return {{2}};',

      ],

      keywords: [

        '0',

        'right',

        'str.charAt(right)',

        'true',

      ],

      correctAnswers: [

        '0',

        'str.charAt(right)',

        'true',

      ],

    ),

    DSAQuestion(

      topic: 'HASHMAP',

      difficulty: 'MEDIUM',

      question:

          'Given an array and a target value, determine whether two elements add up to the target.',

      input: 'arr = [2, 7, 11, 15], target = 9',

      output: 'true',

      hint:

          'For every element, check whether the value needed to reach the target has already been seen.',

      code: [

        'HashMap<Integer, Integer> map = new HashMap<>();',

        '',

        'for (int num : arr) {',

        '    int needed = target - num;',

        '',

        '    if (map.containsKey({{0}})) {',

        '        return {{1}};',

        '    }',

        '',

        '    map.put(num, {{2}});',

        '}',

        '',

        'return false;',

      ],

      keywords: [

        'needed',

        'true',

        '1',

        'num',

      ],

      correctAnswers: [

        'needed',

        'true',

        '1',

      ],

    ),

    DSAQuestion(

      topic: 'BINARY SEARCH',

      difficulty: 'MEDIUM',

      question:

          'Complete the binary search code for a sorted array to find the target element.',

      input: 'arr = [1, 3, 5, 7, 9], target = 7',

      output: 'index 3',

      hint:

          'The middle element divides the sorted array into two possible search regions.',

      code: [

        'int low = 0;',

        'int high = arr.length - 1;',

        '',

        'while (low <= high) {',

        '    int mid = (low + high) / 2;',

        '',

        '    if (arr[mid] == target) {',

        '        return {{0}};',

        '    }',

        '    else if (arr[mid] < target) {',

        '        low = {{1}};',

        '    }',

        '    else {',

        '        high = {{2}};',

        '    }',

        '}',

      ],

      keywords: [

        'mid',

        'mid + 1',

        'mid - 1',

        'target',

      ],

      correctAnswers: [

        'mid',

        'mid + 1',

        'mid - 1',

      ],

    ),

    DSAQuestion(

      topic: 'STACK',

      difficulty: 'CHALLENGE',

      question:

          'Complete the code to check whether brackets in a string are balanced using a stack.',

      input: '"({[]})"',

      output: 'true',

      hint:

          'When a closing bracket appears, compare it with the most recently opened bracket.',

      code: [

        'Stack<Character> stack = new Stack<>();',

        '',

        'for (char ch : str.toCharArray()) {',

        '    if (ch == \'(\' || ch == \'[\' || ch == \'{\') {',

        '        stack.push(ch);',

        '    }',

        '    else {',

        '        if (stack.isEmpty()) {',

        '            return false;',

        '        }',

        '',

        '        char top = stack.pop();',

        '',

        '        if ((ch == \')\' && top != \'(\') ||',

        '            (ch == \']\' && top != \'[\') ||',

        '            (ch == \'}\' && top != \'{{0}}\')) {',

        '            return false;',

        '        }',

        '    }',

        '}',

        '',

        'return stack.isEmpty();',

      ],

      keywords: [

        '{',

        '[',

        '(',

        '}',

      ],

      correctAnswers: [

        '{',

      ],

    ),

  ];

  // ============================================================\*

  // ANSWER HANDLING\*

  // ============================================================\*

  void _resetAnswers() {

    selectedAnswers = List<String>.filled(

      questions[currentQuestion].correctAnswers.length,

      '',

    );

  }

  void selectKeyword(String keyword) {

    if (answered) return;

    final emptyIndex = selectedAnswers.indexWhere(

      (answer) => answer.isEmpty,

    );

    if (emptyIndex == -1) {

      return;

    }

    setState(() {

      selectedAnswers[emptyIndex] = keyword;

    });

  }

  void removeAnswer(int index) {

    if (answered) return;

    setState(() {

      selectedAnswers[index] = '';

    });

  }

  void submitAnswer() {

    if (answered) return;

    if (selectedAnswers.any(

      (answer) => answer.isEmpty,

    )) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: const Text(

            'Please fill all the blanks before submitting.',

          ),

          backgroundColor: themeConfig.accent,

        ),

      );

      return;

    }

    final question = questions[currentQuestion];

    bool correct = true;

    for (

      int i = 0;

      i < question.correctAnswers.length;

      i++

    ) {

      if (selectedAnswers[i] !=

          question.correctAnswers[i]) {

        correct = false;

        break;

      }

    }

    setState(() {

      answered = true;

      if (correct) {

        score++;

      }

    });

  }

  void nextQuestion() {

    if (!answered) return;

    if (currentQuestion <

        questions.length - 1) {

      setState(() {

        currentQuestion++;

        answered = false;

        showSolution = false;

        _resetAnswers();

      });

    } else {

      _showResult();

    }

  }

  // ============================================================\*

  // RESULT\*

  // ============================================================\*

  void _showResult() {

    final percentage =

        ((score / questions.length) * 100).round();

    String title;

    String message;

    int xp;

    if (score == 5) {

      title = 'LEVEL MASTERED! 🎉';

      message =

          'Excellent! You solved all the coding challenges.';

      xp = 150;

    } else if (score >= 4) {

      title = 'GREAT WORK! ⭐';

      message =

          'You have a strong understanding of these DSA concepts.';

      xp = 120;

    } else if (score >= 3) {

      title = 'GOOD PROGRESS! 💪';

      message =

          'You understand the basics. Keep practicing coding problems.';

      xp = 80;

    } else {

      title = 'KEEP PRACTICING! 🔄';

      message =

          'Review the concepts and try the coding challenges again.';

      xp = 30;

    }

    final completedLevel = widget.level;

    SharedPreferences.getInstance().then(

      (prefs) async {

        final completedLevels =

            prefs.getStringList('completed_levels') ??

                [];

        final levelString =

            completedLevel.toString();

        if (!completedLevels.contains(levelString)) {

          completedLevels.add(levelString);

          await prefs.setStringList(

            'completed_levels',

            completedLevels,

          );

        }

      },

    );

    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (_) {

        return AlertDialog(

          backgroundColor: themeConfig.surface,

          title: Text(

            title,

            style: TextStyle(

              color: themeConfig.accent,

              fontWeight: FontWeight.w900,

            ),

          ),

          content: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              Text(

                '$score / ${questions.length}',

                style: TextStyle(

                  color: themeConfig.accent,

                  fontSize: 42,

                  fontWeight: FontWeight.w900,

                ),

              ),

              const SizedBox(height: 5),

              Text(

                '$percentage% Accuracy',

                style: const TextStyle(

                  color: Colors.white70,

                ),

              ),

              const SizedBox(height: 18),

              Text(

                message,

                textAlign: TextAlign.center,

                style: const TextStyle(

                  color: Colors.white70,

                  height: 1.5,

                ),

              ),

              const SizedBox(height: 15),

              Text(

                '+$xp XP',

                style: TextStyle(

                  color: themeConfig.accent,

                  fontSize: 20,

                  fontWeight: FontWeight.w900,

                ),

              ),

            ],

          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);

                Navigator.pop(context);

              },

              child: Text(

                'CONTINUE',

                style: TextStyle(

                  color: themeConfig.accent,

                  fontWeight: FontWeight.bold,

                ),

              ),

            ),

          ],

        );

      },

    );

  }

  // ============================================================\*

  // BUILD\*

  // ============================================================\*

  @override

  Widget build(BuildContext context) {

    final question = questions[currentQuestion];

    return Scaffold(

      backgroundColor: themeConfig.background,

      appBar: AppBar(

        backgroundColor: Colors.transparent,

        foregroundColor: Colors.white,

        elevation: 0,

        title: Text(

          'LEVEL ${widget.level} • DSA',

          style: const TextStyle(

            fontWeight: FontWeight.w900,

            letterSpacing: 1.1,

          ),

        ),

      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.fromLTRB(

            18,

            8,

            18,

            30,

          ),

          child: Column(

            crossAxisAlignment:

                CrossAxisAlignment.start,

            children: [

              _buildLiveHeader(question),

              const SizedBox(height: 14),

              _buildProgress(),

              const SizedBox(height: 18),

              // DESCRIPTION + SOLUTION\*

              _buildQuestionWorkspace(question),

              const SizedBox(height: 22),

              if (answered)

                _buildAnswerResult(question),

              const SizedBox(height: 18),

              _buildActionButton(),

            ],

          ),

        ),

      ),

    );

  }

  // ============================================================\*

  // RESPONSIVE QUESTION WORKSPACE\*

  // ============================================================\*

  Widget _buildQuestionWorkspace(

    DSAQuestion question,

  ) {

    return LayoutBuilder(

      builder: (context, constraints) {

        // ======================================================

        // DESKTOP / TABLET

        // ======================================================

        if (constraints.maxWidth >= 800) {

          return Row(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Expanded(

                flex: 1,

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [

                    _buildDescription(question),

                    const SizedBox(height: 18),

                    _buildHint(question),

                  ],

                ),

              ),

              const SizedBox(width: 18),

              Expanded(

                flex: 1,

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [

                    _buildSolution(question),

                    const SizedBox(height: 18),

                    _buildKeywords(question),

                  ],

                ),

              ),

            ],

          );

        }

        // ======================================================

        // MOBILE - DESCRIPTION / SOLUTION TOGGLE

        // ======================================================

        return Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            _buildDescriptionSolutionToggle(),

            const SizedBox(height: 18),

            _buildMobileToggleContent(question),

          ],

        );

      },

    );

  }

  // ============================================================

  // MOBILE DESCRIPTION / SOLUTION TOGGLE

  // ============================================================

  Widget _buildDescriptionSolutionToggle() {

    return Container(

      height: 52,

      padding: const EdgeInsets.all(4),

      decoration: BoxDecoration(

        color: themeConfig.surface.withValues(alpha: 0.9),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(

          color: themeConfig.primary.withValues(alpha: 0.35),

        ),

      ),

      child: Row(

        children: [

          Expanded(

            child: GestureDetector(

              onTap: () {

                setState(() {

                showSolution = false;

                });

              },

              child: AnimatedContainer(

                duration: const Duration(milliseconds: 220),

                alignment: Alignment.center,

                decoration: BoxDecoration(

                  color: !showSolution

                      ? themeConfig.accent

                      : Colors.transparent,

                  borderRadius: BorderRadius.circular(12),

                ),

                child: Text(

                  'DESCRIPTION',

                  style: TextStyle(

                    color: !showSolution

                        ? themeConfig.background

                        : Colors.white70,

                    fontSize: 13,

                    fontWeight: FontWeight.w900,

                    letterSpacing: 0.5,

                  ),

                ),

              ),

            ),

          ),

          Expanded(

            child: GestureDetector(

              onTap: () {

                setState(() {

                  showSolution = true;

                });

              },

              child: AnimatedContainer(

                duration: const Duration(milliseconds: 220),

                alignment: Alignment.center,

                decoration: BoxDecoration(

                  color: showSolution

                      ? themeConfig.accent

                      : Colors.transparent,

                  borderRadius: BorderRadius.circular(12),

                ),

                child: Text(

                  'SOLUTION',

                  style: TextStyle(

                    color: showSolution

                        ? themeConfig.background

                        : Colors.white70,

                    fontSize: 13,

                    fontWeight: FontWeight.w900,

                    letterSpacing: 0.5,

                  ),

                ),

              ),

            ),

          ),

        ],

      ),

    );

  }

  Widget _buildMobileToggleContent(DSAQuestion question) {

    return AnimatedSwitcher(

      duration: const Duration(milliseconds: 250),

      transitionBuilder: (child, animation) {

        return FadeTransition(

          opacity: animation,

          child: SlideTransition(

            position: Tween<Offset>(

              begin: const Offset(0.05, 0),

              end: Offset.zero,

            ).animate(animation),

            child: child,

          ),

        );

      },

      child: showSolution

          ? Column(

              key: const ValueKey('solution'),

              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                _buildSolution(question),

                const SizedBox(height: 18),

                _buildKeywords(question),

              ],

            )

          : Column(

              key: const ValueKey('description'),

              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                _buildDescription(question),

                const SizedBox(height: 18),

                _buildHint(question),

              ],

            ),

    );

  }



  Widget _buildLiveHeader(

    DSAQuestion question,

  ) {

    return Row(

      children: [

        Expanded(

          child: Container(

            padding:

                const EdgeInsets.symmetric(

              horizontal: 14,

              vertical: 10,

            ),

            decoration: BoxDecoration(

              color: themeConfig.primary

                  .withValues(alpha: 0.12),

              borderRadius:

                  BorderRadius.circular(14),

              border: Border.all(

                color: themeConfig.primary

                    .withValues(alpha: 0.25),

              ),

            ),

            child: Row(

              children: [

                Icon(

                  themeConfig.icon,

                  size: 17,

                  color: themeConfig.accent,

                ),

                const SizedBox(width: 8),

                Flexible(

                  child: Text(

                    _themeName(widget.theme),

                    overflow:

                        TextOverflow.ellipsis,

                    style: TextStyle(

                      color: themeConfig.accent,

                      fontSize: 11,

                      fontWeight: FontWeight.w900,

                    ),

                  ),

                ),

              ],

            ),

          ),

        ),

        const SizedBox(width: 10),

        Container(

          padding:

              const EdgeInsets.symmetric(

            horizontal: 12,

            vertical: 10,

          ),

          decoration: BoxDecoration(

            color: themeConfig.secondary

                .withValues(alpha: 0.55),

            borderRadius:

                BorderRadius.circular(14),

            border: Border.all(

              color: themeConfig.primary

                  .withValues(alpha: 0.25),

            ),

          ),

          child: Text(

            question.difficulty,

            style: TextStyle(

              color: themeConfig.accent,

              fontSize: 10,

              fontWeight: FontWeight.w900,

              letterSpacing: 0.7,

            ),

          ),

        ),

      ],

    );

  }

  String _themeName(AppTheme theme) {

    switch (theme) {

      case AppTheme.forest:

        return 'ENCHANTED FOREST';

      case AppTheme.cyberpunk:

        return 'CYBER CITY';

      case AppTheme.kingdom:

        return 'CODING KINGDOM';

    }

  }

  // ============================================================\*

  // PROGRESS\*

  // ============================================================\*

  Widget _buildProgress() {

    final progress =

        (currentQuestion + 1) /

            questions.length;

    return Column(

      crossAxisAlignment:

          CrossAxisAlignment.start,

      children: [

        Row(

          mainAxisAlignment:

              MainAxisAlignment.spaceBetween,

          children: [

            Text(

              'QUESTION ${currentQuestion + 1}/${questions.length}',

              style: TextStyle(

                color: themeConfig.accent,

                fontSize: 12,

                fontWeight: FontWeight.w900,

                letterSpacing: 1.2,

              ),

            ),

            Text(

              '$score correct',

              style: const TextStyle(

                color: Colors.white60,

                fontSize: 12,

              ),

            ),

          ],

        ),

        const SizedBox(height: 9),

        ClipRRect(

          borderRadius:

              BorderRadius.circular(20),

          child: LinearProgressIndicator(

            value: progress,

            minHeight: 8,

            backgroundColor:

                Colors.white10,

            valueColor:

                AlwaysStoppedAnimation<Color>(

              themeConfig.accent,

            ),

          ),

        ),

      ],

    );

  }

  // ============================================================\*

  // DESCRIPTION\*

  // ============================================================\*

  Widget _buildDescription(

    DSAQuestion question,

  ) {

    return _card(

      child: Column(

        crossAxisAlignment:

            CrossAxisAlignment.start,

        children: [

          _sectionTitle('DESCRIPTION'),

          const SizedBox(height: 16),

          Text(

            'Question',

            style: TextStyle(

              color: themeConfig.accent,

              fontSize: 14,

              fontWeight: FontWeight.w900,

            ),

          ),

          const SizedBox(height: 8),

          Text(

            question.question,

            style: const TextStyle(

              color: Colors.white,

              fontSize: 17,

              height: 1.5,

              fontWeight: FontWeight.w700,

            ),

          ),

          const SizedBox(height: 18),

          _inputOutputBox(

            'INPUT',

            question.input,

          ),

          const SizedBox(height: 10),

          _inputOutputBox(

            'OUTPUT',

            question.output,

          ),

        ],

      ),

    );

  }

  // ============================================================\*

  // INPUT / OUTPUT\*

  // ============================================================\*

  Widget _inputOutputBox(

    String title,

    String value,

  ) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(

        color: themeConfig.primary

            .withValues(alpha: 0.08),

        borderRadius:

            BorderRadius.circular(12),

        border: Border.all(

          color: themeConfig.primary

              .withValues(alpha: 0.18),

        ),

      ),

      child: RichText(

        text: TextSpan(

          children: [

            TextSpan(

              text: '$title\n',

              style: TextStyle(

                color: themeConfig.accent,

                fontWeight: FontWeight.w900,

                fontSize: 11,

              ),

            ),

            TextSpan(

              text: value,

              style: const TextStyle(

                color: Colors.white,

                fontFamily: 'monospace',

                fontSize: 13,

              ),

            ),

          ],

        ),

      ),

    );

  }

  // ============================================================\*

  // HINT\*

  // ============================================================\*

  Widget _buildHint(

    DSAQuestion question,

  ) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: themeConfig.accent

            .withValues(alpha: 0.08),

        borderRadius:

            BorderRadius.circular(16),

        border: Border.all(

          color: themeConfig.accent

              .withValues(alpha: 0.25),

        ),

      ),

      child: Row(

        crossAxisAlignment:

            CrossAxisAlignment.start,

        children: [

          const Text(

            '💡',

            style: TextStyle(

              fontSize: 24,

            ),

          ),

          const SizedBox(width: 10),

          Expanded(

            child: Column(

              crossAxisAlignment:

                  CrossAxisAlignment.start,

              children: [

                Text(

                  'HINT',

                  style: TextStyle(

                    color: themeConfig.accent,

                    fontSize: 12,

                    fontWeight: FontWeight.w900,

                  ),

                ),

                const SizedBox(height: 5),

                Text(

                  question.hint,

                  style: const TextStyle(

                    color: Colors.white70,

                    fontSize: 13,

                    height: 1.5,

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

  // ============================================================\*

  // SOLUTION / CODE\*

  // ============================================================\*

  Widget _buildSolution(

    DSAQuestion question,

  ) {

    return _card(

      child: Column(

        crossAxisAlignment:

            CrossAxisAlignment.start,

        children: [

          _sectionTitle('SOLUTION'),

          const SizedBox(height: 8),

          const Text(

            'Code with Blanks',

            style: TextStyle(

              color: Colors.white,

              fontSize: 15,

              fontWeight: FontWeight.w800,

            ),

          ),

          const SizedBox(height: 15),

          Container(

            width: double.infinity,

            padding: const EdgeInsets.all(15),

            decoration: BoxDecoration(

              color:

                  Colors.black.withValues(

                alpha: 0.35,

              ),

              borderRadius:

                  BorderRadius.circular(14),

              border: Border.all(

                color: themeConfig.primary

                    .withValues(alpha: 0.2),

              ),

            ),

            child: Column(

              crossAxisAlignment:

                  CrossAxisAlignment.start,

              children: [

                for (

                  int lineIndex = 0;

                  lineIndex < question.code.length;

                  lineIndex++

                )

                  _buildCodeLine(

                    question.code[lineIndex],

                  ),

              ],

            ),

          ),

        ],

      ),

    );

  }

  // ============================================================\*

  // CODE LINE\*

  // ============================================================\*

  Widget _buildCodeLine(

    String line,

  ) {

    final parts = line.split(

      RegExp(r'\{\{\d+\}\}'),

    );

    final matches = RegExp(

      r'\{\{(\d+)\}\}',

    ).allMatches(line);

    if (matches.isEmpty) {

      return Padding(

        padding:

            const EdgeInsets.symmetric(

          vertical: 2,

        ),

        child: Text(

          line.isEmpty ? ' ' : line,

          style: const TextStyle(

            color: Colors.white70,

            fontFamily: 'monospace',

            fontSize: 13,

            height: 1.5,

          ),

        ),

      );

    }

    final spans = <InlineSpan>[];

    for (

      int i = 0;

      i < parts.length;

      i++

    ) {

      spans.add(

        TextSpan(

          text: parts[i],

          style: const TextStyle(

            color: Colors.white70,

            fontFamily: 'monospace',

            fontSize: 13,

          ),

        ),

      );

      if (i < matches.length) {

        final blankIndex =

            int.parse(

          matches

              .elementAt(i)

              .group(1)!,

        );

        spans.add(

          WidgetSpan(

            alignment:

                PlaceholderAlignment.middle,

            child: GestureDetector(

              onTap: () {

                if (!answered) {

                  removeAnswer(blankIndex);

                }

              },

              child: Container(

                constraints:

                    const BoxConstraints(

                  minWidth: 55,

                ),

                margin:

                    const EdgeInsets.symmetric(

                  horizontal: 3,

                ),

                padding:

                    const EdgeInsets.symmetric(

                  horizontal: 8,

                  vertical: 3,

                ),

                decoration: BoxDecoration(

                  color: selectedAnswers[

                              blankIndex]

                          .isEmpty

                      ? themeConfig.accent

                          .withValues(alpha: 0.15)

                      : themeConfig.accent

                          .withValues(alpha: 0.25),

                  borderRadius:

                      BorderRadius.circular(5),

                  border: Border.all(

                    color: themeConfig.accent

                        .withValues(alpha: 0.6),

                  ),

                ),

                child: Text(

                  selectedAnswers[

                              blankIndex]

                          .isEmpty

                      ? '□□□□'

                      : selectedAnswers[

                          blankIndex],

                  style: TextStyle(

                    color: themeConfig.accent,

                    fontFamily: 'monospace',

                    fontSize: 12,

                    fontWeight:

                        FontWeight.w900,

                  ),

                ),

              ),

            ),

          ),

        );

      }

    }

    return Padding(

      padding:

          const EdgeInsets.symmetric(

        vertical: 2,

      ),

      child: RichText(

        text: TextSpan(

          children: spans,

        ),

      ),

    );

  }

  // ============================================================\*

  // KEYWORDS\*

  // ============================================================\*

  Widget _buildKeywords(

    DSAQuestion question,

  ) {

    return _card(

      child: Column(

        crossAxisAlignment:

            CrossAxisAlignment.start,

        children: [

          _sectionTitle(

            'KEYWORDS TO FILL THE BLANKS',

          ),

          const SizedBox(height: 14),

          const Text(

            'Tap a keyword to place it in the next blank.',

            style: TextStyle(

              color: Colors.white60,

              fontSize: 12,

            ),

          ),

          const SizedBox(height: 12),

          Wrap(

            spacing: 9,

            runSpacing: 9,

            children:

                question.keywords.map(

              (keyword) {

                return GestureDetector(

                  onTap: () =>

                      selectKeyword(keyword),

                  child: AnimatedContainer(

                    duration:

                        const Duration(

                      milliseconds: 150,

                    ),

                    padding:

                        const EdgeInsets.symmetric(

                      horizontal: 13,

                      vertical: 9,

                    ),

                    decoration:

                        BoxDecoration(

                      color: themeConfig

                          .primary

                          .withValues(

                        alpha: 0.15,

                      ),

                      borderRadius:

                          BorderRadius.circular(

                        10,

                      ),

                      border: Border.all(

                        color: themeConfig

                            .primary

                            .withValues(

                          alpha: 0.35,

                        ),

                      ),

                    ),

                    child: Text(

                      keyword,

                      style: TextStyle(

                        color:

                            themeConfig.accent,

                        fontFamily:

                            'monospace',

                        fontSize: 12,

                        fontWeight:

                            FontWeight.w800,

                      ),

                    ),

                  ),

                );

              },

            ).toList(),

          ),

        ],

      ),

    );

  }

  // ============================================================\*

  // ANSWER RESULT\*

  // ============================================================\*

  Widget _buildAnswerResult(

    DSAQuestion question,

  ) {

    bool correct = true;

    for (

      int i = 0;

      i < question.correctAnswers.length;

      i++

    ) {

      if (selectedAnswers[i] !=

          question.correctAnswers[i]) {

        correct = false;

        break;

      }

    }

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: (correct

                ? Colors.greenAccent

                : Colors.orangeAccent)

            .withValues(alpha: 0.08),

        borderRadius:

            BorderRadius.circular(16),

        border: Border.all(

          color: (correct

                  ? Colors.greenAccent

                  : Colors.orangeAccent)

              .withValues(alpha: 0.3),

        ),

      ),

      child: Column(

        crossAxisAlignment:

            CrossAxisAlignment.start,

        children: [

          Text(

            correct

                ? '✅ CORRECT'

                : '💡 REVIEW THE SOLUTION',

            style: TextStyle(

              color: correct

                  ? Colors.greenAccent

                  : themeConfig.accent,

              fontSize: 13,

              fontWeight: FontWeight.w900,

            ),

          ),

          const SizedBox(height: 10),

          if (!correct)

            const Text(

              'Correct answers:',

              style: TextStyle(

                color: Colors.white70,

                fontSize: 12,

              ),

            ),

          if (!correct)

            const SizedBox(height: 6),

          if (!correct)

            Wrap(

              spacing: 7,

              runSpacing: 7,

              children:

                  question.correctAnswers.map(

                (answer) {

                  return Container(

                    padding:

                        const EdgeInsets.symmetric(

                      horizontal: 8,

                      vertical: 5,

                    ),

                    decoration:

                        BoxDecoration(

                      color: themeConfig

                          .primary

                          .withValues(

                        alpha: 0.15,

                      ),

                      borderRadius:

                          BorderRadius.circular(

                        6,

                      ),

                    ),

                    child: Text(

                      answer,

                      style: TextStyle(

                        color:

                            themeConfig.accent,

                        fontFamily:

                            'monospace',

                        fontSize: 12,

                      ),

                    ),

                  );

                },

              ).toList(),

            ),

        ],

      ),

    );

  }

  // ============================================================\*

  // ACTION BUTTON\*

  // ============================================================\*

  Widget _buildActionButton() {

    return SizedBox(

      width: double.infinity,

      height: 54,

      child: ElevatedButton(

        onPressed:

            answered

                ? nextQuestion

                : submitAnswer,

        style:

            ElevatedButton.styleFrom(

          backgroundColor:

              themeConfig.accent,

          foregroundColor:

              themeConfig.background,

          shape:

              RoundedRectangleBorder(

            borderRadius:

                BorderRadius.circular(15),

          ),

        ),

        child: Text(

          answered

              ? currentQuestion ==

                      questions.length - 1

                  ? 'VIEW RESULT'

                  : 'NEXT QUESTION'

              : 'SUBMIT ANSWER',

          style: const TextStyle(

            fontWeight: FontWeight.w900,

            letterSpacing: 0.8,

          ),

        ),

      ),

    );

  }

  // ============================================================\*

  // REUSABLE CARD\*

  // ============================================================\*

  Widget _card({

    required Widget child,

  }) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: themeConfig.surface

            .withValues(alpha: 0.82),

        borderRadius:

            BorderRadius.circular(20),

        border: Border.all(

          color: themeConfig.primary

              .withValues(alpha: 0.25),

        ),

      ),

      child: child,

    );

  }

  // ============================================================\*

  // SECTION TITLE\*

  // ============================================================\*

  Widget _sectionTitle(

    String title,

  ) {

    return Text(

      title,

      style: TextStyle(

        color: themeConfig.accent,

        fontSize: 14,

        fontWeight: FontWeight.w900,

        letterSpacing: 1.1,

      ),

    );

  }

}

// ============================================================\*

// DSA QUESTION MODEL\*

// ============================================================\*

class DSAQuestion {

  final String topic;

  final String difficulty;

  final String question;

  final String input;

  final String output;

  final String hint;

  final List<String> code;

  final List<String> keywords;

  final List<String> correctAnswers;

  const DSAQuestion({

    required this.topic,

    required this.difficulty,

    required this.question,

    required this.input,

    required this.output,

    required this.hint,

    required this.code,

    required this.keywords,

    required this.correctAnswers,

  });

}
