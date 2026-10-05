import 'package:flutter/material.dart';
import 'theme_selection_screen.dart';
import 'core_subject_level_screen.dart';

class OSCoreLevelScreen extends StatelessWidget {
  final int level;
  final String title;
  final String subtitle;
  final String topic;
  final Color accentColor;
  final AppTheme theme;

  const OSCoreLevelScreen({
    super.key,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.topic,
    required this.accentColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final i = (level - 1).clamp(0, _levels.length - 1);
    final data = _levels[i];
    return CoreSubjectLevelScreen(
      theme: theme,
      level: level,
      subject: 'OS',
      title: title.isEmpty ? data.$1 : title,
      subtitle: subtitle.isEmpty ? data.$2 : subtitle,
      accentColor: accentColor,
      questions: data.$3,
      nextTitle: level < _levels.length ? 'Level ${level + 1}' : 'Complete',
    );
  }

  static const List<(String, String, List<CoreLearningQuestion>)> _levels = <(String, String, List<CoreLearningQuestion>)>[
    ("OS BASICS", "Processes • Threads • Memory", [ CoreLearningQuestion(
      title: "Process vs Thread Memory", concept: "Process vs Thread Memory", type: 'mcq',
      question: "Which component is typically shared by concurrent threads of the same process but not directly shared between separate parent-child processes?", options: ["CPU registers and program counter", "Runtime stack", "Global variables (data segment) and heap memory", "Process IDs"], correctOption: 2,
      explanation: "Threads share process resources such as heap and data/global memory, while each thread has its own execution state and stack.", animationTitle: "Process vs Thread Memory",
      animationSteps: ["Process", "Shared Heap/Data", "Thread Stack", "Separate Process"],
    )]),
    ("CPU SCHEDULING", "SJF • Waiting Time • Starvation", [ CoreLearningQuestion(
      title: "Shortest Job First", concept: "Shortest Job First", type: 'mcq',
      question: "Which scheduling algorithm is optimal for minimizing average waiting time but is difficult to implement in pure form and can cause starvation?", options: ["FCFS", "Shortest Job First (SJF)", "Round Robin", "Non-preemptive Priority Scheduling"], correctOption: 1,
      explanation: "SJF minimizes average waiting time by choosing the shortest CPU burst, but exact future burst length is not known and long jobs can starve.", animationTitle: "Shortest Job First",
      animationSteps: ["Ready Queue", "Shortest Burst", "CPU", "Long Job Waits"],
    )]),
    ("DEADLOCKS", "Coffman Conditions", [ CoreLearningQuestion(
      title: "Deadlock Conditions", concept: "Deadlock Conditions", type: 'mcq',
      question: "Which set contains the four necessary Coffman conditions for deadlock?", options: ["Mutual Exclusion, Starvation, No Preemption, Circular Wait", "Mutual Exclusion, Hold and Wait, No Preemption, Circular Wait", "Resource Allocation, Aging, Preemption, Race Condition", "Context Switching, Semaphores, Hold and Wait, Thread Pools"], correctOption: 1,
      explanation: "Deadlock requires mutual exclusion, hold and wait, no preemption, and circular wait to hold simultaneously.", animationTitle: "Deadlock Conditions",
      animationSteps: ["Mutual Exclusion", "Hold & Wait", "No Preemption", "Circular Wait"],
    )]),
    ("SYNCHRONIZATION", "Mutex • Semaphore", [ CoreLearningQuestion(
      title: "Mutex vs Semaphore", concept: "Mutex vs Semaphore", type: 'mcq',
      question: "What is a key difference between a binary semaphore and a mutex?", options: ["A mutex takes any integer value while a semaphore only takes 0 and 1.", "A mutex has ownership; a semaphore has no ownership and can be signaled by another thread.", "Semaphores only use hardware interrupts.", "A mutex always busy-waits while a semaphore always blocks."], correctOption: 1,
      explanation: "A mutex is owned by the locking thread. A semaphore is a signaling/counting mechanism without the same ownership requirement.", animationTitle: "Mutex vs Semaphore",
      animationSteps: ["Thread A", "Mutex Owned", "Semaphore Signal", "Thread B"],
    )]),
    ("VIRTUAL MEMORY", "FIFO • Page Faults", [ CoreLearningQuestion(
      title: "Belady’s Anomaly", concept: "Belady’s Anomaly", type: 'mcq',
      question: "What anomaly can occur when increasing the number of physical page frames increases page faults under FIFO?", options: ["Thrashing", "Belady’s Anomaly", "Direct Memory Mapping Failure", "Fragmentation"], correctOption: 1,
      explanation: "Belady’s Anomaly is the counterintuitive increase in page faults after adding frames for some FIFO reference strings.", animationTitle: "Belady’s Anomaly",
      animationSteps: ["Pages", "3 Frames", "4 Frames", "More Faults"],
    )]),
    ("MULTIPROCESSING", "Process Spawning • join()", [ CoreLearningQuestion(
      title: "Process Spawning", concept: "Process Spawning", type: 'code',
      question: "Fill the blanks to create two OS processes, start them, and wait for them to finish.", code: "import multiprocessing\n\nprocess1 = multiprocessing.____(target=compute_factorial, args=(\"Proc-A\", 10))\nprocess2 = multiprocessing.____(target=compute_factorial, args=(\"Proc-B\", 12))\n\nprocess1.____()\nprocess2.start()\n\nprocess1.join()\nprocess2.join()\n", answers: ["Process", "Process", "start"],
      explanation: "The multiprocessing.Process class creates independent OS-level processes. start() begins execution and join() waits for completion.", animationTitle: "Process Spawning",
      animationSteps: ["Create Process", "Create Process", "Start", "Join"],
    )]),
    ("THREAD SYNCHRONIZATION", "Race Condition • Lock", [ CoreLearningQuestion(
      title: "Race Condition Resolution", concept: "Race Condition Resolution", type: 'code',
      question: "Fill the blanks to protect the critical section with a lock.", code: "import threading\n\nshared_counter = 0\ncounter_lock = threading.____()\n\ndef safe_increment(iterations):\n    global shared_counter\n    for _ in range(iterations):\n        with ____:\n            current = shared_counter\n            shared_counter = current + ____\n", answers: ["Lock", "counter_lock", "1"],
      explanation: "The document uses threading.Lock() and protects the read-modify-write sequence with with counter_lock, preventing concurrent updates from corrupting the shared counter.", animationTitle: "Race Condition Resolution",
      animationSteps: ["Shared Counter", "Lock Acquired", "Critical Section", "Safe Update"],
    )]),
    ("PRODUCER-CONSUMER", "Queue • Synchronization", [ CoreLearningQuestion(
      title: "Producer Consumer", concept: "Producer Consumer", type: 'code',
      question: "Fill the blanks for a bounded, thread-safe FIFO buffer.", code: "import queue\n\nbounded_buffer = queue.____(maxsize=5)\n\n# Producer\nbounded_buffer.____(item)\n\n# Consumer\nitem = bounded_buffer.____(timeout=2)\n", answers: ["Queue", "put", "get"],
      explanation: "queue.Queue provides a thread-safe FIFO buffer. put() adds an item and get() retrieves one; a bounded queue can block when full or empty.", animationTitle: "Producer Consumer",
      animationSteps: ["Producer", "Bounded Queue", "Consumer", "Processed Item"],
    )]),
    ("INTEGRATED CHALLENGE", "Review • Apply • Connect", [ CoreLearningQuestion(
      title: "Integrated Subject Challenge", concept: "Integrated Review", type: 'mcq',
      question: "Which approach best demonstrates that you can connect the key ideas from the completed levels of this subject?", options: ["Recall one isolated definition only.", "Apply the relevant concepts together to solve a problem.", "Skip the concepts and guess.", "Use an unrelated topic."], correctOption: 1,
      explanation: "This level revisits the ideas already covered in Levels 1–8 and checks whether they can be applied together.", animationTitle: "Integrated Challenge",
      animationSteps: ["Recall", "Connect", "Apply", "Verify"],
    )]),
    ("MASTER DEMO", "Progress • Completion • Next Level", [ CoreLearningQuestion(
      title: "Level 10 Demo", concept: "FINAL DEMO", type: 'mcq',
      question: "What does reaching Level 10 demonstrate in this project?", options: ["Only that the first level was opened.", "That the subject progression can continue through the final demo level.", "That no previous levels were completed.", "That the quiz has no progress tracking."], correctOption: 1,
      explanation: "Level 10 is intentionally a demo level for presentation. Completing it demonstrates the full Level 1 → Level 10 progression and completion flow.", animationTitle: "LEVEL 10 • MASTER DEMO",
      animationSteps: ["LEVEL 1", "LEVEL 5", "LEVEL 8", "LEVEL 10 ✓"],
    )]),
  ];
}
