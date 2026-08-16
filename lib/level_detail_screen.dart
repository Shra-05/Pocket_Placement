import 'package:flutter/material.dart';
import 'level_quiz_screen.dart';

class LevelDetailScreen extends StatefulWidget {
  final int level;
  final String title;
  final String subtitle;
  final Color accentColor;

  const LevelDetailScreen({
    super.key,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  @override
  State<LevelDetailScreen> createState() => _LevelDetailScreenState();
}

class _LevelDetailScreenState extends State<LevelDetailScreen> {
  int visibleHints = 0;

  late final LevelContent content;

  @override
  void initState() {
    super.initState();
    content = LevelContent.forLevel(widget.level);
  }

  void showNextHint() {
    if (visibleHints < content.hints.length) {
      setState(() {
        visibleHints++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070313),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'LEVEL ${widget.level}',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              _buildProblem(),
              const SizedBox(height: 14),
              _buildIntuition(),
              const SizedBox(height: 14),
              _buildConcept(),
              const SizedBox(height: 14),
              _buildHints(),
              const SizedBox(height: 14),
              _buildComplexity(),
              const SizedBox(height: 24),
              _buildAssessmentButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            widget.accentColor.withValues(alpha: 0.25),
            Colors.black.withValues(alpha: 0.35),
          ],
        ),
        border: Border.all(color: widget.accentColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LEVEL ${widget.level}',
            style: TextStyle(
              color: widget.accentColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content.subtitle,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildProblem() {
    return _sectionCard(
      icon: Icons.flag_rounded,
      title: '🎯 THE CHALLENGE',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content.problem,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _exampleBox(),
        ],
      ),
    );
  }

  Widget _exampleBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.accentColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EXAMPLE',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Input: ${content.exampleInput}',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Output: ${content.exampleOutput}',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntuition() {
    return _sectionCard(
      icon: Icons.lightbulb_rounded,
      title: '💡 INTUITION',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < content.intuition.length; i++) ...[
            _StepText(number: '${i + 1}', text: content.intuition[i]),
            if (i != content.intuition.length - 1) const SizedBox(height: 9),
          ],
        ],
      ),
    );
  }

  Widget _buildConcept() {
    return _sectionCard(
      icon: Icons.psychology_rounded,
      title: '🧠 WHAT SHOULD I USE?',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final concept in content.concepts) _conceptChip(concept),
        ],
      ),
    );
  }

  Widget _conceptChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.accentColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: widget.accentColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHints() {
    return _sectionCard(
      icon: Icons.tips_and_updates_rounded,
      title: '🔎 HINTS',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < visibleHints; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _hintTile(number: i + 1, text: content.hints[i]),
            ),
          if (visibleHints < content.hints.length)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: showNextHint,
                icon: const Icon(Icons.lightbulb_outline_rounded),
                label: Text(
                  visibleHints == 0
                      ? 'REVEAL HINT 1'
                      : 'REVEAL HINT ${visibleHints + 1}',
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '✨ All hints revealed. You are ready for the assessment!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _hintTile({required int number, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.accentColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: widget.accentColor,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                height: 1.5,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplexity() {
    return _sectionCard(
      icon: Icons.speed_rounded,
      title: '⚡ COMPLEXITY',
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Time: ${content.timeComplexity}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Space: ${content.spaceComplexity}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LevelQuizScreen(
                level: widget.level,
                accentColor: widget.accentColor,
              ),
            ),
          );
        },
        icon: const Icon(Icons.quiz_rounded),
        label: const Text(
          'START 5 QUESTION ASSESSMENT',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: widget.accentColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: widget.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StepText extends StatelessWidget {
  final String number;
  final String text;

  const _StepText({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0x3322D3EE),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Color(0xFF22D3EE),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class LevelContent {
  final String title;
  final String subtitle;
  final String problem;
  final String exampleInput;
  final String exampleOutput;
  final List<String> intuition;
  final List<String> concepts;
  final List<String> hints;
  final String timeComplexity;
  final String spaceComplexity;

  const LevelContent({
    required this.title,
    required this.subtitle,
    required this.problem,
    required this.exampleInput,
    required this.exampleOutput,
    required this.intuition,
    required this.concepts,
    required this.hints,
    required this.timeComplexity,
    required this.spaceComplexity,
  });

  factory LevelContent.forLevel(int level) {
    switch (level) {
      case 1:
        return const LevelContent(
          title: 'CODE AWAKENING',
          subtitle: 'Pass the Placement Gate',
          problem:
              'A student has scores in three placement rounds. '
              'Calculate the total score. The student qualifies '
              'for the next round if the total score is 180 or more.',
          exampleInput: '70 65 60',
          exampleOutput: 'Qualified',
          intuition: [
            'Identify the three scores given as input.',
            'Calculate their total.',
            'Compare the total with the qualification threshold.',
            'Decide whether the student qualifies.',
          ],
          concepts: ['Variables', 'Arithmetic', 'if / else'],
          hints: [
            'What information is given, and what final value do you need to calculate?',
            'First calculate the sum of the three scores, then compare that sum with the cutoff.',
            'Your condition needs to check whether total >= 180.',
          ],
          timeComplexity: 'O(1)',
          spaceComplexity: 'O(1)',
        );

      case 2:
        return const LevelContent(
          title: 'ARRAY VAULT',
          subtitle: 'Find the pair that unlocks the vault',
          problem:
              'You are given an array of candidate scores and a target score. '
              'Find whether two different scores can combine to reach the target.',
          exampleInput: '[2, 7, 11, 15], target = 9',
          exampleOutput: '[2, 7]',
          intuition: [
            'For every number, think about what other number is needed to reach the target.',
            'Avoid checking every possible pair if you can remember values you have already seen.',
            'Use that stored information to quickly determine whether the required partner exists.',
          ],
          concepts: ['Arrays', 'Hashing', 'Complement'],
          hints: [
            'For a current value x, what value would complete the target?',
            'Think about storing values that you have already visited.',
            'A hash-based lookup can help you find the required complement quickly.',
          ],
          timeComplexity: 'O(n)',
          spaceComplexity: 'O(n)',
        );

      case 3:
        return const LevelContent(
          title: 'STRING CIPHER',
          subtitle: 'Decode the candidate identifier',
          problem:
              'A company receives two strings representing candidate IDs. '
              'Determine whether the second string can be formed by rearranging '
              'the characters of the first.',
          exampleInput: 'listen, silent',
          exampleOutput: 'True',
          intuition: [
            'The order of characters does not matter.',
            'What matters is how many times each character occurs.',
            'Compare the character frequencies in both strings.',
          ],
          concepts: ['Strings', 'Frequency Counting', 'Hash Map'],
          hints: [
            'If order does not matter, what information about each character matters?',
            'Count how often every character appears.',
            'Both strings must have identical character frequencies.',
          ],
          timeComplexity: 'O(n)',
          spaceComplexity: 'O(k)',
        );

      case 4:
        return const LevelContent(
          title: 'SEARCH PROTOCOL',
          subtitle: 'Locate the correct position',
          problem:
              'You are given a sorted list of placement scores. Find the position '
              'of a target score efficiently.',
          exampleInput: '[10, 20, 30, 40, 50], target = 40',
          exampleOutput: 'Index 3',
          intuition: [
            'The array is already sorted, so use that information.',
            'Instead of checking every element, inspect the middle.',
            'Use the comparison to eliminate half of the remaining search space.',
          ],
          concepts: ['Binary Search', 'Sorted Array', 'Divide and Conquer'],
          hints: [
            'What advantage does a sorted array give you?',
            'Look at the middle element first.',
            'Each comparison should allow you to discard roughly half the search space.',
          ],
          timeComplexity: 'O(log n)',
          spaceComplexity: 'O(1)',
        );

      case 5:
        return const LevelContent(
          title: 'SORTING ARENA',
          subtitle: 'Arrange the candidates',
          problem:
              'Given a collection of candidate scores, arrange them from the '
              'lowest score to the highest score before ranking the candidates.',
          exampleInput: '[40, 10, 30, 20]',
          exampleOutput: '[10, 20, 30, 40]',
          intuition: [
            'Identify the ordering the problem requires.',
            'Choose a sorting strategy appropriate for the data.',
            'After sorting, the candidates can be processed in the required order.',
          ],
          concepts: ['Sorting', 'Comparison', 'Arrays'],
          hints: [
            'What property should the final array have?',
            'Think about comparing elements and arranging them according to their values.',
            'Consider the standard sorting algorithms you have learned.',
          ],
          timeComplexity: 'O(n log n)',
          spaceComplexity: 'O(n)',
        );

      case 6:
        return const LevelContent(
          title: 'LINKED CHAIN',
          subtitle: 'Repair the candidate chain',
          problem:
              'Candidates are stored as nodes connected one after another. '
              'You need to understand how to move through this chain and locate a particular candidate.',
          exampleInput: '10 → 20 → 30 → 40, target = 30',
          exampleOutput: 'Found at position 3',
          intuition: [
            'Each node knows where the next node is.',
            'Start from the first node and follow the links one by one.',
            'Stop when the required value is found or the chain ends.',
          ],
          concepts: ['Linked List', 'Nodes', 'Traversal'],
          hints: [
            'Can you jump directly to an arbitrary node?',
            'Start at the head and follow the next reference.',
            'Continue until the value is found or the pointer becomes null.',
          ],
          timeComplexity: 'O(n)',
          spaceComplexity: 'O(1)',
        );

      case 7:
        return const LevelContent(
          title: 'STACK FORTRESS',
          subtitle: 'Process candidates in order',
          problem:
              'A system receives a sequence of operations where the most recently '
              'added item must be processed first. Identify the data structure that fits this behavior.',
          exampleInput: 'Push A, Push B, Pop',
          exampleOutput: 'B',
          intuition: [
            'Focus on which item should leave the structure first.',
            'The newest item is removed before older items.',
            'Identify the data structure that follows this ordering rule.',
          ],
          concepts: ['Stack', 'LIFO', 'Push / Pop'],
          hints: [
            'Which item is removed first: the oldest or newest?',
            'Think about Last In, First Out.',
            'A stack provides exactly this behavior.',
          ],
          timeComplexity: 'O(1)',
          spaceComplexity: 'O(n)',
        );

      case 8:
        return const LevelContent(
          title: 'RECURSION DUNGEON',
          subtitle: 'Break the problem into smaller quests',
          problem:
              'A problem can be solved by repeatedly solving a smaller version '
              'of the same problem. Identify the key structure required to make this approach work safely.',
          exampleInput: 'factorial(4)',
          exampleOutput: '24',
          intuition: [
            'Look for a problem that contains a smaller version of itself.',
            'Define how the current problem depends on a smaller problem.',
            'Identify the condition that stops the repeated calls.',
          ],
          concepts: ['Recursion', 'Base Case', 'Call Stack'],
          hints: [
            'What smaller version of the problem can solve the current one?',
            'Every recursive approach needs a stopping condition.',
            'Find the base case before thinking about the recursive step.',
          ],
          timeComplexity: 'O(n)',
          spaceComplexity: 'O(n)',
        );

      case 9:
        return const LevelContent(
          title: 'TREE KINGDOM',
          subtitle: 'Navigate the hierarchy',
          problem:
              'Candidates are organized in a hierarchical structure. '
              'You need to understand how to visit nodes according to a specific traversal order.',
          exampleInput: 'Root: 4, Left: 2, Right: 6',
          exampleOutput: '2, 4, 6',
          intuition: [
            'A tree has relationships between parent and child nodes.',
            'Traversal means deciding the order in which nodes are visited.',
            'Choose the traversal based on the required output order.',
          ],
          concepts: ['Trees', 'Traversal', 'Binary Search Tree'],
          hints: [
            'Which node should be visited first in the required order?',
            'For sorted output from a BST, think about the appropriate traversal.',
            'In-order traversal visits left, root, then right.',
          ],
          timeComplexity: 'O(n)',
          spaceComplexity: 'O(n)',
        );

      case 10:
        return const LevelContent(
          title: 'GRAPH BOSS',
          subtitle: 'Find the safest route',
          problem:
              'A placement network contains multiple connected locations. '
              'Find an efficient way to explore the network and reason about reaching a destination.',
          exampleInput: 'A → B → C, A → D → C',
          exampleOutput: 'A path to C exists',
          intuition: [
            'Represent the locations as vertices and connections as edges.',
            'Start from the source and explore connected locations.',
            'Choose a graph traversal or shortest-path technique based on the question.',
          ],
          concepts: ['Graphs', 'BFS / DFS', 'Shortest Path'],
          hints: [
            'What are the vertices and what are the edges?',
            'For simple reachability, think about BFS or DFS.',
            'If edge weights matter, consider a shortest-path algorithm.',
          ],
          timeComplexity: 'O(V + E)',
          spaceComplexity: 'O(V)',
        );

      default:
        return const LevelContent(
          title: 'NEW QUEST',
          subtitle: 'A new challenge awaits',
          problem: 'This level is being prepared.',
          exampleInput: 'Coming soon',
          exampleOutput: 'Coming soon',
          intuition: [
            'Break the problem into smaller parts.',
            'Identify the information you need.',
            'Choose the appropriate concept.',
          ],
          concepts: ['Problem Solving'],
          hints: [
            'Start by understanding the input.',
            'Identify the expected output.',
            'Think about the most suitable approach.',
          ],
          timeComplexity: 'TBD',
          spaceComplexity: 'TBD',
        );
    }
  }
}
