import 'package:flutter/material.dart';
import '../../../services/dsa_service.dart';

class TransferQuestionScreen extends StatefulWidget {
  final String problemId;
  final int correctIntuitionChallenges;

  const TransferQuestionScreen({
    Key? key,
    required this.problemId,
    required this.correctIntuitionChallenges,
  }) : super(key: key);

  @override
  State<TransferQuestionScreen> createState() => _TransferQuestionScreenState();
}

class _TransferQuestionScreenState extends State<TransferQuestionScreen> {
  late Future<Map<String, dynamic>> _problemFuture;
  int currentQuestionIndex = 0;
  int correctTransferAnswers = 0;
  int? selectedOption;
  bool showFeedback = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    _problemFuture = DSAService.getProblem(widget.problemId);
  }

  void _selectOption(int optionIndex, List<dynamic> transferQuestions) {
    if (showFeedback || currentQuestionIndex >= transferQuestions.length)
      return;

    final question = transferQuestions[currentQuestionIndex];
    final correct = optionIndex == question['correct'];

    setState(() {
      selectedOption = optionIndex;
      isCorrect = correct;
      showFeedback = true;

      if (correct) {
        correctTransferAnswers++;
      }
    });
  }

  void _nextQuestion(List<dynamic> transferQuestions) {
    if (currentQuestionIndex < transferQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOption = null;
        showFeedback = false;
      });
    } else {
      _completeLesson();
    }
  }

  void _completeLesson() {
    Navigator.of(context).pushReplacementNamed(
      '/dsa-lesson-completion',
      arguments: {
        'problemId': widget.problemId,
        'correctIntuitionChallenges': widget.correctIntuitionChallenges,
        'correctTransferQuestions': correctTransferAnswers,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Understanding'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _problemFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final problem = snapshot.data?['problem'] ?? {};
          final transferQuestions =
              problem['transferQuestions'] as List<dynamic>? ?? [];

          if (transferQuestions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🎉 Lesson Complete!'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _completeLesson,
                      child: const Text('See Results'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (currentQuestionIndex >= transferQuestions.length) {
            return const Center(child: Text('All questions completed!'));
          }

          final question = transferQuestions[currentQuestionIndex] as Map;
          final scenario = question['scenario'] ?? '';
          final questionText = question['question'] ?? '';
          final options = List<String>.from(question['options'] ?? []);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value:
                        (currentQuestionIndex + 1) / transferQuestions.length,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Transfer Question ${currentQuestionIndex + 1}/${transferQuestions.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Scenario',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          scenario,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    questionText,
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
                    final isCorrectOption = optionIndex == question['correct'];

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
                        onTap: () =>
                            _selectOption(optionIndex, transferQuestions),
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
                  }).toList(),
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
                                ? 'You understand the pattern!'
                                : 'Review the key insight and try again.',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _nextQuestion(transferQuestions),
                        child: Text(
                          currentQuestionIndex < transferQuestions.length - 1
                              ? 'Next Question'
                              : 'Complete Lesson',
                          style: const TextStyle(
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
