import 'package:flutter/material.dart';
import 'theme_selection_screen.dart';
import 'core_subject_level_screen.dart';

class OOPSCoreLevelScreen extends StatelessWidget {
  final int level;
  final String title;
  final String subtitle;
  final String topic;
  final Color accentColor;
  final AppTheme theme;

  const OOPSCoreLevelScreen({
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
      subject: 'OOPS',
      title: title.isEmpty ? data.$1 : title,
      subtitle: subtitle.isEmpty ? data.$2 : subtitle,
      accentColor: accentColor,
      questions: data.$3,
      nextTitle: level < _levels.length ? 'Level ${level + 1}' : 'Complete',
      onNextLevel: level < _levels.length
          ? () {
              final nextLevel = level + 1;
              final nextData = _levels[nextLevel - 1];

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => OOPSCoreLevelScreen(
                    level: nextLevel,
                    title: nextData.$1,
                    subtitle: nextData.$2,
                    topic: topic,
                    accentColor: accentColor,
                    theme: theme,
                  ),
                ),
              );
            }
          : null,
    );
  }

  static const List<(String, String, List<CoreLearningQuestion>)> _levels = <(String, String, List<CoreLearningQuestion>)>[
    ("CLASSES & OBJECTS", "Objects • Methods • Inheritance",  [CoreLearningQuestion(
      title: "Dynamic Binding & Polymorphism", concept: "Dynamic Binding & Polymorphism", type: 'mcq',
      question: "Consider the pseudo-code: Parent* ptr = new Child(); ptr->print(); What is printed and why?", options: ["“Parent”, because the pointer type is Parent (Static Binding).", "“Child”, because virtual enables dynamic dispatch/binding at runtime.", "Compilation error because Parent pointer cannot point to Child.", "“Parent” followed by “Child”."], correctOption: 1,
      explanation: "The pointer refers to a Child object. Because print() is virtual, runtime dispatch selects Child::print().", animationTitle: "Dynamic Binding & Polymorphism",
      animationSteps: ["Parent Pointer", "Child Object", "Virtual Lookup", "Child::print()"],
    )]),
    ("PYTHON MRO", "Multiple Inheritance • Method Lookup", [CoreLearningQuestion(
      title: "Python Method Resolution Order", concept: "Python Method Resolution Order", type: 'mcq',
      question: "For D(B, C), where B(A) and C(A), which algorithm determines the precise method lookup order?", options: ["Depth-First Search with left-to-right priority.", "Breadth-First Search with right-to-left priority.", "C3 Linearization Algorithm.", "Kahn’s Topological Sorting Algorithm."], correctOption: 2,
      explanation: "Python uses C3 Linearization. For the hierarchy in the document, the order is D → B → C → A → object.", animationTitle: "Python Method Resolution Order",
      animationSteps: ["D", "B", "C", "A → object"],
    )]),
    ("ENCAPSULATION", "Data Hiding • Getter • Setter", [CoreLearningQuestion(
      title: "Encapsulation", concept: "Encapsulation", type: 'mcq',
      question: "If Car exposes a public engineState that many external classes directly modify instead of using controlled methods, which OOP concept is violated?", options: ["Polymorphism", "Encapsulation", "Abstraction", "Single Inheritance"], correctOption: 1,
      explanation: "Encapsulation hides internal state and provides controlled access through well-defined methods.", animationTitle: "Encapsulation",
      animationSteps: ["External Classes", "Controlled Method", "Private State", "Safe Access"],
    )]),
    ("ABSTRACT CLASS & INTERFACE", "State • Contract",  [CoreLearningQuestion(
      title: "Abstract Class vs Interface", concept: "Abstract Class vs Interface", type: 'mcq',
      question: "What is a key structural difference in modern Java-like OOP languages?", options: ["Abstract classes can only have abstract methods; interfaces only concrete methods.", "A class can inherit multiple abstract classes but only one interface.", "Abstract classes can maintain instance state and constructors; interfaces cannot maintain instance state or have constructors.", "Abstract classes cannot support static methods while interfaces can."], correctOption: 2,
      explanation: "An abstract class can contain instance fields and constructors. An interface represents a contract and cannot hold instance state or have constructors.", animationTitle: "Abstract Class vs Interface",
      animationSteps: ["Abstract Class", "Instance State", "Interface", "Contract"],
    )]),
    ("VIRTUAL DESTRUCTOR", "Inheritance • Resource Cleanup", [CoreLearningQuestion(
      title: "Virtual Destructors", concept: "Virtual Destructors", type: 'mcq',
      question: "In C++, why should a base-class destructor be virtual when deleting a derived object through a base pointer?", options: ["To prevent compiler syntax errors.", "To ensure the base constructor is called first.", "To ensure the derived destructor runs first and resources are released correctly.", "To let the garbage collector identify orphan references."], correctOption: 2,
      explanation: "Virtual destruction enables dynamic dispatch so the derived destructor executes before the base destructor when deleting through a base pointer.", animationTitle: "Virtual Destructors",
      animationSteps: ["Base Pointer", "Derived Object", "Derived Destructor", "Base Destructor"],
    )]),
    ("CLASS & INHERITANCE", "Person • Student • super()",  [CoreLearningQuestion(
      title: "Class Definition & Single Inheritance", concept: "Class Definition & Single Inheritance", type: 'code',
      question: "Fill the blanks to create Student as a subclass of Person and call the parent constructor.", code: "class Person:\n    def __init__(self, name, age):\n        self.name = name\n        self.age = age\n\nclass Student(____):\n    def __init__(self, name, age, student_id):\n        ____.____(name, age)\n        self.student_id = student_id\n\n    def get_details(self):\n        return ____().get_details()\n", answers: ["Person", "super().__init__", "super"],
      explanation: "The Student class inherits from Person, uses super().__init__() to initialize inherited state, and can call the parent method through super().", animationTitle: "Class Definition & Single Inheritance",
      animationSteps: ["Person", "super().__init__", "Student override"],
    )]),
    ("ENCAPSULATION IN CODE", "Private State • Properties", [CoreLearningQuestion(
      title: "BankAccount Encapsulation", concept: "BankAccount Encapsulation", type: 'code',
      question: "Fill the blanks to keep the balance private and expose controlled access.", code: "class BankAccount:\n    def __init__(self, owner, initial_balance):\n        self.owner = owner\n        self.____ = initial_balance\n\n    @property\n    def balance(self):\n        return self.____\n\n    def deposit(self, amount):\n        self.____ += amount\n", answers: ["__balance", "__balance", "__balance"],
      explanation: "The document uses Python name mangling with __balance. Access goes through the property while updates happen through controlled methods such as deposit().", animationTitle: "BankAccount Encapsulation",
      animationSteps: ["Client", "deposit()", "__balance", "balance property"],
    )]),
    ("ABCs & MULTIPLE INHERITANCE", "Abstract Method • Mixin • MRO", [CoreLearningQuestion(
      title: "Abstract Base Class and Multiple Inheritance", concept: "Abstract Base Class and Multiple Inheritance", type: 'code',
      question: "Fill the blanks for an abstract payment processor and a class that combines the processor with an audit mixin.", code: "from abc import ABC, abstractmethod\n\nclass PaymentProcessor(____):\n    @____\n    def process_payment(self, amount):\n        pass\n\nclass PayPalProcessor(____, AuditLoggerMixin):\n    def process_payment(self, amount):\n        self.log_transaction(\"TXN_PP_9921\", amount, \"SUCCESS\")\n        return True\n", answers: ["ABC", "abstractmethod", "PaymentProcessor"],
      explanation: "PaymentProcessor derives from ABC and declares an abstract method. PayPalProcessor inherits from PaymentProcessor and the AuditLoggerMixin, demonstrating multiple inheritance.", animationTitle: "Abstract Base Class and Multiple Inheritance",
      animationSteps: ["ABC", "abstractmethod", "PaymentProcessor + Mixin", "PayPalProcessor"],
    )]),
    ("INTEGRATED CHALLENGE", "Review • Apply • Connect", [CoreLearningQuestion(
      title: "Integrated Subject Challenge", concept: "Integrated Review", type: 'mcq',
      question: "Which approach best demonstrates that you can connect the key ideas from the completed levels of this subject?", options: ["Recall one isolated definition only.", "Apply the relevant concepts together to solve a problem.", "Skip the concepts and guess.", "Use an unrelated topic."], correctOption: 1,
      explanation: "This level revisits the ideas already covered in Levels 1–8 and checks whether they can be applied together.", animationTitle: "Integrated Challenge",
      animationSteps: ["Recall", "Connect", "Apply", "Verify"],
    )]),
    ("MASTER DEMO", "Progress • Completion • Next Level", [CoreLearningQuestion(
      title: "Level 10 Demo", concept: "FINAL DEMO", type: 'mcq',
      question: "What does reaching Level 10 demonstrate in this project?", options: ["Only that the first level was opened.", "That the subject progression can continue through the final demo level.", "That no previous levels were completed.", "That the quiz has no progress tracking."], correctOption: 1,
      explanation: "Level 10 is intentionally a demo level for presentation. Completing it demonstrates the full Level 1 → Level 10 progression and completion flow.", animationTitle: "LEVEL 10 • MASTER DEMO",
      animationSteps: ["LEVEL 1", "LEVEL 5", "LEVEL 8", "LEVEL 10 ✓"],
    )]),
  ];
}
