import 'package:flutter/material.dart';
import 'package:pocket_placement/services/dsa_service.dart';
import 'thinking_interface_screen.dart'; // ← THIS LINE MUST BE HERE

class ProblemDisplayScreen extends StatefulWidget {
  final String problemId;

  const ProblemDisplayScreen({Key? key, required this.problemId})
    : super(key: key);

  @override
  State<ProblemDisplayScreen> createState() => _ProblemDisplayScreenState();
}

class _ProblemDisplayScreenState extends State<ProblemDisplayScreen> {
  late Future<Map<String, dynamic>> _problemFuture;
  late Map<String, dynamic> _problemData;
  bool _showExamples = false;

  @override
  void initState() {
    super.initState();
    _problemFuture = DSAService.getProblem(widget.problemId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DSA World'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _problemFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          }

          _problemData = snapshot.data ?? {};
          final problem = _problemData['problem'] ?? {};
          final progress = _problemData['userProgress'] ?? {};

          return SingleChildScrollView(
            child: Column(
              children: [
                // ========== HEADER ==========
                _buildHeader(problem, progress),

                // ========== PROBLEM TITLE & DIFFICULTY ==========
                _buildTitleSection(problem),

                // ========== DESCRIPTION ==========
                _buildDescriptionSection(problem),

                // ========== SCENARIO (The Real-World Context) ==========
                _buildScenarioSection(problem),

                // ========== KEY INSIGHTS ==========
                _buildKeyInsightsSection(problem),

                // ========== PATTERN & COMPLEXITY ==========
                _buildPatternComplexitySection(problem),

                // ========== EXAMPLES (Collapsible) ==========
                _buildExamplesSection(problem),

                // ========== ACTION BUTTONS ==========
                _buildActionButtons(problem, progress),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // ========== HEADER (Progress Badge) ==========
  Widget _buildHeader(
    Map<String, dynamic> problem,
    Map<String, dynamic> progress,
  ) {
    final status = progress['status'] ?? 'not_started';
    final attemptCount = progress['attemptCount'] ?? 0;

    Color statusColor = Colors.grey;
    String statusText = 'Not Started';
    IconData statusIcon = Icons.circle_outlined;

    if (status == 'solved') {
      statusColor = Colors.green;
      statusText = 'Solved ✓';
      statusIcon = Icons.check_circle;
    } else if (status == 'completed') {
      statusColor = Colors.blue;
      statusText = 'Completed';
      statusIcon = Icons.done;
    } else if (status == 'in_progress') {
      statusColor = Colors.orange;
      statusText = 'In Progress';
      statusIcon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
          // Status badge
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (attemptCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Attempts: $attemptCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Difficulty badge
          Row(
            children: [
              _buildDifficultyBadge(problem['difficulty'] ?? 'beginner'),
              const SizedBox(width: 12),
              Chip(
                label: Text(
                  problem['algorithmTopic']
                          ?.replaceAll('_', ' ')
                          .toUpperCase() ??
                      'ALGORITHM',
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
                backgroundColor: Colors.deepPurple.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        color = Colors.green;
        break;
      case 'intermediate':
        color = Colors.orange;
        break;
      case 'advanced':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        difficulty.toUpperCase(),
        style: const TextStyle(fontSize: 11, color: Colors.white),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  // ========== DESCRIPTION SECTION ==========
  Widget _buildDescriptionSection(Map<String, dynamic> problem) {
    final intuitiveApproach = problem['intuitiveApproach'] ?? '';

    if (intuitiveApproach.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border(
            left: BorderSide(color: Colors.green.shade400, width: 4),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🧠 Intuitive Approach',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              intuitiveApproach,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== TITLE SECTION ==========
  Widget _buildTitleSection(Map<String, dynamic> problem) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            problem['title'] ?? 'Problem',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            problem['description'] ?? '',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ========== SCENARIO SECTION ==========
  Widget _buildScenarioSection(Map<String, dynamic> problem) {
    final problemStatement = problem['problemStatement'] ?? {};
    final scenario = problemStatement['scenario'] ?? '';

    if (scenario.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          border: Border(
            left: BorderSide(color: Colors.blue.shade400, width: 4),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📍 The Scenario',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              scenario,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== KEY INSIGHTS SECTION ==========
  Widget _buildKeyInsightsSection(Map<String, dynamic> problem) {
    final insights = problem['keyInsights'] as List<dynamic>? ?? [];

    if (insights.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 Key Insights',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 12),
            ...insights.map((insight) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✓ ',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        insight.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ========== PATTERN & COMPLEXITY SECTION ==========
  Widget _buildPatternComplexitySection(Map<String, dynamic> problem) {
    final patternName = problem['patternName'] ?? '';
    final timeComplexity = problem['timeComplexity'] ?? '';
    final spaceComplexity = problem['spaceComplexity'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Pattern
          if (patternName.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('🎯 ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pattern Name',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          patternName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Complexity Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeComplexity,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Space',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        spaceComplexity,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== EXAMPLES SECTION (Collapsible) ==========
  Widget _buildExamplesSection(Map<String, dynamic> problem) {
    final problemStatement = problem['problemStatement'] ?? {};
    final examples = problemStatement['examples'] as List<dynamic>? ?? [];

    if (examples.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showExamples = !_showExamples;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text(
                    '📝 Examples',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _showExamples ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (_showExamples) ...[
            const SizedBox(height: 12),
            ...examples.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final example = entry.value as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example $index',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildExampleRow(
                      'Input:',
                      example['input']?.toString() ?? '',
                      Colors.blue.shade50,
                    ),
                    const SizedBox(height: 6),
                    _buildExampleRow(
                      'Output:',
                      example['output']?.toString() ?? '',
                      Colors.green.shade50,
                    ),
                    if (example['explanation'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Explanation:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        example['explanation'].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildExampleRow(String label, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  // ========== ACTION BUTTONS ==========
  Widget _buildActionButtons(
    Map<String, dynamic> problem,
    Map<String, dynamic> progress,
  ) {
    final status = progress['status'] ?? 'not_started';
    final hasAttempted = progress['attemptCount'] ?? 0 > 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // PRIMARY: Start/Continue Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                _startSolving(problem);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                status == 'not_started'
                    ? '🚀 Start Solving'
                    : '➡️ Continue Solving',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // SECONDARY: View Intuition
          if (hasAttempted)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to intuitive approach screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View Intuition - Coming Soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.deepPurple),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '💭 View Intuitive Approach',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ========== START SOLVING ==========
  void _startSolving(Map<String, dynamic> problem) async {
    try {
      // Start a new attempt
      final result = await DSAService.startAttempt(widget.problemId);

      print('✓ Attempt started: $result');

      // Navigate to thinking interface
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ThinkingInterfaceScreen(
              problemId: widget.problemId,
              problemData: problem,
            ),
          ),
        );
      }
    } catch (e) {
      print('✗ Error starting attempt: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ========== ERROR WIDGET ==========
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error Loading Problem',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _problemFuture = DSAService.getProblem(widget.problemId);
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
