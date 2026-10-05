import 'package:flutter/material.dart';

import 'theme_selection_screen.dart';




class CoreQuestionScreen extends StatefulWidget {

  final AppTheme theme;

  final int level;
  final String topic;

  const CoreQuestionScreen({

    super.key,

    required this.theme,

    required this.level,
    this.topic = 'OS',
  });

  @override

  State<CoreQuestionScreen> createState() => _CoreQuestionScreenState();

}

class _CoreQuestionScreenState extends State<CoreQuestionScreen> {

  int selectedOption = -1;

  bool showHint = false;

  int currentStep = 0;

  late final CoreThemeColors colors;
  late final CoreSubjectQuestion question;

  @override

  void initState() {

    super.initState();

    colors = CoreThemeColors.fromTheme(widget.theme);
    question = CoreSubjectQuestion.forSubject(widget.topic, widget.level);

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: colors.background,

      body: SafeArea(

        child: LayoutBuilder(

          builder: (context, constraints) {

            if (constraints.maxWidth >= 850) {

              return _buildDesktopLayout();

            }

            return _buildMobileLayout();

          },

        ),

      ),

    );

  }

  // ============================================================

  // DESKTOP

  // ============================================================

  Widget _buildDesktopLayout() {

    return Column(

      children: [

        _buildTopBar(),

        _buildProgress(),

        Expanded(

          child: SingleChildScrollView(

            padding: const EdgeInsets.fromLTRB(28, 18, 28, 24),

            child: Column(

              children: [

                Row(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Expanded(

                      flex: 5,

                      child: Column(

                        children: [

                          _buildChallengeCard(),

                          const SizedBox(height: 14),

                          _buildOptionsCard(),

                        ],

                      ),

                    ),

                    const SizedBox(width: 18),

                    Expanded(

                      flex: 5,

                      child: Column(

                        children: [

                          _buildSimulationCard(),

                          const SizedBox(height: 14),

          
                        ],

                      ),

                    ),

                  ],

                ),

                const SizedBox(height: 18),

                _buildBottomActions(),

              ],

            ),

          ),

        ),

      ],

    );

  }

  // ============================================================

  // MOBILE

  // ============================================================

  Widget _buildMobileLayout() {

    return Column(

      children: [

        _buildTopBar(),

        _buildProgress(),

        Expanded(

          child: SingleChildScrollView(

            padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),

            child: Column(

              children: [

                _buildChallengeCard(),

                const SizedBox(height: 14),

                _buildOptionsCard(),

                const SizedBox(height: 14),

                _buildSimulationCard(),

                const SizedBox(height: 14),


                const SizedBox(height: 18),

                _buildBottomActions(),

              ],

            ),

          ),

        ),

      ],

    );

  }

  // ============================================================

  // TOP BAR

  // ============================================================

  Widget _buildTopBar() {

    return Padding(

      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),

      child: Row(

        children: [

          _smallButton(

            icon: Icons.arrow_back_rounded,

            label: 'Quit / Back',

            onPressed: () => Navigator.pop(context),

          ),

          const SizedBox(width: 18),

          Expanded(

            child: Column(

              children: [

                Text(

                  'CORE CS • ${widget.topic.toUpperCase()}',

                  textAlign: TextAlign.center,

                  style: TextStyle(

                    color: colors.text,

                    fontSize: 20,

                    fontWeight: FontWeight.w900,

                    letterSpacing: .7,

                  ),

                ),

                const SizedBox(height: 3),

                Text(

                  'LEVEL ${widget.level}',

                  style: TextStyle(

                    color: colors.accent,

                    fontSize: 12,

                    fontWeight: FontWeight.w800,

                    letterSpacing: 1.5,

                  ),

                ),

              ],

            ),

          ),

          const SizedBox(width: 12),

          const SizedBox(width: 10),

          _buildXp(),

        ],

      ),

    );

  }

  Widget _smallButton({

    required IconData icon,

    required String label,

    required VoidCallback onPressed,

  }) {

    return OutlinedButton.icon(

      onPressed: onPressed,

      icon: Icon(

        icon,

        size: 19,

        color: colors.accent,

      ),

      label: Text(

        label,

        style: TextStyle(

          color: colors.accent,

          fontWeight: FontWeight.w800,

        ),

      ),

      style: OutlinedButton.styleFrom(

        side: BorderSide(

          color: colors.accent.withValues(alpha: .45),

        ),

        backgroundColor: colors.panel,

        padding: const EdgeInsets.symmetric(

          horizontal: 12,

          vertical: 11,

        ),

        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.circular(13),

        ),

      ),

    );

  }

  Widget _buildXp() {

    return Container(

      padding: const EdgeInsets.symmetric(

        horizontal: 13,

        vertical: 10,

      ),

      decoration: BoxDecoration(

        color: colors.xpBackground,

        borderRadius: BorderRadius.circular(13),

        border: Border.all(

          color: colors.xpColor.withValues(alpha: .5),

        ),

      ),

      child: Row(

        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(

            Icons.bolt_rounded,

            color: colors.xpColor,

          ),

          const SizedBox(width: 4),

          Text(

            '450 XP',

            style: TextStyle(

              color: colors.xpColor,

              fontWeight: FontWeight.w900,

            ),

          ),

        ],

      ),

    );

  }

  // ============================================================

  // PROGRESS

  // ============================================================

  Widget _buildProgress() {

    return Padding(

      padding: const EdgeInsets.symmetric(

        horizontal: 28,

        vertical: 8,

      ),

      child: Row(

        children: [

          Expanded(

            child: ClipRRect(

              borderRadius: BorderRadius.circular(20),

              child: LinearProgressIndicator(

                value: (currentStep + 3) / 5,

                minHeight: 7,

                backgroundColor: colors.track,

                valueColor: AlwaysStoppedAnimation<Color>(

                  colors.accent,

                ),

              ),

            ),

          ),

          const SizedBox(width: 12),

          Text(

            '${(((currentStep + 3) / 5) * 100).round()}%',

            style: TextStyle(

              color: colors.accent,

              fontWeight: FontWeight.w900,

            ),

          ),

        ],

      ),

    );

  }

  // ============================================================

  // CHALLENGE CARD

  // ============================================================

  Widget _buildChallengeCard() {

    return _panel(

      title: '🎯 CHALLENGE CARD',

      icon: Icons.track_changes_rounded,

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Container(

            padding: const EdgeInsets.symmetric(

              horizontal: 13,

              vertical: 8,

            ),

            decoration: BoxDecoration(

              color: colors.levelBadgeBackground,

              borderRadius: BorderRadius.circular(18),

              border: Border.all(

                color: colors.xpColor.withValues(alpha: .55),

              ),

            ),

            child: Text(

              question.difficulty,

              style: TextStyle(

                color: colors.xpColor,

                fontWeight: FontWeight.w800,

                fontSize: 13,

              ),

            ),

          ),

          const SizedBox(height: 18),

          Text(
            question.question,
            style: TextStyle(
              color: colors.text,
              fontSize: 18,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 18),

          _buildHintBox(),

        ],

      ),

    );

  }

  Widget _buildHintBox() {

    return AnimatedContainer(

      duration: const Duration(milliseconds: 220),

      width: double.infinity,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(

        color: colors.hintBackground,

        borderRadius: BorderRadius.circular(13),

        border: Border.all(

          color: colors.hintColor.withValues(alpha: .35),

        ),

      ),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Icon(

            Icons.lightbulb_rounded,

            color: colors.hintColor,

          ),

          const SizedBox(width: 10),

          Expanded(

            child: Text(

              showHint

                  ? 'In Round Robin scheduling, when the time quantum expires, the running process is moved back to the Ready state.'

                  : 'Hint available — consider what happens when the time quantum expires.',

              style: TextStyle(

                color: colors.text,

                height: 1.45,

                fontSize: 13,

              ),

            ),

          ),

        ],

      ),

    );

  }

  // ============================================================

  // OPTIONS

  // ============================================================

  Widget _buildOptionsCard() {
    return _panel(
      title: '☷ INTERACTIVE OPTIONS',
      icon: Icons.list_rounded,
      child: Column(
        children: [
          Row(children: [
            Expanded(child: _optionButton(index: 0, letter: 'A', text: question.options[0])),
            const SizedBox(width: 10),
            Expanded(child: _optionButton(index: 1, letter: 'B', text: question.options[1])),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _optionButton(index: 2, letter: 'C', text: question.options[2])),
            const SizedBox(width: 10),
            Expanded(child: _optionButton(index: 3, letter: 'D', text: question.options[3])),
          ]),
        ],
      ),
    );
  }

  Widget _optionButton({

    required int index,

    required String letter,

    required String text,

  }) {

    final selected = selectedOption == index;

    return InkWell(

      onTap: () {

        setState(() {

          selectedOption = index;

        });

      },

      borderRadius: BorderRadius.circular(13),

      child: AnimatedContainer(

        duration: const Duration(milliseconds: 180),

        constraints: const BoxConstraints(

          minHeight: 72,

        ),

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(

          color: selected

              ? colors.selectedOptionBackground

              : colors.optionBackground,

          borderRadius: BorderRadius.circular(13),

          border: Border.all(

            color: selected

                ? colors.accent

                : colors.optionBorder,

            width: selected ? 2 : 1,

          ),

        ),

        child: Row(

          children: [

            Container(

              width: 42,

              height: 42,

              alignment: Alignment.center,

              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(10),

                border: Border.all(

                  color: selected

                      ? colors.accent

                      : colors.optionBorder,

                ),

              ),

              child: Text(

                letter,

                style: TextStyle(

                  color: selected

                      ? colors.accent

                      : colors.text,

                  fontSize: 17,

                  fontWeight: FontWeight.w900,

                ),

              ),

            ),

            const SizedBox(width: 10),

            Expanded(

              child: Text(

                text,

                style: TextStyle(

                  color: colors.text,

                  fontSize: 14,

                  fontWeight: selected

                      ? FontWeight.w900

                      : FontWeight.w600,

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

  // ============================================================

  // SIMULATION

  // ============================================================

  Widget _buildSimulationCard() {

    return _panel(

      title: '⚡ LIVE SIMULATION / CODE ARENA',

      icon: Icons.computer_rounded,

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            question.simulationTitle,

            style: TextStyle(

              color: colors.text,

              fontSize: 17,

              fontWeight: FontWeight.w900,

            ),

          ),

          const SizedBox(height: 12),

          Container(

            width: double.infinity,

            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(

              color: colors.simulationBackground,

              borderRadius: BorderRadius.circular(14),

              border: Border.all(

                color: colors.accent.withValues(alpha: .25),

              ),

            ),

            child: CoreFlowAnimation(
              labels: question.simulationLabels,
              accentColor: colors.accent,
              textColor: colors.text,
              mutedColor: colors.muted,
              step: currentStep.clamp(0, question.simulationLabels.length - 1),
              onStepChanged: (value) {
                setState(() => currentStep = value);
              },
            ),

          ),

          const SizedBox(height: 14),

          _buildCurrentStep(),

        ],

      ),

    );

  }

  Widget _buildCurrentStep() {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(

        color: colors.stepBackground,

        borderRadius: BorderRadius.circular(13),

        border: Border.all(

          color: colors.accent.withValues(alpha: .25),

        ),

      ),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Container(

            width: 32,

            height: 32,

            alignment: Alignment.center,

            decoration: BoxDecoration(

              color: colors.accent.withValues(alpha: .15),

              shape: BoxShape.circle,

            ),

            child: Text(

              '${currentStep + 1}',

              style: TextStyle(

                color: colors.accent,

                fontWeight: FontWeight.w900,

              ),

            ),

          ),

          const SizedBox(width: 10),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  'CURRENT STEP',

                  style: TextStyle(

                    color: colors.accent,

                    fontSize: 11,

                    fontWeight: FontWeight.w900,

                    letterSpacing: 1,

                  ),

                ),

                const SizedBox(height: 5),

                Text(

                  _stepDescription(),

                  style: TextStyle(

                    color: colors.text,

                    fontSize: 13,

                    height: 1.45,

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

  String _stepDescription() {
    final index = currentStep.clamp(0, question.stepDescriptions.length - 1);
    return question.stepDescriptions[index];
  }















  // ============================================================

  // BOTTOM ACTIONS

  // ============================================================

  Widget _buildBottomActions() {

    return Row(

      children: [

        Expanded(

          child: OutlinedButton.icon(

            onPressed: () {

              setState(() {

                showHint = true;

              });

            },

            icon: Icon(

              Icons.lightbulb_rounded,

              color: colors.hintColor,

            ),

            label: Text(

              'USE HINT  (-20 XP)',

              style: TextStyle(

                color: colors.hintColor,

                fontWeight: FontWeight.w900,

              ),

            ),

            style: OutlinedButton.styleFrom(

              minimumSize: const Size(0, 54),

              side: BorderSide(

                color: colors.hintColor.withValues(alpha: .5),

              ),

              backgroundColor: colors.hintBackground,

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(14),

              ),

            ),

          ),

        ),

        const SizedBox(width: 12),

        Expanded(

          child: ElevatedButton.icon(

            onPressed: _submitAnswer,

            icon: const Icon(Icons.arrow_forward_rounded),

            label: const Text(

              'CHECK ANSWER / SUBMIT',

              style: TextStyle(

                fontWeight: FontWeight.w900,

                letterSpacing: .5,

              ),

            ),

            style: ElevatedButton.styleFrom(

              minimumSize: const Size(0, 54),

              backgroundColor: colors.accent,

              foregroundColor: colors.buttonText,

              elevation: 0,

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(14),

              ),

            ),

          ),

        ),

      ],

    );

  }

  void _submitAnswer() {

    if (selectedOption == -1) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: const Text('Select an answer first.'),

          backgroundColor: colors.panel,

        ),

      );

      return;

    }

    if (selectedOption == question.correctOption) {
      setState(() {
        if (currentStep < 4) currentStep++;
      });


      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(
            '🎉 Correct! ${question.options[question.correctOption]}',
          ),

          backgroundColor: colors.success,

        ),

      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(
            'Not quite. Use the hint and simulation to reason through the concept.',
          ),

          backgroundColor: colors.error,

        ),

      );

    }

  }

  // ============================================================

  // PANEL

  // ============================================================

  Widget _panel({

    required String title,

    required IconData icon,

    required Widget child,

  }) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: colors.panel,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(

          color: colors.border,

        ),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Icon(

                icon,

                color: colors.accent,

                size: 21,

              ),

              const SizedBox(width: 8),

              Expanded(

                child: Text(

                  title,

                  style: TextStyle(

                    color: colors.accent,

                    fontSize: 13,

                    fontWeight: FontWeight.w900,

                    letterSpacing: .8,

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

// ============================================================

// THEME COLORS

// ============================================================


class CoreFlowAnimation extends StatelessWidget {
  final List<String> labels;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;
  final int step;
  final ValueChanged<int> onStepChanged;

  const CoreFlowAnimation({
    super.key,
    required this.labels,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
    required this.step,
    required this.onStepChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safe = step.clamp(0, labels.length - 1);
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: Row(
            children: List.generate(labels.length, (index) {
              final active = index == safe;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: active ? 145 : 125,
                    decoration: BoxDecoration(
                      color: active ? accentColor.withValues(alpha: .20) : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: active ? accentColor : accentColor.withValues(alpha: .25),
                        width: active ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        labels[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: active ? accentColor : textColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: safe > 0 ? () => onStepChanged(safe - 1) : null,
              icon: const Icon(Icons.skip_previous_rounded, size: 16),
              label: const Text('Previous'),
            ),
            ElevatedButton.icon(
              onPressed: safe < labels.length - 1 ? () => onStepChanged(safe + 1) : null,
              icon: const Icon(Icons.skip_next_rounded, size: 16),
              label: const Text('Next Step'),
            ),
            OutlinedButton.icon(
              onPressed: () => onStepChanged(0),
              icon: const Icon(Icons.replay_rounded, size: 16),
              label: const Text('Replay'),
            ),
          ],
        ),
      ],
    );
  }
}

class CoreSubjectQuestion {
  final String difficulty;
  final String question;
  final List<String> options;
  final int correctOption;
  final String hint;
  final String simulationTitle;
  final List<String> simulationLabels;
  final List<String> stepDescriptions;

  const CoreSubjectQuestion({
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctOption,
    required this.hint,
    required this.simulationTitle,
    required this.simulationLabels,
    required this.stepDescriptions,
  });

  static CoreSubjectQuestion forSubject(String topic, int level) {
    final key = topic.trim().toUpperCase();
    if (key == 'DBMS') return _dbms(level);
    if (key == 'CN' || key == 'COMPUTER NETWORKS') return _cn(level);
    if (key == 'ML' || key == 'MACHINE LEARNING') return _ml(level);
    return _os(level);
  }

  static CoreSubjectQuestion _os(int level) => const CoreSubjectQuestion(
    difficulty: 'Intermediate • Process Scheduling',
    question: 'Which transition occurs when a running process is interrupted by the CPU scheduler’s time slice?',
    options: ['Running → Waiting', 'Running → Ready', 'Waiting → Ready', 'Running → Terminated'],
    correctOption: 1,
    hint: 'In Round Robin scheduling, when the time quantum expires, the running process is moved back to the Ready state.',
    simulationTitle: 'Process Lifecycle Visualizer',
    simulationLabels: ['READY', 'RUNNING', 'WAITING', 'READY'],
    stepDescriptions: [
      'The process is currently in the Ready state.',
      'The scheduler dispatches the process to Running.',
      'The time slice expires and the scheduler interrupts the process.',
      'The process returns to the Ready queue.',
    ],
  );

  static CoreSubjectQuestion _dbms(int level) {
    const q = [
      CoreSubjectQuestion(
        difficulty: 'Beginner • Database Foundations',
        question: 'Which component primarily manages data in a database system?',
        options: ['DBMS', 'Compiler', 'Router', 'Browser'], correctOption: 0,
        hint: 'Think about the software responsible for storing, retrieving and controlling database data.',
        simulationTitle: 'Database Request Visualizer',
        simulationLabels: ['CLIENT', 'DBMS', 'DATABASE', 'RESULT'],
        stepDescriptions: ['Client sends a request.', 'DBMS processes the request.', 'DBMS accesses the database.', 'Result is returned to the client.'],
      ),
      CoreSubjectQuestion(
        difficulty: 'Intermediate • ER Model',
        question: 'In an ER model, what represents a real-world object such as Student or Course?',
        options: ['Entity', 'Query', 'Index', 'Transaction'], correctOption: 0,
        hint: 'A real-world object with attributes is modeled as an entity.',
        simulationTitle: 'ER Model Visualizer',
        simulationLabels: ['ENTITY', 'ATTRIBUTE', 'RELATION', 'MODEL'],
        stepDescriptions: ['Identify the entity.', 'Identify its attributes.', 'Connect related entities.', 'Build the conceptual model.'],
      ),
      CoreSubjectQuestion(
        difficulty: 'Intermediate • Relational Model',
        question: 'Which key uniquely identifies a row in a relational table?',
        options: ['Primary Key', 'Foreign Key', 'Index', 'View'], correctOption: 0,
        hint: 'It must uniquely identify each record.',
        simulationTitle: 'Relational Model Visualizer',
        simulationLabels: ['TABLE', 'ROW', 'PRIMARY KEY', 'RELATION'],
        stepDescriptions: ['Start with the table.', 'Identify a record.', 'Use the primary key to identify it.', 'Relate tables using keys.'],
      ),
      CoreSubjectQuestion(
        difficulty: 'Intermediate • SQL',
        question: 'Which SQL clause filters rows using a condition?',
        options: ['WHERE', 'ORDER BY', 'GROUP BY', 'JOIN'], correctOption: 0,
        hint: 'It specifies which rows should satisfy a condition.',
        simulationTitle: 'SQL Query Visualizer',
        simulationLabels: ['SELECT', 'WHERE', 'TABLE', 'RESULT'],
        stepDescriptions: ['Choose columns.', 'Apply the condition.', 'Read matching rows.', 'Return the result.'],
      ),
    ];
    return q[((level - 1).clamp(0, q.length - 1)).toInt()];
  }

  static CoreSubjectQuestion _cn(int level) {
    const q = [
      CoreSubjectQuestion(
        difficulty: 'Beginner • Networking Basics',
        question: 'Why are protocols needed when devices communicate over a network?',
        options: ['To define communication rules', 'To store files', 'To compile code', 'To create databases'], correctOption: 0,
        hint: 'Protocols define how devices format, send and interpret data.',
        simulationTitle: 'Network Communication Visualizer',
        simulationLabels: ['CLIENT', 'PACKET', 'NETWORK', 'SERVER'],
        stepDescriptions: ['Client creates data.', 'Data becomes packets.', 'Packets travel through the network.', 'Server receives and interprets the data.'],
      ),
      CoreSubjectQuestion(
        difficulty: 'Intermediate • OSI Model',
        question: 'Which OSI layer handles logical addressing and routing?',
        options: ['Network', 'Physical', 'Session', 'Presentation'], correctOption: 0,
        hint: 'Think about IP addresses and routers.',
        simulationTitle: 'OSI Layer Visualizer',
        simulationLabels: ['APPLICATION', 'TRANSPORT', 'NETWORK', 'LINK'],
        stepDescriptions: ['Application creates data.', 'Transport prepares delivery.', 'Network handles addressing and routing.', 'Link handles local delivery.'],
      ),
      CoreSubjectQuestion(
        difficulty: 'Intermediate • TCP/IP',
        question: 'Which protocol provides reliable, connection-oriented transport?',
        options: ['TCP', 'UDP', 'IP', 'DNS'], correctOption: 0,
        hint: 'It uses acknowledgements and retransmission for reliable delivery.',
        simulationTitle: 'Transport Visualizer',
        simulationLabels: ['APP', 'TCP', 'IP', 'DESTINATION'],
        stepDescriptions: ['Application creates data.', 'TCP provides reliable transport.', 'IP routes packets.', 'Destination receives the data.'],
      ),
      CoreSubjectQuestion(
        difficulty: 'Intermediate • Routing',
        question: 'What device forwards packets between different networks?',
        options: ['Router', 'Switch', 'Keyboard', 'Monitor'], correctOption: 0,
        hint: 'Think about the device connecting separate networks.',
        simulationTitle: 'Routing Visualizer',
        simulationLabels: ['SOURCE', 'ROUTER', 'NEXT HOP', 'DESTINATION'],
        stepDescriptions: ['Source creates a packet.', 'Router examines the destination.', 'Packet moves to the next hop.', 'Destination receives it.'],
      ),
    ];
    return q[((level - 1).clamp(0, q.length - 1)).toInt()];
  }

  static CoreSubjectQuestion _ml(int level) {
    const q = [
      CoreSubjectQuestion(
        difficulty: 'Beginner • ML Basics',
        question: 'What does a machine learning model learn from during training?',
        options: ['Patterns in data', 'Only the final answer', 'Network cables', 'Database indexes'], correctOption: 0,
        hint: 'Training examples allow the model to learn patterns.',
        simulationTitle: 'Machine Learning Flow',
        simulationLabels: ['DATA', 'FEATURES', 'MODEL', 'PREDICTION'],
        stepDescriptions: ['Collect examples.', 'Prepare features.', 'Train the model.', 'Generate a prediction.'],
      ),
      CoreSubjectQuestion(
        difficulty: 'Intermediate • Regression',
        question: 'Which type of value is commonly predicted by regression?',
        options: ['Continuous value', 'Only text labels', 'Network address', 'Database table'], correctOption: 0,
        hint: 'Think about a numeric output such as score or temperature.',
        simulationTitle: 'Regression Visualizer',
        simulationLabels: ['DATA', 'FEATURES', 'MODEL', 'VALUE'],
        stepDescriptions: ['Collect examples.', 'Select features.', 'Fit the model.', 'Predict a continuous value.'],
      ),
      CoreSubjectQuestion(
        difficulty: 'Intermediate • Classification',
        question: 'What is the output of a binary classification model?',
        options: ['One of two classes', 'A database table', 'A network packet', 'A memory address'], correctOption: 0,
        hint: 'Binary means there are two possible classes.',
        simulationTitle: 'Classification Visualizer',
        simulationLabels: ['INPUT', 'FEATURES', 'PROBABILITY', 'CLASS'],
        stepDescriptions: ['Start with input.', 'Prepare features.', 'Estimate probability.', 'Select the class.'],
      ),
      CoreSubjectQuestion(
        difficulty: 'Intermediate • Decision Trees',
        question: 'What does a decision tree use to split data?',
        options: ['Feature-based conditions', 'Network packets', 'SQL joins', 'CPU time slices'], correctOption: 0,
        hint: 'Decision nodes ask questions about feature values.',
        simulationTitle: 'Decision Tree Visualizer',
        simulationLabels: ['ROOT', 'CONDITION', 'BRANCH', 'LEAF'],
        stepDescriptions: ['Start at the root.', 'Evaluate a feature condition.', 'Follow a branch.', 'Reach the prediction leaf.'],
      ),
    ];
    return q[((level - 1).clamp(0, q.length - 1)).toInt()];
  }
}

class CoreThemeColors {

  final Color background;

  final Color panel;

  final Color border;

  final Color accent;

  final Color text;

  final Color muted;

  final Color optionBackground;

  final Color optionBorder;

  final Color selectedOptionBackground;

  final Color simulationBackground;

  final Color stepBackground;

  final Color hintBackground;

  final Color hintColor;


  final Color xpColor;

  final Color xpBackground;

  final Color levelBadgeBackground;

  final Color track;

  final Color buttonText;

  final Color success;

  final Color error;

  const CoreThemeColors({

    required this.background,

    required this.panel,

    required this.border,

    required this.accent,

    required this.text,

    required this.muted,

    required this.optionBackground,

    required this.optionBorder,

    required this.selectedOptionBackground,

    required this.simulationBackground,

    required this.stepBackground,

    required this.hintBackground,

    required this.hintColor,


    required this.xpColor,

    required this.xpBackground,

    required this.levelBadgeBackground,

    required this.track,

    required this.buttonText,

    required this.success,

    required this.error,

  });

  factory CoreThemeColors.fromTheme(AppTheme theme) {

    switch (theme) {

      // --------------------------------------------------------

      // FOREST

      // --------------------------------------------------------

      case AppTheme.forest:

        return const CoreThemeColors(

          background: Color(0xFF03100C),

          panel: Color(0xFF061B15),

          border: Color(0xFF176B5A),

          accent: Color(0xFF35E0B5),

          text: Color(0xFFE9FFF8),

          muted: Color(0xFF91AAA3),

          optionBackground: Color(0xFF0A251D),

          optionBorder: Color(0xFF356B5E),

          selectedOptionBackground: Color(0xFF0E4736),

          simulationBackground: Color(0xFF041510),

          stepBackground: Color(0xFF09241B),

          hintBackground: Color(0xFF182515),

          hintColor: Color(0xFFFFD95A),

          xpColor: Color(0xFFFFD45A),

          xpBackground: Color(0xFF302B10),

          levelBadgeBackground: Color(0xFF26301A),

          track: Color(0xFF163B31),

          buttonText: Color(0xFF03100C),

          success: Color(0xFF168B63),

          error: Color(0xFF8E3845),

        );

      // --------------------------------------------------------

      // CYBERPUNK

      // --------------------------------------------------------

      case AppTheme.cyberpunk:

        return const CoreThemeColors(

          background: Color(0xFF09051A),

          panel: Color(0xFF120B2D),

          border: Color(0xFF5535A5),

          accent: Color(0xFF22D3EE),

          text: Color(0xFFF3F5FF),

          muted: Color(0xFFAAA7C8),

          optionBackground: Color(0xFF18103A),

          optionBorder: Color(0xFF624BA8),

          selectedOptionBackground: Color(0xFF25205C),

          simulationBackground: Color(0xFF0A0620),

          stepBackground: Color(0xFF171033),

          hintBackground: Color(0xFF29200C),

          hintColor: Color(0xFFFFD34D),

          xpColor: Color(0xFFFFC84D),

          xpBackground: Color(0xFF2A2009),

          levelBadgeBackground: Color(0xFF2D1741),

          track: Color(0xFF30225B),

          buttonText: Color(0xFF061018),

          success: Color(0xFF27D9A1),

          error: Color(0xFFE04F7F),

        );

      // --------------------------------------------------------

      // KINGDOM

      // --------------------------------------------------------

      case AppTheme.kingdom:

        return const CoreThemeColors(

          background: Color(0xFF160B04),

          panel: Color(0xFF281407),

          border: Color(0xFF76501F),

          accent: Color(0xFFFFC857),

          text: Color(0xFFFFF5DE),

          muted: Color(0xFFC5B79A),

          optionBackground: Color(0xFF351C0A),

          optionBorder: Color(0xFF76582C),

          selectedOptionBackground: Color(0xFF51300D),

          simulationBackground: Color(0xFF1C0E04),

          stepBackground: Color(0xFF321A08),

          hintBackground: Color(0xFF3A260C),

          hintColor: Color(0xFFFFD76A),

          xpColor: Color(0xFFFFCF55),

          xpBackground: Color(0xFF3A250A),

          levelBadgeBackground: Color(0xFF42270D),

          track: Color(0xFF553618),

          buttonText: Color(0xFF1A0D03),

          success: Color(0xFF4DBB75),

          error: Color(0xFFB74B4B),

        );

    }

  }

}
