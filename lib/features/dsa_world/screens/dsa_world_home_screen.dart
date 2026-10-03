import 'package:flutter/material.dart';
import 'problem_display_screen.dart';

class DSAWorldHomeScreen extends StatefulWidget {
  const DSAWorldHomeScreen({Key? key}) : super(key: key);

  @override
  State<DSAWorldHomeScreen> createState() => _DSAWorldHomeScreenState();
}

class _DSAWorldHomeScreenState extends State<DSAWorldHomeScreen> {
  // Hardcoded problem ID from seeding (STEP 5)
  static const String signalStreamProblemId = '6aa0e547dac9f9b55342b3f6';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DSA World'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ========== HERO SECTION ==========
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.deepPurple.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🧠 DSA World',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Learn algorithms through intuitive reasoning, not memorization.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatChip('0', 'Problems'),
                      const SizedBox(width: 12),
                      _buildStatChip('0', 'Mastered'),
                      const SizedBox(width: 12),
                      _buildStatChip('0', 'XP'),
                    ],
                  ),
                ],
              ),
            ),

            // ========== PROBLEMS SECTION ==========
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📚 Available Problems',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Signal Stream Problem Card
                  _buildProblemCard(
                    title: 'Signal Stream',
                    topic: 'Sliding Window',
                    difficulty: 'Beginner',
                    description:
                        'Find the longest contiguous sequence of unique signals in a stream.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProblemDisplayScreen(
                            problemId: signalStreamProblemId,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Coming Soon Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.construction,
                              color: Colors.amber,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Coming Soon',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'More DSA patterns coming soon:\n• Two Pointers\n• Hash Maps\n• Binary Search\n• Dynamic Programming\n• And much more!',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber.shade900,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String value, String label) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: Colors.white70),
          ),
        ],
      ),
      backgroundColor: Colors.white.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    );
  }

  Widget _buildProblemCard({
    required String title,
    required String topic,
    required String difficulty,
    required String description,
    required VoidCallback onTap,
  }) {
    Color difficultyColor;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        difficultyColor = Colors.green;
        break;
      case 'intermediate':
        difficultyColor = Colors.orange;
        break;
      case 'advanced':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.grey;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        topic,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: difficultyColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    difficulty,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            // CTA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: const Text(
                    '0 attempts',
                    style: TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Colors.grey.shade100,
                ),
                Icon(Icons.arrow_forward, color: Colors.deepPurple, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
