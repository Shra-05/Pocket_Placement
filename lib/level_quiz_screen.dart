import 'package:flutter/material.dart';


class LevelQuizScreen extends StatefulWidget {
  final int level;
  final Color accentColor;

  const LevelQuizScreen({
    super.key,
    required this.level,
    required this.accentColor,
  });

  @override
  State<LevelQuizScreen> createState() => _LevelQuizScreenState();
}

class _LevelQuizScreenState extends State<LevelQuizScreen> {
  int currentQuestion = 0;
  int score = 0;
  int? selectedAnswer;
  bool answered = false;

  final List<QuizQuestion> questions = const [
    QuizQuestion(
      question:
          'A student has scores of 70, 65, and 60. What should you calculate first?',
      options: [
        'The average immediately',
        'The total of the three scores',
        'The highest score',
        'The lowest score',
      ],
      correctAnswer: 1,
      explanation:
          'The problem first asks for the total score, so the three scores should be added.',
    ),
    QuizQuestion(
      question:
          'The student qualifies when the total score is 180 or more. Which condition represents this rule?',
      options: [
        'total < 180',
        'total == 180',
        'total >= 180',
        'total > 180',
      ],
      correctAnswer: 2,
      explanation:
          '"180 or more" includes 180, so the correct condition is total >= 180.',
    ),
    QuizQuestion(
      question:
          'Which programming concept is most suitable for deciding whether the student qualifies?',
      options: [
        'if / else',
        'Binary Search',
        'Recursion',
        'Linked List',
      ],
      correctAnswer: 0,
      explanation:
          'The program needs to make a decision based on a condition, which is exactly what if / else is used for.',
    ),
    QuizQuestion(
      question:
          'If the three scores are 70, 65, and 60, what is the total?',
      options: [
        '185',
        '195',
        '175',
        '180',
      ],
      correctAnswer: 3,
      explanation:
          '70 + 65 + 60 = 195. Therefore, the student qualifies.',
    ),
    QuizQuestion(
      question:
          'What is the time complexity of this problem when only three scores are processed?',
      options: [
        'O(n)',
        'O(log n)',
        'O(1)',
        'O(n²)',
      ],
      correctAnswer: 2,
      explanation:
          'The problem always processes exactly three values, so the amount of work does not grow with input size. Therefore it is O(1).',
    ),
  ];

  void selectAnswer(int index) {
    if (answered) return;

    setState(() {
      selectedAnswer = index;
      answered = true;

      if (index == questions[currentQuestion].correctAnswer) {
        score++;
      }
    });
  }

  void nextQuestion() {
    if (!answered) return;

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        answered = false;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    final percentage = ((score / questions.length) * 100).round();

    String title;
    String message;
    int xp;

    if (score == 5) {
      title = 'LEVEL MASTERED! 🎉';
      message = 'Excellent! You understood the core concepts.';
      xp = 150;
    } else if (score >= 4) {
      title = 'GREAT WORK! ⭐';
      message = 'You have a strong understanding of this level.';
      xp = 120;
    } else if (score >= 3) {
      title = 'GOOD PROGRESS! 💪';
      message = 'You understand the basics. A little more practice will help.';
      xp = 80;
    } else {
      title = 'KEEP PRACTICING! 🔄';
      message = 'Revisit the intuition and hints before trying again.';
      xp = 30;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF120A25),
          title: Text(
            title,
            style: TextStyle(
              color: widget.accentColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score / ${questions.length}',
                style: const TextStyle(
                  color: Colors.white,
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
                  color: widget.accentColor,
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
              child: const Text('CONTINUE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];

    return Scaffold(
      backgroundColor: const Color(0xFF070313),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'LEVEL ${widget.level} QUIZ',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgress(),
              const SizedBox(height: 18),
              _buildQuestion(question),
              const SizedBox(height: 18),
              _buildOptions(question),
              const SizedBox(height: 18),
              if (answered) _buildExplanation(question),
              const SizedBox(height: 22),
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    final progress = (currentQuestion + 1) / questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'QUESTION ${currentQuestion + 1}/${questions.length}',
              style: TextStyle(
                color: widget.accentColor,
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
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.accentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion(QuizQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Text(
        question.question,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          height: 1.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildOptions(QuizQuestion question) {
    return Column(
      children: [
        for (int i = 0; i < question.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _optionTile(
              index: i,
              text: question.options[i],
              correctAnswer: question.correctAnswer,
            ),
          ),
      ],
    );
  }

  Widget _optionTile({
    required int index,
    required String text,
    required int correctAnswer,
  }) {
    final isSelected = selectedAnswer == index;
    final isCorrect = index == correctAnswer;

    Color borderColor = Colors.white.withValues(alpha: 0.12);

    if (answered && isCorrect) {
      borderColor = Colors.greenAccent;
    } else if (answered && isSelected && !isCorrect) {
      borderColor = Colors.redAccent;
    } else if (isSelected) {
      borderColor = widget.accentColor;
    }

    return GestureDetector(
      onTap: () => selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected || (answered && isCorrect) ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.accentColor.withValues(alpha: 0.12),
              ),
              child: Text(
                String.fromCharCode(65 + index),
                style: TextStyle(
                  color: widget.accentColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            if (answered && isCorrect)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.greenAccent,
              ),
            if (answered && isSelected && !isCorrect)
              const Icon(
                Icons.cancel_rounded,
                color: Colors.redAccent,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation(QuizQuestion question) {
    final correct = selectedAnswer == question.correctAnswer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (correct ? Colors.greenAccent : Colors.orangeAccent)
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (correct ? Colors.greenAccent : Colors.orangeAccent)
              .withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            correct ? '✅ CORRECT' : '💡 LEARN FROM IT',
            style: TextStyle(
              color: correct ? Colors.greenAccent : Colors.orangeAccent,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.explanation,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: answered ? nextQuestion : null,
        child: Text(
          currentQuestion == questions.length - 1
              ? 'VIEW RESULT'
              : 'NEXT QUESTION',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}