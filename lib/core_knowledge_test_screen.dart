import 'package:flutter/material.dart';
import 'core_question_bank.dart';
import 'core_subject_level_screen.dart';
import 'theme_selection_screen.dart';
import 'services/core_question_pdf_service.dart';

class CoreKnowledgeTestScreen extends StatefulWidget {
  final AppTheme theme;
  final String subject;
  final int testNumber;
  final Color accentColor;
  final VoidCallback? onPassed;

  const CoreKnowledgeTestScreen({
    super.key,
    required this.theme,
    required this.subject,
    required this.testNumber,
    required this.accentColor,
    this.onPassed,
  });

  @override
  State<CoreKnowledgeTestScreen> createState() => _CoreKnowledgeTestScreenState();
}

class _CoreKnowledgeTestScreenState extends State<CoreKnowledgeTestScreen> {
  late final List<CoreLearningQuestion> questions;
  int index = 0;
  int? selected;
  int score = 0;
  bool submitted = false;
  bool finished = false;
  late final CoreTheme colors;

  @override
  void initState() {
    super.initState();
    colors = CoreTheme.fromTheme(widget.theme);
    questions = CoreQuestionBank.testFor(widget.subject, widget.testNumber);
  }

  void _submit() {
    if (selected == null || submitted) return;
    setState(() {
      submitted = true;
      if (selected == questions[index].correctOption) score++;
    });
  }

  void _next() {
    if (index < questions.length - 1) {
      setState(() {
        index++;
        selected = null;
        submitted = false;
      });
    } else {
      setState(() => finished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.testNumber == 5
        ? 'FINAL KNOWLEDGE TEST'
        : 'KNOWLEDGE TEST ${widget.testNumber}';
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.panel,
        foregroundColor: colors.text,
        title: Text('${widget.subject} • $title'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: finished ? _result() : _question(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _question() {
    if (questions.isEmpty) {
      return const Center(child: Text('No checkpoint questions available.'));
    }
    final q = questions[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value: (index + 1) / questions.length,
          color: colors.accent,
          backgroundColor: colors.border,
        ),
        const SizedBox(height: 18),
        Text('QUESTION ${index + 1} OF ${questions.length}',
            style: TextStyle(color: colors.muted, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(q.question,
            style: TextStyle(color: colors.text, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 18),
        ...List.generate(q.options.length, (i) {
          final chosen = selected == i;
          final correct = submitted && i == q.correctOption;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              onPressed: submitted ? null : () => setState(() => selected = i),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(14),
                foregroundColor: colors.text,
                backgroundColor: correct ? Colors.green.withOpacity(.18) : chosen ? colors.selected : colors.card,
                side: BorderSide(color: correct ? Colors.green : chosen ? colors.accent : colors.border),
              ),
              child: Text('${String.fromCharCode(65 + i)}. ${q.options[i]}'),
            ),
          );
        }),
        if (submitted)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(14)),
            child: Text(q.explanation, style: TextStyle(color: colors.text)),
          ),
        const Spacer(),
        ElevatedButton(
          onPressed: submitted ? _next : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.accent,
            foregroundColor: colors.background,
            padding: const EdgeInsets.all(15),
          ),
          child: Text(submitted
              ? (index == questions.length - 1 ? 'SEE RESULTS' : 'NEXT QUESTION')
              : 'SUBMIT ANSWER'),
        ),
      ],
    );
  }

  Widget _result() {
    final passed = score >= (questions.length * .7).ceil();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(passed ? Icons.emoji_events_rounded : Icons.refresh_rounded,
            size: 76, color: colors.accent),
        const SizedBox(height: 18),
        Text(passed ? 'QUEST CLEARED!' : 'KEEP PRACTICING',
            style: TextStyle(color: colors.text, fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Text('Score: $score / ${questions.length}',
            style: TextStyle(color: colors.accent, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('Pass mark: 70%. Review the previous 20 levels before trying again.',
            textAlign: TextAlign.center, style: TextStyle(color: colors.muted)),
        const SizedBox(height: 24),
        if (passed && widget.testNumber == 5)
          ElevatedButton.icon(
            onPressed: () => CoreQuestionPdfService.downloadSubjectQuestions(widget.subject),
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: const Text('DOWNLOAD SUBJECT PDF'),
          ),
        if (passed && widget.onPassed != null)
          ElevatedButton(
            onPressed: widget.onPassed,
            style: ElevatedButton.styleFrom(backgroundColor: colors.accent, foregroundColor: colors.background),
            child: const Text('CONTINUE TO NEXT LEVEL'),
          ),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('BACK TO LEVEL MAP'),
        ),
      ],
    );
  }
}
