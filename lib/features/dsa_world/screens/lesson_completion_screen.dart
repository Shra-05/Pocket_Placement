import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/dsa_service.dart';

class LessonCompletionScreen extends StatefulWidget {
  final String problemId;
  final int correctIntuitionChallenges;
  final int correctTransferQuestions;

  const LessonCompletionScreen({
    Key? key,
    required this.problemId,
    required this.correctIntuitionChallenges,
    required this.correctTransferQuestions,
  }) : super(key: key);

  @override
  State<LessonCompletionScreen> createState() => _LessonCompletionScreenState();
}

class _LessonCompletionScreenState extends State<LessonCompletionScreen> {
  int xpEarned = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _submitSolution();
  }

  Future<void> _submitSolution() async {
    try {
      final result = await DSAService.submitSolution(widget.problemId);

      final xp = result['xpEarned'] ?? 0;

      setState(() {
        xpEarned = xp;
        isLoading = false;
      });

      // Update local preferences
      final prefs = await SharedPreferences.getInstance();
      final currentXP = prefs.getInt('xp') ?? 0;
      final currentDSAXP = prefs.getInt('dsaTotalXP') ?? 0;

      await prefs.setInt('xp', (currentXP + xp).toInt());
      await prefs.setInt('dsaTotalXP', (currentDSAXP + xp).toInt());
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _backToDSAHome() {
    Navigator.of(context).pushReplacementNamed('/dsa-world-home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    const Text('🎉', style: TextStyle(fontSize: 80)),
                    const SizedBox(height: 24),
                    Text(
                      'Lesson Complete',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'You discovered the intuition!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.yellow.withValues(alpha: 0.1),
                        border: Border.all(color: Colors.yellow, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '+$xpEarned',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'XP Earned',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _StatRow(
                      icon: '💡',
                      label: 'Intuition Challenges',
                      value: '${widget.correctIntuitionChallenges}/6',
                    ),
                    const SizedBox(height: 12),
                    _StatRow(
                      icon: '🔄',
                      label: 'Transfer Questions',
                      value: '${widget.correctTransferQuestions}/2',
                    ),
                    const SizedBox(height: 48),
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
                          const Text(
                            '🔓 Pattern Unlocked',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Hashing / Fast Lookup',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'When you repeatedly need to know whether a value has already appeared, think about a HashSet/HashMap.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _backToDSAHome,
                        child: const Text(
                          'Try Another Question',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _backToDSAHome,
                        child: const Text(
                          'Back to DSA World',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
