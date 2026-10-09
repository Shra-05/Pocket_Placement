import 'package:flutter/material.dart';
import '../../../services/dsa_service.dart';

class ProblemListScreen extends StatefulWidget {
  const ProblemListScreen({super.key});

  @override
  State<ProblemListScreen> createState() => _ProblemListScreenState();
}

class _ProblemListScreenState extends State<ProblemListScreen> {
  late Future<List<Map<String, dynamic>>> _problemsFuture;

  @override
  void initState() {
    super.initState();
    _problemsFuture = DSAService.getProblems();
  }

  void _reload() {
    setState(() {
      _problemsFuture = DSAService.getProblems();
    });
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a Problem'), centerTitle: true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _problemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reload,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final problems = snapshot.data ?? [];
          if (problems.isEmpty) {
            return const Center(child: Text('No problems found'));
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: problems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final problem = problems[index];
                  final title = (problem['title'] ?? '') as String;
                  final difficulty = (problem['difficulty'] ?? '') as String;
                  final topics = List<String>.from(problem['topics'] ?? []);
                  final color = _difficultyColor(difficulty);

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/dsa-problem-display',
                        arguments: {'problemId': problem['_id']},
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade700),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  topics.join(' • '),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              border: Border.all(color: color),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              difficulty,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
