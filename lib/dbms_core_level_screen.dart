import 'package:flutter/material.dart';
import 'theme_selection_screen.dart';
import 'core_subject_level_screen.dart';

class DBMSCoreLevelScreen extends StatelessWidget {
  final int level;
  final String title;
  final String subtitle;
  final String topic;
  final Color accentColor;
  final AppTheme theme;

  const DBMSCoreLevelScreen({
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
      subject: 'DBMS',
      title: title.isEmpty ? data.$1 : title,
      subtitle: subtitle.isEmpty ? data.$2 : subtitle,
      accentColor: accentColor,
      questions: data.$3,
      nextTitle: level < _levels.length ? 'Level ${level + 1}' : 'Complete',
    );
  }

  static const List<(String, String, List<CoreLearningQuestion>)> _levels = <(String, String, List<CoreLearningQuestion>)>[
    ("ACID & TRANSACTIONS", "Dirty Read • Concurrency", [ CoreLearningQuestion(
      title: "Dirty Read", concept: "Dirty Read", type: 'mcq',
      question: "Transaction 1 updates a row, Transaction 2 reads it before Transaction 1 commits, and Transaction 1 rolls back. What anomaly occurred?", options: ["Dirty Read", "Non-repeatable Read", "Phantom Read", "Lost Update"], correctOption: 0,
      explanation: "A dirty read occurs when a transaction reads data written by another concurrent transaction before that transaction commits.", animationTitle: "Dirty Read",
      animationSteps: ["T1 Writes", "Uncommitted Data", "T2 Reads", "T1 Rollback"],
    )]),
    ("B+ TREE", "Indexing • Range Queries", [ CoreLearningQuestion(
      title: "B+ Tree Indexing", concept: "B+ Tree Indexing", type: 'mcq',
      question: "Why are B+ trees preferred for database indexing on disk?", options: ["They store keys and pointers in both internal and leaf nodes.", "Leaf nodes are linked for efficient range queries and actual data pointers are kept at the leaf level.", "They have worse search complexity than BSTs but use less memory.", "They never need balancing."], correctOption: 1,
      explanation: "B+ trees keep internal nodes compact for high fan-out and link leaves sequentially, making range scans efficient.", animationTitle: "B+ Tree Indexing",
      animationSteps: ["Root", "Internal Nodes", "Leaf 1 ↔ Leaf 2", "Range Scan"],
    )]),
    ("CONFLICT SERIALIZABILITY", "Precedence Graph", [ CoreLearningQuestion(
      title: "Conflict Serializability", concept: "Conflict Serializability", type: 'mcq',
      question: "According to the schedule discussed in the source, what determines whether the schedule is conflict-serializable?", options: ["A cycle in the precedence graph makes it serializable.", "The absence of a cycle in the precedence graph means the schedule is conflict-serializable.", "Any read-write pair is automatically non-serializable.", "Only schedules with no writes are serializable."], correctOption: 1,
      explanation: "The source explains that the precedence graph has no cycle, so the schedule is conflict-serializable.", animationTitle: "Conflict Serializability",
      animationSteps: ["Operations", "Conflict Edge", "Precedence Graph", "No Cycle → Serializable"],
    )]),
    ("REFERENTIAL INTEGRITY", "Foreign Keys • Cascade", [ CoreLearningQuestion(
      title: "ON DELETE CASCADE", concept: "ON DELETE CASCADE", type: 'mcq',
      question: "What happens when a parent row is deleted with ON DELETE CASCADE?", options: ["The parent deletion is prevented.", "Child foreign keys are set to NULL.", "Matching rows in the child table are automatically deleted.", "A warning is raised and orphan rows remain."], correctOption: 2,
      explanation: "ON DELETE CASCADE automatically removes child rows whose foreign key references the deleted parent row.", animationTitle: "ON DELETE CASCADE",
      animationSteps: ["Parent Row", "Delete", "Foreign Key Match", "Child Deleted"],
    )]),
    ("NORMALIZATION", "1NF • 2NF • 3NF", [ CoreLearningQuestion(
      title: "Highest Normal Form", concept: "Highest Normal Form", type: 'mcq',
      question: "In the source analysis, after checking that there is no partial dependency but a 3NF condition is violated, what is the highest normal form?", options: ["1NF", "2NF", "3NF", "BCNF"], correctOption: 1,
      explanation: "The document’s detailed correction concludes that there are no partial dependencies, so the relation satisfies 2NF but not 3NF.", animationTitle: "Highest Normal Form",
      animationSteps: ["Functional Dependencies", "Candidate Key", "No Partial Dependency", "2NF"],
    )]),
    ("DDL & CONSTRAINTS", "Tables • Keys • Constraints", [ CoreLearningQuestion(
      title: "Table Creation", concept: "Table Creation", type: 'code',
      question: "Fill the blanks for the primary key, foreign key, and cascade constraint shown in the SQL schema.", code: "CREATE TABLE departments (\n    dept_id INTEGER ____ AUTOINCREMENT,\n    dept_name TEXT NOT NULL UNIQUE\n);\n\nCREATE TABLE employees (\n    emp_id INTEGER PRIMARY KEY AUTOINCREMENT,\n    dept_id INTEGER,\n    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)\n        ON DELETE ____\n);\n", answers: ["PRIMARY KEY", "CASCADE"],
      explanation: "The source schema uses a primary key for department IDs and ON DELETE CASCADE so matching employee rows are deleted when a department is deleted.", animationTitle: "Table Creation",
      animationSteps: ["Departments", "Primary Key", "Employees", "Cascade"],
    )]),
    ("JOINS & AGGREGATION", "JOIN • GROUP BY • HAVING", [ CoreLearningQuestion(
      title: "Department Salary Query", concept: "Department Salary Query", type: 'code',
      question: "Fill the blanks to join departments with employees, group departments, and keep only groups whose average salary exceeds 50000.", code: "SELECT d.dept_name,\n       COUNT(e.emp_id) AS total_employees\nFROM departments d\n____ employees e ON d.dept_id = e.dept_id\n____ BY d.dept_name\n____ AVG(e.salary) > 50000;\n", answers: ["INNER JOIN", "GROUP", "HAVING"],
      explanation: "The source query uses INNER JOIN, GROUP BY department, and HAVING AVG(e.salary) > 50000.", animationTitle: "Department Salary Query",
      animationSteps: ["Departments", "INNER JOIN", "GROUP BY", "HAVING"],
    )]),
    ("WINDOW FUNCTIONS", "Ranking • Partition • Running Total", [ CoreLearningQuestion(
      title: "Analytical Query", concept: "Analytical Query", type: 'code',
      question: "Fill the blanks for ranking employees within each department.", code: "SELECT e.first_name,\n       e.salary,\n       ____() OVER (\n           PARTITION ____ e.dept_id\n           ORDER BY e.salary DESC\n       ) AS salary_rank\nFROM employees e;\n", answers: ["DENSE_RANK", "BY"],
      explanation: "The source uses DENSE_RANK() with PARTITION BY dept_id to rank salaries independently inside each department.", animationTitle: "Analytical Query",
      animationSteps: ["Department", "Partition", "Rank", "Salary Order"],
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
