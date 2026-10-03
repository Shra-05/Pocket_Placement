import 'package:flutter/material.dart';
import 'package:pocket_placement/services/api_service.dart';

class ThinkingInterfaceScreen extends StatefulWidget {
  final String problemId;
  final Map<String, dynamic> problemData;

  const ThinkingInterfaceScreen({
    Key? key,
    required this.problemId,
    required this.problemData,
  }) : super(key: key);

  @override
  State<ThinkingInterfaceScreen> createState() =>
      _ThinkingInterfaceScreenState();
}

class _ThinkingInterfaceScreenState extends State<ThinkingInterfaceScreen> {
  late List<Map<String, dynamic>> _checkpoints;
  int _currentCheckpointIndex = 0;
  bool _isSubmittingCheckpoint = false;
  bool _showingFeedback = false;
  String _feedbackMessage = '';
  bool _feedbackCorrect = false;

  // Checkpoint responses
  final Map<int, String> _checkpointResponses = {};

  // Final solution submission
  late TextEditingController _approachController;
  late TextEditingController _explanationController;
  late TextEditingController _thoughtProcessController;

  bool _isSubmittingSolution = false;
  bool _solutionSubmitted = false;
  Map<String, dynamic> _submissionResult = {};

  @override
  void initState() {
    super.initState();
    _approachController = TextEditingController();
    _explanationController = TextEditingController();
    _thoughtProcessController = TextEditingController();

    // Initialize checkpoints
    _initializeCheckpoints();
  }

  void _initializeCheckpoints() {
    _checkpoints = [
      {
        'number': 1,
        'type': 'pattern_identification',
        'title': '🎯 Pattern Recognition',
        'question':
            'What pattern or technique do you recognize in this problem? Describe what you see.',
        'hint':
            'Think about moving boundaries across the data. What kind of pattern might that be?',
      },
      {
        'number': 2,
        'type': 'approach_selection',
        'title': '🛠️ Choose Your Approach',
        'question':
            'Which algorithmic approach would you use to solve this efficiently? Why?',
        'hint':
            'Consider approaches that process each element only once. What data structure helps track seen elements?',
      },
      {
        'number': 3,
        'type': 'complexity_check',
        'title': '⏱️ Analyze Complexity',
        'question':
            'What is the time and space complexity of your approach? Explain why.',
        'hint':
            'For sliding window: how many times is each element processed? What needs to be stored?',
      },
    ];
  }

  @override
  void dispose() {
    _approachController.dispose();
    _explanationController.dispose();
    _thoughtProcessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_solutionSubmitted) {
      return _buildSubmissionResultScreen();
    }

    if (_currentCheckpointIndex >= _checkpoints.length) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Submit Your Solution'),
          elevation: 0,
          backgroundColor: Colors.deepPurple,
        ),
        body: _buildSolutionSubmissionScreen(),
      );
    }

    final checkpoint = _checkpoints[_currentCheckpointIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Think It Through'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Step ${_currentCheckpointIndex + 1}/${_checkpoints.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProgressBar(),
            if (!_showingFeedback)
              _buildCheckpointQuestion(checkpoint)
            else
              _buildFeedbackSection(checkpoint),
            _buildActionButtons(checkpoint),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ========== PROGRESS BAR ==========
  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.deepPurple.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reasoning Progress',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              Text(
                '${_currentCheckpointIndex + 1}/${_checkpoints.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentCheckpointIndex + 1) / _checkpoints.length,
              minHeight: 8,
              backgroundColor: Colors.deepPurple.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.deepPurple.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== CHECKPOINT QUESTION ==========
  Widget _buildCheckpointQuestion(Map<String, dynamic> checkpoint) {
    final userResponse = _checkpointResponses[checkpoint['number']] ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            checkpoint['title'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Question box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                left: BorderSide(color: Colors.blue.shade400, width: 4),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              checkpoint['question'],
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade800,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Response input
          TextField(
            controller: TextEditingController(text: userResponse),
            onChanged: (value) {
              setState(() {
                _checkpointResponses[checkpoint['number']] = value;
              });
            },
            minLines: 4,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Type your thinking here... Be specific and detailed.',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.deepPurple,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),

          // Hint button
          _buildHintButton(checkpoint),
        ],
      ),
    );
  }

  Widget _buildHintButton(Map<String, dynamic> checkpoint) {
    return TextButton.icon(
      onPressed: () {
        _showHint(checkpoint);
      },
      icon: const Icon(Icons.lightbulb_outline),
      label: const Text('💡 Get a Hint'),
      style: TextButton.styleFrom(foregroundColor: Colors.amber),
    );
  }

  void _showHint(Map<String, dynamic> checkpoint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💡 Hint'),
        content: Text(checkpoint['hint']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  // ========== FEEDBACK SECTION ==========
  Widget _buildFeedbackSection(Map<String, dynamic> checkpoint) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Feedback box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _feedbackCorrect
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              border: Border(
                left: BorderSide(
                  color: _feedbackCorrect
                      ? Colors.green.shade400
                      : Colors.orange.shade400,
                  width: 4,
                ),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _feedbackCorrect ? Icons.check_circle : Icons.info,
                      color: _feedbackCorrect
                          ? Colors.green.shade400
                          : Colors.orange.shade400,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _feedbackCorrect ? 'Great thinking!' : 'Good attempt!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _feedbackCorrect
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _feedbackMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Your response
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Response:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _checkpointResponses[checkpoint['number']] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== ACTION BUTTONS ==========
  Widget _buildActionButtons(Map<String, dynamic> checkpoint) {
    final isLastCheckpoint = _currentCheckpointIndex == _checkpoints.length - 1;
    final response = _checkpointResponses[checkpoint['number']] ?? '';

    if (_showingFeedback) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                if (isLastCheckpoint) {
                  // Move to solution submission
                  _currentCheckpointIndex = _checkpoints.length;
                  _showingFeedback = false;
                } else {
                  // Move to next checkpoint
                  _currentCheckpointIndex++;
                  _showingFeedback = false;
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isLastCheckpoint ? 'Next: Submit Solution' : 'Next Checkpoint',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: response.isEmpty
                  ? null
                  : () => _submitCheckpoint(checkpoint),
              style: ElevatedButton.styleFrom(
                backgroundColor: response.isEmpty
                    ? Colors.grey
                    : Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmittingCheckpoint
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Submit Answer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          if (response.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _checkpointResponses[checkpoint['number']] = '';
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.deepPurple),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Clear Answer',
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

  // ========== SUBMIT CHECKPOINT ==========
  void _submitCheckpoint(Map<String, dynamic> checkpoint) async {
    final response = _checkpointResponses[checkpoint['number']] ?? '';

    if (response.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide an answer first')),
      );
      return;
    }

    setState(() {
      _isSubmittingCheckpoint = true;
    });

    try {
      final result = await ApiService.submitDSACheckpoint(
        problemId: widget.problemId,
        checkpointNumber: checkpoint['number'],
        checkpointType: checkpoint['type'],
        userResponse: response,
      );

      if (mounted) {
        setState(() {
          _isSubmittingCheckpoint = false;
          _feedbackMessage = result['checkpoint']['feedbackGiven'] ?? '';
          _feedbackCorrect = result['checkpoint']['isCorrect'] ?? false;
          _showingFeedback = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmittingCheckpoint = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // ========== SOLUTION SUBMISSION SCREEN ==========
  Widget _buildSolutionSubmissionScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              '✍️ Now Submit Your Solution',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Based on your reasoning, write your final approach and explanation.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Approach field
            Text(
              '1. What approach will you use?',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _approachController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'e.g., "Sliding window with two pointers"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 20),

            // Explanation field
            Text(
              '2. Why does this approach work?',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _explanationController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Explain the key insight and how it solves the problem efficiently...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 20),

            // Thought process field
            Text(
              '3. Walk us through your thought process',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _thoughtProcessController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'How did you arrive at this solution? What did you consider?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    _approachController.text.isEmpty ||
                        _explanationController.text.isEmpty
                    ? null
                    : _submitSolution,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmittingSolution
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        '🚀 Submit Solution',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _submitSolution() async {
    setState(() {
      _isSubmittingSolution = true;
    });

    try {
      final result = await ApiService.submitDSASolution(
        problemId: widget.problemId,
        selectedApproach: _approachController.text,
        selectedApproachExplanation: _explanationController.text,
        userThoughtProcess: _thoughtProcessController.text,
      );

      if (mounted) {
        setState(() {
          _isSubmittingSolution = false;
          _solutionSubmitted = true;
          _submissionResult = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmittingSolution = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ========== SUBMISSION RESULT SCREEN ==========
  Widget _buildSubmissionResultScreen() {
    final attempt = _submissionResult['attempt'] ?? {};
    final solutionCorrect = attempt['solutionCorrect'] ?? false;
    final overallScore = attempt['overallScore'] ?? 0;
    final xpEarned = attempt['xpEarned'] ?? 0;
    final approachScore = attempt['approachScore'] ?? 0;
    final complexityScore = attempt['complexityScore'] ?? 0;
    final reasoningScore = attempt['reasoningScore'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        elevation: 0,
        backgroundColor: solutionCorrect ? Colors.green : Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Result banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: solutionCorrect
                      ? [Colors.green.shade400, Colors.green.shade600]
                      : [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    solutionCorrect ? Icons.check_circle : Icons.done,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    solutionCorrect
                        ? '✓ Excellent Reasoning!'
                        : '✓ Good Attempt!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _submissionResult['message'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Scores
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Score',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildScoreCard('Overall', overallScore),
                  const SizedBox(height: 12),
                  _buildScoreCard('Approach Selection', approachScore),
                  const SizedBox(height: 12),
                  _buildScoreCard('Complexity Analysis', complexityScore),
                  const SizedBox(height: 12),
                  _buildScoreCard('Reasoning Quality', reasoningScore),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 32),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'XP Earned',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                            Text(
                              '+$xpEarned XP',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Back to Problem',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String label, int score) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getScoreColor(score).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$score/100',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _getScoreColor(score),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.amber;
    return Colors.red;
  }
}
