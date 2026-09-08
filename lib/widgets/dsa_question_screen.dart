import 'package:flutter/material.dart';
import 'dsa_question_model.dart';
import 'dsa_questions.dart';
import 'dsa_animations/array_max_animation.dart';

class DSAQuestionScreen extends StatefulWidget {
  const DSAQuestionScreen({super.key});

  @override
  State<DSAQuestionScreen> createState() => _DSAQuestionScreenState();
}

class _DSAQuestionScreenState extends State<DSAQuestionScreen> {
  int currentQuestion = 0;

  final List<String> userAnswers = [];

  @override
  Widget build(BuildContext context) {
    final DSAQuestion question = dsaQuestions[currentQuestion];

    return Scaffold(
      appBar: AppBar(title: const Text("DSA")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Question ${currentQuestion + 1}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Text(
              question.topic,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Text(question.question, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 15),

            Text("Output: ${question.output}"),

            const SizedBox(height: 25),

            // 🎬 Animated visual explanation
            if (question.topic == "Arrays") ...[
              const ArrayMaxAnimation(),
              const SizedBox(height: 25),
            ],

            Text(
              "💡 Hint",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(question.hint),

            const SizedBox(height: 25),

            Text(
              "Solution",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              question.code,
              style: const TextStyle(fontFamily: "monospace"),
            ),

            const SizedBox(height: 25),

            const Text(
              "Keywords",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children: question.keywords.map((keyword) {
                return Chip(label: Text(keyword));
              }).toList(),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  checkAnswer(question);
                },

                child: const Text("SUBMIT"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkAnswer(DSAQuestion question) {
    // Answer checking will be added next.
  }
}
