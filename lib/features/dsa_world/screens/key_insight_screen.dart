import 'package:flutter/material.dart';
import '../../../services/dsa_service.dart';

class KeyInsightScreen extends StatefulWidget {
  final String problemId;
  final int correctIntuitionChallenges;

  const KeyInsightScreen({
    Key? key,
    required this.problemId,
    required this.correctIntuitionChallenges,
  }) : super(key: key);

  @override
  State<KeyInsightScreen> createState() => _KeyInsightScreenState();
}

class _KeyInsightScreenState extends State<KeyInsightScreen> {
  late Future<Map<String, dynamic>> _solutionFuture;

  @override
  void initState() {
    super.initState();
    _solutionFuture = DSAService.getSolution(widget.problemId);
  }

  void _continueToTransfer() {
    Navigator.of(context).pushReplacementNamed(
      '/dsa-transfer-question',
      arguments: {
        'problemId': widget.problemId,
        'correctIntuitionChallenges': widget.correctIntuitionChallenges,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Key Insight'), centerTitle: true),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _solutionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final solution = snapshot.data?['solution'] ?? {};
          final keyInsight = solution['keyInsight'] ?? '';
          final bruteForce = solution['bruteForceApproach'] ?? {};
          final optimal = solution['optimalApproach'] ?? {};
          final patternName = solution['patternName'] ?? '';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '💡 Key Intuition',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          keyInsight,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Approaches',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ApproachCard(
                    title: 'Brute Force',
                    description: bruteForce['description'] ?? '',
                    timeComplexity: bruteForce['timeComplexity'] ?? '',
                    spaceComplexity: bruteForce['spaceComplexity'] ?? '',
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _ApproachCard(
                    title: 'Optimized',
                    description: optimal['description'] ?? '',
                    timeComplexity: optimal['timeComplexity'] ?? '',
                    spaceComplexity: optimal['spaceComplexity'] ?? '',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 32),
                  if (patternName.isNotEmpty) ...[
                    Text(
                      'Pattern Unlocked 🔓',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        border: Border.all(color: Colors.purple),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patternName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'When you repeatedly need to know whether a value has already appeared, think about a HashSet/HashMap.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Key Takeaways',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        BulletPoint(text: 'Look for the complementary value'),
                        BulletPoint(text: 'Store previously seen values'),
                        BulletPoint(
                          text:
                              'Think about what information you actually need',
                        ),
                        BulletPoint(
                          text: 'Compare brute force vs optimized approaches',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _continueToTransfer,
                      child: const Text(
                        'Verify Understanding',
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
          );
        },
      ),
    );
  }
}

class _ApproachCard extends StatelessWidget {
  final String title;
  final String description;
  final String timeComplexity;
  final String spaceComplexity;
  final Color color;

  const _ApproachCard({
    required this.title,
    required this.description,
    required this.timeComplexity,
    required this.spaceComplexity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Time',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      timeComplexity,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Space',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      spaceComplexity,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
