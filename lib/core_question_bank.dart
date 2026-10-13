import 'core_subject_level_screen.dart';

class CoreQuestionBank {
  static const Map<String, List<_QuestionSpec>> _specs = {
    'OOPS': [
      _QuestionSpec('Classes and Objects','A class defines a blueprint; an object is an instance with state and behavior.','A class is always an object instance.','Objects cannot contain state.','A class is a network protocol.'),
      _QuestionSpec('Constructors','A constructor initializes an object when it is created.','A constructor must return an integer.','A constructor always destroys an object.','A constructor cannot accept parameters.'),
      _QuestionSpec('Encapsulation','Encapsulation combines data and methods while controlling access to internal state.','Encapsulation means sorting objects.','Encapsulation removes methods.','Encapsulation is a database join.'),
      _QuestionSpec('Access Modifiers','Access modifiers control where members can be accessed.','Private members are always globally visible.','Access modifiers only change comments.','Public members cannot be called.'),
      _QuestionSpec('Inheritance','Inheritance lets a class reuse or extend behavior from a parent class.','Inheritance prevents code reuse.','Inheritance is a SQL constraint.','Inheritance removes parent classes.'),
      _QuestionSpec('Method Overloading','Overloading uses the same method name with different parameter lists.','Overloading requires unrelated names.','Overloading changes only comments.','Overloading occurs only after deployment.'),
      _QuestionSpec('Method Overriding','Overriding provides a subclass implementation of an inherited method with a compatible signature.','Overriding changes only variable names.','Overriding requires unrelated classes.','Overriding is normalization.'),
      _QuestionSpec('Polymorphism','Polymorphism allows one interface or base type to represent different implementations.','Polymorphism means every class has one object.','Polymorphism prevents method calls.','Polymorphism is file compression.'),
      _QuestionSpec('Dynamic Binding','Dynamic binding selects the applicable overridden method at runtime.','It occurs only during preprocessing.','It removes inheritance.','It compiles SQL queries.'),
      _QuestionSpec('Abstraction','Abstraction exposes essential behavior while hiding unnecessary implementation details.','Abstraction exposes every internal detail.','Abstraction is a sorting algorithm.','Abstraction prevents reuse.'),
      _QuestionSpec('Interfaces','An interface defines a contract that implementing classes provide.','An interface is always a concrete object.','An interface stores every object automatically.','An interface is only a UI screen.'),
      _QuestionSpec('Abstract Classes','An abstract class can provide shared behavior and require subclasses to implement abstract members.','It must always be instantiated directly.','It cannot contain implemented methods.','It is a database index.'),
      _QuestionSpec('Composition','Composition models a strong has-a relationship between objects.','Composition is always is-a inheritance.','Composition requires global variables.','Composition is recursion.'),
      _QuestionSpec('Aggregation','Aggregation models a has-a relationship where the contained object may have an independent lifecycle.','The child must always die with its parent.','Aggregation is overloading.','Aggregation is exception handling.'),
      _QuestionSpec('Association','Association represents a relationship between otherwise distinct classes or objects.','Association means two classes must inherit from each other.','Association is a loop.','Association deletes both objects.'),
      _QuestionSpec('SOLID Principles','SOLID principles guide maintainable object-oriented design and separation of responsibilities.','SOLID is a storage format.','Every class must be static.','SOLID replaces constructors.'),
      _QuestionSpec('Exception Handling','Exception handling allows programs to respond to runtime errors through controlled mechanisms.','Exceptions always stop all future programs.','Exceptions are database keys.','Exception handling replaces testing.'),
      _QuestionSpec('Static Members','Static members belong to a class rather than a particular instance.','Static fields require a new object for every access.','Static methods always access instance fields directly.','Static means immutable in every language.'),
      _QuestionSpec('Coupling and Cohesion','Good design generally aims for lower coupling and higher cohesion.','Good design maximizes unrelated responsibilities.','Coupling and cohesion mean the same thing.','High coupling always improves maintainability.'),
      _QuestionSpec('Design Patterns','Design patterns are reusable approaches to recurring software design problems.','Patterns are executable programming languages.','Patterns remove the need to understand requirements.','Patterns are database records.'),
    ],
    'OS': [
      _QuestionSpec('Process','A process is a program in execution with its own process context and resources.','A process is only a CPU register.','A process is one instruction.','A process cannot contain threads.'),
      _QuestionSpec('Thread','Threads in a process share many process resources but have their own execution stack and state.','Every thread has a separate address space.','Threads never share memory.','Threads cannot execute concurrently.'),
      _QuestionSpec('Process vs Thread','Processes usually have separate address spaces; threads within one process commonly share memory.','Threads never share memory.','All processes always share all memory.','Threads have no execution state.'),
      _QuestionSpec('Context Switching','A context switch saves one execution context and restores another.','It deletes the operating system.','It creates a database table.','It always increases CPU speed.'),
      _QuestionSpec('FCFS Scheduling','First-Come, First-Served schedules processes in arrival order.','It always selects the shortest job.','It always preempts every process.','It is a page replacement policy.'),
      _QuestionSpec('SJF Scheduling','Shortest Job First selects the process with the shortest expected CPU burst.','It ignores burst length.','It is a memory allocation method.','It always uses round robin.'),
      _QuestionSpec('Round Robin','Round Robin assigns each ready process a time quantum in cyclic order.','One process runs forever.','It has no time quantum.','It is only a page replacement algorithm.'),
      _QuestionSpec('Priority Scheduling','Priority scheduling selects a process based on its assigned priority.','It ignores priority values.','It is only used for files.','It can never cause starvation.'),
      _QuestionSpec('Starvation','Starvation occurs when a process waits indefinitely because others repeatedly receive service.','Starvation means a process always finishes first.','It is a compiler stage.','It cannot occur in priority scheduling.'),
      _QuestionSpec('Deadlock','Deadlock occurs when processes wait indefinitely for resources held by one another.','Deadlock means all processes run normally.','It only occurs in networking.','It is a CPU instruction.'),
      _QuestionSpec('Coffman Conditions','The four conditions are mutual exclusion, hold-and-wait, no preemption, and circular wait.','Deadlock requires only one condition.','Deadlock requires no resources.','Deadlock requires a compiler.'),
      _QuestionSpec('Mutex','A mutex provides mutual exclusion for a critical section.','A mutex is a file system.','A mutex guarantees no scheduling.','A mutex is always a counting semaphore.'),
      _QuestionSpec('Semaphore','A semaphore is a synchronization primitive used for signaling or resource counting.','A semaphore is a file system.','A semaphore cannot hold a count.','A semaphore is a CPU register.'),
      _QuestionSpec('Race Condition','A race condition occurs when concurrent access makes results depend on timing.','It is always deterministic.','It means no shared state exists.','It is a page fault.'),
      _QuestionSpec('Virtual Memory','Virtual memory gives processes a logical address space and can use secondary storage to extend available memory.','It removes all RAM.','It is only CPU scheduling.','It prevents every page fault.'),
      _QuestionSpec('Paging','Paging divides virtual memory into fixed-size pages and physical memory into frames.','Paging uses only variable-size segments.','Paging eliminates address translation.','Paging is a network protocol.'),
      _QuestionSpec('Page Fault','A page fault occurs when a referenced page needs OS handling because it is not currently mapped in RAM.','It means the CPU is permanently broken.','It is a SQL error.','It always means deadlock.'),
      _QuestionSpec('Belady Anomaly','FIFO can exhibit Belady anomaly, where adding frames increases page faults for some reference strings.','It only affects CPU scheduling.','It means zero page faults.','It is a compiler warning.'),
      _QuestionSpec('File System','A file system organizes files, directories, and storage metadata.','It only schedules CPU tasks.','It is a thread.','It cannot store directories.'),
      _QuestionSpec('System Call','A system call is a controlled interface for a user program to request an OS service.','It is only a hardware cable.','It never enters kernel mode.','It is a database query.'),
    ],
    'DBMS': [
      _QuestionSpec('Database','A database is an organized collection of data for storage and retrieval.','A database is only a CPU scheduler.','A database cannot contain tables.','A database is always a text editor.'),
      _QuestionSpec('Primary Key','A primary key uniquely identifies each row in a relation.','It allows duplicate identifiers by definition.','It must always be a foreign key.','It is a query result.'),
      _QuestionSpec('Foreign Key','A foreign key references a key in another or the same table to enforce referential integrity.','It always creates a new database.','It removes all constraints.','Every foreign key is unique by definition.'),
      _QuestionSpec('ER Model','An ER model represents entities, attributes, and relationships.','It is only an execution plan.','It cannot represent relationships.','It is a CPU algorithm.'),
      _QuestionSpec('Normalization','Normalization reduces redundancy and update anomalies by organizing relations.','It maximizes duplicate data.','It is only indexing.','It encrypts a table.'),
      _QuestionSpec('First Normal Form','1NF requires atomic attribute values and no repeating groups in the classical relational model.','It requires two primary keys.','It means no columns.','It requires recursion.'),
      _QuestionSpec('Second Normal Form','2NF removes partial dependencies of non-prime attributes on a proper subset of a candidate key.','It removes only transitive dependencies.','It forbids primary keys.','It is a join algorithm.'),
      _QuestionSpec('Third Normal Form','3NF addresses inappropriate transitive dependencies of non-key attributes on candidate keys.','It requires no keys.','It is only about indexes.','It means every row is duplicated.'),
      _QuestionSpec('ACID Properties','ACID stands for atomicity, consistency, isolation, and durability.','ACID means access, caching, indexing, data.','ACID is a network protocol.','ACID is a sorting method.'),
      _QuestionSpec('Atomicity','Atomicity treats a transaction as an all-or-nothing unit.','It means only reads are allowed.','It means every query is permanent.','It is a join type.'),
      _QuestionSpec('Isolation','Isolation controls how concurrent transactions observe each other’s intermediate results.','It means deleting all locks.','It prevents all concurrency.','It is a primary key.'),
      _QuestionSpec('Dirty Read','A dirty read reads data written by another transaction before that transaction commits.','It requires no transaction.','It is always a disk failure.','It is a primary key violation.'),
      _QuestionSpec('Serializability','Conflict serializability can be tested by checking whether the precedence graph is acyclic.','A cycle proves serializability.','It ignores conflicts.','It applies only to schemas.'),
      _QuestionSpec('B+ Tree','B+ trees keep records or record pointers at leaves and link leaves for efficient range scans.','B+ trees never balance.','They cannot support range queries.','They are only for text.'),
      _QuestionSpec('Indexing','An index can speed lookups but adds storage and update overhead.','Indexes always slow reads.','Indexes replace transactions.','Indexes remove primary keys.'),
      _QuestionSpec('JOIN','A JOIN combines rows from tables according to a join condition.','A JOIN can use only one table.','A JOIN always deletes rows.','A JOIN is a transaction property.'),
      _QuestionSpec('GROUP BY','GROUP BY forms groups for aggregate calculations.','It deletes rows permanently.','It is a constraint.','It cannot be used with aggregates.'),
      _QuestionSpec('HAVING','HAVING filters groups after grouping and aggregation.','It filters individual rows before FROM.','It creates a table.','It is a primary key.'),
      _QuestionSpec('Window Function','A window function computes across related rows without collapsing them into one row per group.','It always deletes rows.','It is only DDL.','It cannot use ordering.'),
      _QuestionSpec('Recovery','Database recovery uses logs, checkpoints, and backups to restore consistency after failures.','Recovery removes backups.','It is only query optimization.','It cannot use logs.'),
    ],
    'CN': [
      _QuestionSpec('OSI Model','The OSI model divides network functions into seven conceptual layers.','It has two layers only.','It is a database schema.','It is a CPU scheduler.'),
      _QuestionSpec('Physical Layer','The physical layer transmits raw bits over a physical medium.','It routes IP packets.','It stores SQL rows.','It performs CPU scheduling.'),
      _QuestionSpec('Data Link Layer','The data link layer handles framing and link-local delivery, commonly using MAC addresses.','It assigns process IDs.','It performs SQL normalization.','It is an application protocol.'),
      _QuestionSpec('Network Layer','The network layer provides logical addressing and packet routing between networks.','It only handles file permissions.','It is a database key.','It replaces transport protocols.'),
      _QuestionSpec('TCP','TCP provides connection-oriented, reliable, ordered byte-stream delivery.','TCP is always connectionless.','TCP never retransmits.','TCP cannot use ports.'),
      _QuestionSpec('UDP','UDP provides a connectionless datagram service without built-in delivery guarantees.','UDP always guarantees ordering.','UDP requires a three-way handshake.','UDP cannot use ports.'),
      _QuestionSpec('TCP Handshake','TCP connection establishment commonly uses SYN, SYN-ACK, and ACK.','It starts with FIN, FIN, FIN.','It uses DNS queries as acknowledgments.','It requires no acknowledgments.'),
      _QuestionSpec('Port Number','Port numbers identify transport-layer application endpoints.','They identify physical cables.','They replace IP addresses.','They are MAC addresses.'),
      _QuestionSpec('IP Address','An IP address provides logical network-layer addressing.','It is a process ID.','It is always a MAC address.','It is a file name.'),
      _QuestionSpec('Subnetting','Subnetting divides an IP network into smaller logical networks.','It is encryption.','It removes IP addresses.','It increases one broadcast domain only.'),
      _QuestionSpec('CIDR','CIDR represents network prefixes with notation such as /24.','It represents ports only.','It is a transport protocol.','It removes routing.'),
      _QuestionSpec('ARP','ARP resolves an IPv4 address to a link-layer MAC address on a local network.','It maps domain names to URLs.','It encrypts TCP.','It schedules processes.'),
      _QuestionSpec('DNS','DNS resolves domain names to IP addresses and other resource records.','It assigns MAC addresses directly.','It replaces TCP.','It is a database lock.'),
      _QuestionSpec('DHCP','DHCP automatically provides network settings such as IP address, gateway, and DNS server.','It encrypts every packet by definition.','It replaces routing.','It handles web pages only.'),
      _QuestionSpec('HTTP','HTTP is an application-layer protocol for web request and response communication.','It is a physical-layer standard.','It is a CPU scheduling algorithm.','It assigns MAC addresses.'),
      _QuestionSpec('HTTPS','HTTPS protects HTTP traffic using TLS to provide confidentiality and integrity in transit.','It removes encryption.','It is always UDP-only.','It is a database transaction.'),
      _QuestionSpec('TLS','TLS negotiates cryptographic parameters and protects application traffic in transit.','It is a routing protocol.','It only compresses images.','It replaces DNS.'),
      _QuestionSpec('Socket','A socket is an application programming endpoint for network communication.','It is a subnet mask.','It is a CPU cache.','It is a database row.'),
      _QuestionSpec('Routing','Routing selects paths for packets between networks using routing information.','It only happens inside a CPU.','It maps variables to classes.','It is SQL normalization.'),
      _QuestionSpec('Congestion Control','Congestion control adjusts sending behavior to reduce network overload.','It guarantees unlimited bandwidth.','It is encryption.','It only changes MAC addresses.'),
    ],
    'ML': [
      _QuestionSpec('Supervised Learning','Supervised learning learns a mapping from inputs to labeled target outputs.','It never uses labels.','It is only clustering.','It cannot make predictions.'),
      _QuestionSpec('Unsupervised Learning','Unsupervised learning discovers structure in data without target labels.','It requires every label.','It is always regression.','It cannot find clusters.'),
      _QuestionSpec('Train-Test Split','A train-test split separates training data from data used to estimate generalization.','The test set should always train the model.','It removes all features.','It is an optimizer.'),
      _QuestionSpec('Overfitting','Overfitting occurs when a model fits training data too closely and generalizes poorly.','It always means both errors are high.','It is caused only by low capacity.','It means no parameters exist.'),
      _QuestionSpec('Underfitting','Underfitting occurs when a model is too simple to capture important patterns.','It always means zero training error.','It is the same as leakage.','It requires only more test data.'),
      _QuestionSpec('Bias-Variance','Bias reflects systematic error; variance reflects sensitivity to the particular training sample.','They are database constraints.','Variance always means zero error.','Bias applies only to images.'),
      _QuestionSpec('Linear Regression','Linear regression models a continuous target as a linear combination of features.','It is only clustering.','It predicts class labels only.','It cannot have an intercept.'),
      _QuestionSpec('Logistic Regression','Logistic regression models class probabilities, often using a sigmoid for binary classification.','It is only a clustering algorithm.','It always predicts continuous prices.','It requires no labels.'),
      _QuestionSpec('Decision Tree','A decision tree makes predictions through feature-based splits arranged in a tree.','It has no decision rules.','It is always an ensemble.','It cannot handle classification.'),
      _QuestionSpec('Random Forest','A random forest combines many randomized decision trees to improve generalization.','It is one linear equation.','It requires no training data.','It is a scaling method.'),
      _QuestionSpec('K-Nearest Neighbors','KNN predicts using labels or values from nearby training examples.','It never uses distance.','It is always unsupervised.','It builds a neural network by definition.'),
      _QuestionSpec('K-Means','K-means clusters data by iteratively assigning points to centroids and updating centroids.','It requires class labels.','It predicts only time series.','It never uses distances.'),
      _QuestionSpec('Feature Scaling','Feature scaling puts numerical features on comparable scales.','It always removes all features.','It creates target labels.','It is model evaluation.'),
      _QuestionSpec('Normalization vs Standardization','Normalization often rescales a range; standardization commonly centers and scales by standard deviation.','They always produce identical values.','Standardization deletes rows.','Normalization trains labels.'),
      _QuestionSpec('Cross-Validation','Cross-validation evaluates a model across multiple train-validation splits.','It tests only one row.','It guarantees zero error.','It replaces a final test set in every workflow.'),
      _QuestionSpec('Confusion Matrix','A confusion matrix summarizes predicted versus actual class counts.','It measures only training time.','It is a clustering centroid.','It replaces labels.'),
      _QuestionSpec('Precision','Precision is true positives divided by all predicted positives.','It is true positives divided by all actual positives.','It is always accuracy.','It ignores false positives.'),
      _QuestionSpec('Recall','Recall is true positives divided by all actual positives.','It is true positives divided by predicted positives.','It ignores false negatives.','It is always specificity.'),
      _QuestionSpec('F1 Score','F1 is the harmonic mean of precision and recall.','It is their arithmetic sum.','It is the number of features.','It measures model size only.'),
      _QuestionSpec('Gradient Descent','Gradient descent updates parameters in a direction that reduces the objective using its gradient.','It always increases loss.','It is a train-test split.','It requires no learning rate.'),
    ],
  };

  static List<CoreLearningQuestion> forSubject(String subject) {
    final specs = _specs[subject.toUpperCase()] ?? const <_QuestionSpec>[];
    final result = <CoreLearningQuestion>[];
    for (var level = 1; level <= 100; level++) {
      final s = specs[(level - 1) % specs.length];
      final variant = ((level - 1) ~/ specs.length) + 1;
      final options = <String>[s.correct, s.wrong1, s.wrong2, s.wrong3];
      final shift = (level - 1) % 4;
      final rotated = List<String>.generate(4, (i) => options[(i + shift) % 4]);
      result.add(CoreLearningQuestion(
        title: '${s.name} • Level $level',
        concept: s.name,
        type: 'mcq',
        question: _levelQuestion(s.name, variant),
        options: rotated,
        correctOption: (4 - shift) % 4,
        explanation: s.correct,
        animationTitle: 'Simulation: ${s.name}',
        animationSteps: _animationSteps(subject.toUpperCase(), s.name),
      ));
    }
    return result;
  }

  static List<CoreLearningQuestion> testFor(String subject, int testNumber) {
    final all = forSubject(subject);
    if (testNumber < 1 || testNumber > 5) return [];
    final start = (testNumber - 1) * 20;
    // Ten mixed questions drawn from the preceding 20-level block.
    return List.generate(10, (i) {
      final a = all[start + (i * 2)];
      final b = all[start + (i * 2) + 1];
      final correct = '${a.concept}: ${a.explanation}';
      final opts = <String>[
        correct,
        '${a.concept}: ${a.options.first}',
        '${b.concept}: ${b.explanation}',
        'Neither concept is relevant to the scenario.',
      ];
      final shift = i % 4;
      final rotated = List<String>.generate(4, (j) => opts[(j + shift) % 4]);
      return CoreLearningQuestion(
        title: 'Knowledge Test $testNumber • Question ${i + 1}',
        concept: '${a.concept} + ${b.concept}',
        type: 'mcq',
        question: 'A placement scenario tests ${a.concept} and ${b.concept}. Which statement correctly describes the first concept?',
        options: rotated,
        correctOption: (4 - shift) % 4,
        explanation: a.explanation,
        animationTitle: 'Knowledge Check',
        animationSteps: [a.concept, b.concept, 'Connect ideas', 'Apply in a scenario'],
      );
    });
  }

  static List<String> _animationSteps(String subject, String concept) {
    final c = concept.toLowerCase();
    if (subject == 'OS') {
      if (c.contains('deadlock') || c.contains('coffman')) return ['Process A holds a resource and waits for another.', 'Process B holds the resource A needs.', 'A circular wait can leave both processes blocked.', 'Break a required condition to prevent deadlock.'];
      if (c.contains('paging') || c.contains('virtual memory') || c.contains('page fault')) return ['A process references a virtual page.', 'The page table maps it to a physical frame.', 'If absent, a page fault asks the OS to load it.', 'Execution resumes when the mapping is ready.'];
      if (c.contains('round robin')) return ['Processes wait in the ready queue.', 'The scheduler gives the first process a time quantum.', 'An unfinished process returns to the queue.', 'The CPU rotates fairly through ready processes.'];
      if (c.contains('fcfs')) return ['Processes enter in arrival order.', 'The first process receives the CPU.', 'It finishes its CPU burst before the next starts.', 'The queue order determines execution order.'];
      if (c.contains('sjf')) return ['The scheduler compares expected CPU burst lengths.', 'The shortest available job is selected.', 'That job executes according to the policy.', 'Other jobs wait until selected.'];
      if (c.contains('thread')) return ['A process owns resources and an address space.', 'Threads share many process resources.', 'Each thread keeps its own execution state and stack.', 'Threads can execute concurrently within the process.'];
      if (c.contains('context switching')) return ['The running process is interrupted.', 'The OS saves its execution context.', 'The scheduler selects another ready process.', 'The saved context of the next process is restored.'];
      return ['A program is loaded as a process.', 'The OS allocates resources and tracks its state.', 'The scheduler selects it for CPU execution.', 'The process produces results or waits for an event.'];
    }
    if (subject == 'DBMS') {
      if (c.contains('normalization') || c.contains('1nf') || c.contains('2nf') || c.contains('3nf')) return ['Inspect a table for repeating groups or dependencies.', 'Identify the dependency that violates the target normal form.', 'Decompose the relation while preserving required relationships.', 'Use keys to connect the resulting tables without needless redundancy.'];
      if (c.contains('primary key')) return ['Inspect the candidate identifier for each row.', 'Choose a key that is unique and non-null.', 'The database enforces uniqueness for every row.', 'Rows can now be identified reliably.'];
      if (c.contains('foreign key')) return ['A child row stores a referenced key value.', 'The database checks the referenced parent key.', 'Valid references preserve referential integrity.', 'Invalid references are rejected or handled by the configured rule.'];
      if (c.contains('acid') || c.contains('atomicity') || c.contains('isolation') || c.contains('dirty read')) return ['A transaction begins its operations.', 'The database enforces transaction rules and isolation.', 'The transaction commits or rolls back.', 'Only a valid completed outcome is retained.'];
      if (c.contains('join')) return ['Choose the input tables and join condition.', 'Compare rows using the join predicate.', 'Matching rows are combined into result rows.', 'The query returns the resulting relation.'];
      if (c.contains('index') || c.contains('b+ tree')) return ['A query searches for a key.', 'The index guides the search through tree or index entries.', 'The matching record location is found.', 'The database can avoid scanning every row.'];
      return ['A query or transaction reaches the database.', 'The DBMS checks schema, constraints, and operation rules.', 'The engine reads or updates the relevant rows.', 'A result or transaction outcome is returned.'];
    }
    if (subject == 'CN') {
      if (c.contains('tcp handshake')) return ['Client sends SYN to request a connection.', 'Server replies with SYN-ACK.', 'Client acknowledges with ACK.', 'Both endpoints can begin TCP data exchange.'];
      if (c.contains('dns')) return ['The user requests a domain name.', 'A resolver looks up the domain record.', 'DNS returns the corresponding IP address.', 'The client can contact the destination IP.'];
      if (c.contains('osi model') || c.contains('physical layer') || c.contains('data link') || c.contains('network layer')) return ['Application data is prepared at the sender.', 'Each network layer adds its relevant control information.', 'Bits and frames travel through the medium and network.', 'The receiver processes the data up the layers.'];
      if (c.contains('udp')) return ['An application creates a datagram.', 'UDP adds ports and a checksum where applicable.', 'The datagram is sent without a connection handshake.', 'Delivery and ordering are not guaranteed by UDP itself.'];
      if (c.contains('port number') || c.contains('ip address')) return ['The application identifies the destination service.', 'IP addressing identifies the destination host.', 'Transport ports identify the application endpoint.', 'The packet is delivered toward the correct endpoint.'];
      return ['The sender creates data for transmission.', 'The network encapsulates data into packets or frames.', 'Routers forward packets toward the destination.', 'The receiver accepts and processes the data.'];
    }
    if (subject == 'OOPS') {
      if (c.contains('inheritance')) return ['A parent class defines shared members.', 'A child class extends or inherits those members.', 'The child can reuse behavior and add its own.', 'The child object exposes the inherited and added behavior.'];
      if (c.contains('polymorphism') || c.contains('overrid') || c.contains('overload') || c.contains('dynamic binding')) return ['Code invokes a method through a name or base type.', 'The language resolves the applicable signature or runtime type.', 'The selected implementation is invoked.', 'The observed behavior depends on the selected method.'];
      if (c.contains('encapsulation') || c.contains('access modifier')) return ['An object stores internal state.', 'Access modifiers restrict direct access to members.', 'Public methods validate or control changes.', 'The object protects its invariants.'];
      if (c.contains('constructor')) return ['A new object is requested.', 'The constructor initializes fields and required state.', 'The object becomes ready for use.', 'Methods operate on the initialized object.'];
      if (c.contains('interface') || c.contains('abstract')) return ['A contract describes required behavior.', 'A concrete class implements the contract.', 'An object is used through the abstraction.', 'The caller relies on behavior rather than implementation details.'];
      return ['A class defines state and behavior.', 'An object is created from the class blueprint.', 'A method is invoked on the object.', 'The object performs behavior using its state.'];
    }
    if (subject == 'ML') {
      if (c.contains('gradient descent')) return ['Start with current model parameters and loss.', 'Compute the gradient of the objective.', 'Update parameters in the negative-gradient direction.', 'Repeat updates while monitoring whether loss decreases.'];
      if (c.contains('k-means')) return ['Choose initial cluster centroids.', 'Assign each data point to its nearest centroid.', 'Recompute centroids from assigned points.', 'Repeat assignment and update until stable.'];
      if (c.contains('decision tree') || c.contains('random forest')) return ['Inspect training examples and candidate features.', 'Choose a feature split that improves the criterion.', 'Follow branches or combine tree predictions.', 'Produce the model prediction.'];
      if (c.contains('cross-validation')) return ['Split data into multiple folds.', 'Train on all but one fold.', 'Validate on the held-out fold and record the metric.', 'Aggregate scores across folds.'];
      if (c.contains('precision') || c.contains('recall') || c.contains('f1') || c.contains('confusion matrix')) return ['Compare predictions with actual labels.', 'Count true positives, false positives, and false negatives.', 'Calculate the selected evaluation metric.', 'Interpret the metric in the problem context.'];
      if (c.contains('linear regression') || c.contains('logistic regression')) return ['Prepare features and labelled examples.', 'The model computes a score from its parameters.', 'The score becomes a value or class probability.', 'Evaluate predictions and update model parameters during training.'];
      return ['Prepare the dataset and relevant features.', 'The learning algorithm fits model parameters.', 'The trained model processes an input example.', 'The model returns a prediction or evaluation result.'];
    }
    return ['Introduce the concept and its inputs.', 'Show the key operation or rule.', 'Apply the operation to an example.', 'Review the resulting behavior.'];
  }

  static String _levelQuestion(String concept, int variant) {
    switch (variant) {
      case 1: return 'Which statement best describes $concept?';
      case 2: return 'Which explanation of $concept is correct?';
      case 3: return 'How should $concept be applied in a placement problem?';
      case 4: return 'Which statement about $concept is accurate?';
      default: return 'An interviewer asks about $concept. Which answer is correct?';
    }
  }
}

class _QuestionSpec {
  final String name, correct, wrong1, wrong2, wrong3;
  const _QuestionSpec(this.name, this.correct, this.wrong1, this.wrong2, this.wrong3);
}
