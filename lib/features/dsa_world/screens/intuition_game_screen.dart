import 'package:flutter/material.dart';
import '../../../services/dsa_service.dart';

class IntuitionGameScreen extends StatefulWidget {
  final String problemId;

  const IntuitionGameScreen({super.key, required this.problemId});

  @override
  State<IntuitionGameScreen> createState() => _IntuitionGameScreenState();
}

class _IntuitionGameScreenState extends State<IntuitionGameScreen> {
  late Future<Map<String, dynamic>> _problemFuture;

  // FIX: store the loaded problem so tap handlers can read it
  Map<String, dynamic>? _problem;

  int currentChallengeIndex = 0;
  int correctAnswers = 0;
  int? selectedOption;
  bool showFeedback = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    // FIX: save the problem data when the request finishes
    _problemFuture = DSAService.getProblem(widget.problemId).then((data) {
      _problem = Map<String, dynamic>.from(data['problem'] ?? {});
      return data;
    });
  }

  // FIX: return the stored problem instead of always returning null
  Map<String, dynamic>? _getProblem() => _problem;

  void _selectOption(int optionIndex) {
    if (showFeedback) return;

    final problem = _getProblem();
    if (problem == null) return;

    final challenges = (problem['intuitionChallenges'] as List?) ?? [];
    if (challenges.isEmpty) return;

    final challenge = challenges[currentChallengeIndex];
    final correct = optionIndex == challenge['correct'];

    setState(() {
      selectedOption = optionIndex;
      isCorrect = correct;
      showFeedback = true;

      if (correct) {
        correctAnswers++;
      }
    });
  }

  void _nextChallenge() {
    final problem = _getProblem();
    if (problem == null) return;

    final challenges = (problem['intuitionChallenges'] as List?) ?? [];
    if (currentChallengeIndex < challenges.length - 1) {
      setState(() {
        currentChallengeIndex++;
        selectedOption = null;
        showFeedback = false;
      });
    } else {
      _navigateToKeyInsight();
    }
  }

  void _requestHint() {
    Navigator.of(context).pushNamed(
      '/dsa-hint-progression',
      arguments: {'problemId': widget.problemId},
    );
  }

  void _navigateToKeyInsight() {
    Navigator.of(context).pushReplacementNamed(
      '/dsa-key-insight',
      arguments: {
        'problemId': widget.problemId,
        'correctIntuitionChallenges': correctAnswers,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intuition Challenge'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _problemFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final problem = snapshot.data?['problem'] ?? {};
          final challenges = List<Map<String, dynamic>>.from(
            problem['intuitionChallenges'] ?? [],
          );

          if (challenges.isEmpty) {
            return const Center(child: Text('No challenges found'));
          }

          if (currentChallengeIndex >= challenges.length) {
            return const Center(child: Text('All challenges completed!'));
          }

          final challenge = challenges[currentChallengeIndex];
          final question = challenge['question'] ?? '';
          final options = List<String>.from(challenge['options'] ?? []);
          final feedback = challenge['feedback'] ?? {};

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (currentChallengeIndex + 1) / challenges.length,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Question ${currentChallengeIndex + 1}/${challenges.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...options.asMap().entries.map((entry) {
                    final optionIndex = entry.key;
                    final optionText = entry.value;
                    final isSelected = selectedOption == optionIndex;
                    final isCorrectOption = optionIndex == challenge['correct'];

                    Color borderColor = Colors.grey;
                    Color backgroundColor = Colors.transparent;

                    if (showFeedback) {
                      if (isCorrectOption) {
                        borderColor = Colors.green;
                        backgroundColor = Colors.green.withValues(alpha: 0.1);
                      } else if (isSelected && !isCorrect) {
                        borderColor = Colors.red;
                        backgroundColor = Colors.red.withValues(alpha: 0.1);
                      }
                    } else if (isSelected) {
                      borderColor = Colors.blue;
                      backgroundColor = Colors.blue.withValues(alpha: 0.1);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _selectOption(optionIndex),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor, width: 2),
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: borderColor,
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? borderColor
                                      : Colors.transparent,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + optionIndex),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : borderColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              if (showFeedback && isCorrectOption)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                              if (showFeedback && isSelected && !isCorrect)
                                const Icon(Icons.cancel, color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  if (showFeedback) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        border: Border.all(
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCorrect ? '✅ Correct!' : '❌ Not quite',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isCorrect
                                ? feedback['correct'] ??
                                      'Great! You understand.'
                                : feedback['incorrect'] ??
                                      'Think more carefully about this.',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (currentChallengeIndex < challenges.length - 1)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: _nextChallenge,
                          child: const Text(
                            'Next Question',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: _navigateToKeyInsight,
                          child: const Text(
                            'See Key Insight',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _requestHint,
                        child: const Text(
                          'Get a Hint',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
