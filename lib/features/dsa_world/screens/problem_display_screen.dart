import 'package:flutter/material.dart';
import '../../../services/dsa_service.dart';

class ProblemDisplayScreen extends StatefulWidget {
  final String problemId;

  const ProblemDisplayScreen({Key? key, required this.problemId})
    : super(key: key);

  @override
  State<ProblemDisplayScreen> createState() => _ProblemDisplayScreenState();
}

class _ProblemDisplayScreenState extends State<ProblemDisplayScreen> {
  late Future<Map<String, dynamic>> _problemFuture;
  bool _startAttemptInProgress = false;

  @override
  void initState() {
    super.initState();
    _problemFuture = DSAService.getProblem(widget.problemId);
  }

  Future<void> _startLearning() async {
    setState(() {
      _startAttemptInProgress = true;
    });

    try {
      await DSAService.startAttempt(widget.problemId);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/dsa-intuition-game',
          arguments: {'problemId': widget.problemId},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _startAttemptInProgress = false;
        });
      }
    }
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Problem'), centerTitle: true),
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final problem = snapshot.data?['problem'] ?? {};
          final title = problem['title'] ?? 'Problem';
          final difficulty = problem['difficulty'] ?? 'Unknown';
          final topics = List<String>.from(problem['topics'] ?? []);
          final problemStatement = problem['problem'] ?? '';
          final examples = List<Map<String, dynamic>>.from(
            problem['examples'] ?? [],
          );
          final source = problem['source'] ?? 'Unknown';

          final difficultyColor = difficulty == 'Easy'
              ? Colors.green
              : difficulty == 'Medium'
              ? Colors.orange
              : Colors.red;

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, child) => Opacity(
                    opacity: v,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - v)),
                      child: child,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _badge(difficulty, difficultyColor),
                            const SizedBox(width: 8),
                            _badge(source, Colors.blue),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (topics.isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: topics
                                .map(
                                  (topic) => Chip(
                                    label: Text(
                                      topic,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: Colors.grey.shade700
                                        .withValues(alpha: 0.25),
                                    side: BorderSide(
                                      color: Colors.grey.shade600.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 28),
                        ],
                        _sectionTitle('Problem Statement'),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800.withValues(alpha: 0.3),
                            border: Border.all(
                              color: Colors.grey.shade700.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            problemStatement,
                            style: const TextStyle(fontSize: 15, height: 1.7),
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (examples.isNotEmpty) ...[
                          _sectionTitle('Examples'),
                          const SizedBox(height: 12),
                          ...examples.asMap().entries.map((entry) {
                            final index = entry.key + 1;
                            final example = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800.withValues(
                                    alpha: 0.5,
                                  ),
                                  border: Border(
                                    left: BorderSide(
                                      color: Colors.blue.shade400,
                                      width: 4,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Example $index',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade300,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SelectableText(
                                      'Input: ${example['input'] ?? ''}',
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SelectableText(
                                      'Output: ${example['output'] ?? ''}',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 13,
                                        color: Colors.green.shade300,
                                      ),
                                    ),
                                    if (example['explanation'] != null &&
                                        (example['explanation'] as String)
                                            .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          example['explanation'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            height: 1.5,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.withValues(alpha: 0.2),
                                Colors.green.withValues(alpha: 0.06),
                              ],
                            ),
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '🎯 Today\'s Goal',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Understand the intuition, not write the full code.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              elevation: 6,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _startAttemptInProgress
                                ? null
                                : _startLearning,
                            child: _startAttemptInProgress
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Start Intuition Challenge',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
