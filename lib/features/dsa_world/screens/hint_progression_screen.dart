import 'package:flutter/material.dart';
import '../../../services/dsa_service.dart';

class HintProgressionScreen extends StatefulWidget {
  final String problemId;

  const HintProgressionScreen({Key? key, required this.problemId})
    : super(key: key);

  @override
  State<HintProgressionScreen> createState() => _HintProgressionScreenState();
}

class _HintProgressionScreenState extends State<HintProgressionScreen> {
  late Future<Map<String, dynamic>> _problemFuture;
  int currentHintLevel = 0;
  Map<int, String> revealedHints = {};

  @override
  void initState() {
    super.initState();
    _problemFuture = DSAService.getProblem(widget.problemId);
  }

  Future<void> _requestHint(int hintLevel) async {
    try {
      final result = await DSAService.getHint(widget.problemId, hintLevel);
      final hint = result['hint'] ?? '';

      setState(() {
        revealedHints[hintLevel] = hint;
        currentHintLevel = hintLevel + 1;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _backToChallenge() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hints'), centerTitle: true),
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
          final hints = List<String>.from(problem['hints'] ?? []);

          if (hints.isEmpty) {
            return const Center(child: Text('No hints available'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progressive Hints',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Each hint guides you toward the solution. Try to solve before asking for the next one!',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ...hints.asMap().entries.map((entry) {
                    final hintLevel = entry.key;
                    final hintText = entry.value;
                    final isRevealed = revealedHints.containsKey(hintLevel);
                    final levelName = _getHintLevelName(hintLevel);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _HintCard(
                        level: hintLevel + 1,
                        levelName: levelName,
                        hintText: hintText,
                        isRevealed: isRevealed,
                        canRequest: hintLevel == currentHintLevel,
                        onRequest: () => _requestHint(hintLevel),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '⚡ Remember',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Using hints reduces your XP reward. Try to think through the problem first!',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _backToChallenge,
                      child: const Text(
                        'Back to Question',
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

  String _getHintLevelName(int level) {
    switch (level) {
      case 0:
        return 'Direction';
      case 1:
        return 'Observation';
      case 2:
        return 'Pattern';
      case 3:
        return 'Reveal';
      default:
        return 'Hint';
    }
  }
}

class _HintCard extends StatelessWidget {
  final int level;
  final String levelName;
  final String hintText;
  final bool isRevealed;
  final bool canRequest;
  final VoidCallback onRequest;

  const _HintCard({
    required this.level,
    required this.levelName,
    required this.hintText,
    required this.isRevealed,
    required this.canRequest,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRevealed
            ? Colors.blue.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        border: Border.all(
          color: isRevealed ? Colors.blue : Colors.grey,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hint $level: $levelName',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isRevealed ? Colors.blue : Colors.grey,
                    ),
                  ),
                  if (!isRevealed)
                    const Text(
                      'Click to reveal',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
              if (isRevealed)
                const Icon(Icons.check_circle, color: Colors.blue),
            ],
          ),
          if (isRevealed) ...[
            const SizedBox(height: 12),
            Text(hintText, style: const TextStyle(fontSize: 13, height: 1.5)),
          ] else if (canRequest) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onPressed: onRequest,
                child: const Text(
                  'Reveal Hint',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Reveal earlier hints first',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
