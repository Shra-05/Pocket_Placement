
import 'package:flutter/material.dart';
import 'theme_selection_screen.dart';
import 'level_quiz_screen.dart';

/// Separate learning interface for the remaining Core subjects.
/// OS uses CoreQuestionScreen.
/// DSA/OOPS keep their existing LevelDetailScreen.
/// DBMS/CN/ML use this screen.
class CoreSubjectDetailScreen extends StatefulWidget {
  final int level;
  final String title;
  final String subtitle;
  final String topic;
  final Color accentColor;
  final AppTheme theme;

  const CoreSubjectDetailScreen({
    super.key,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.topic,
    required this.accentColor,
    required this.theme,
  });

  @override
  State<CoreSubjectDetailScreen> createState() =>
      _CoreSubjectDetailScreenState();
}

class _CoreSubjectDetailScreenState extends State<CoreSubjectDetailScreen> {
  late final CoreSubjectContent content;

  @override
  void initState() {
    super.initState();
    content = CoreSubjectContent.forSubject(
      widget.topic,
      widget.level,
      widget.title,
      widget.subtitle,
    );
  }

  Color get backgroundColor {
    switch (widget.theme) {
      case AppTheme.forest:
        return const Color(0xFF06130F);
      case AppTheme.cyberpunk:
        return const Color(0xFF09051A);
      case AppTheme.kingdom:
        return const Color(0xFF170D05);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${widget.topic.toUpperCase()} • LEVEL ${widget.level}',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 900;

            final learning = SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 14),
                  _missionBrief(),
                  const SizedBox(height: 14),
                  _conceptMap(),
                  const SizedBox(height: 14),
                  _keyIdeas(),
                  const SizedBox(height: 14),
                  _quickHints(),
                ],
              ),
            );

            final action = SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(desktop ? 0 : 18, 8, 18, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _knowledgePanel(),
                  const SizedBox(height: 14),
                  _keywords(),
                  const SizedBox(height: 14),
                  _complexity(),
                  const SizedBox(height: 20),
                  _assessmentButton(),
                ],
              ),
            );

            if (desktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: learning),
                  const SizedBox(width: 8),
                  Expanded(child: action),
                ],
              );
            }

            return learning;
          },
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.18),
        ),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String icon, String title) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: widget.accentColor,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.accentColor.withValues(alpha: 0.6)),
        gradient: LinearGradient(
          colors: [
            widget.accentColor.withValues(alpha: 0.16),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.topic.toUpperCase()} • LEVEL ${widget.level}',
            style: TextStyle(
              color: widget.accentColor,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content.subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _missionBrief() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('🎯', 'MISSION BRIEF'),
          const SizedBox(height: 16),
          Text(
            content.challenge,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: widget.accentColor.withValues(alpha: 0.05),
              border: Border.all(
                color: widget.accentColor.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXAMPLE',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Input: ${content.exampleInput}',
                  style: const TextStyle(color: Colors.white, height: 1.4),
                ),
                const SizedBox(height: 5),
                Text(
                  'Output: ${content.exampleOutput}',
                  style: const TextStyle(color: Colors.white, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _conceptMap() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('🧩', 'CONCEPT MAP'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: content.concepts
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: widget.accentColor.withValues(alpha: 0.45),
                      ),
                      color: widget.accentColor.withValues(alpha: 0.06),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        color: widget.accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _keyIdeas() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('💡', 'KEY IDEAS'),
          const SizedBox(height: 12),
          ...List.generate(
            content.keyIdeas.length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accentColor.withValues(alpha: 0.14),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: widget.accentColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      content.keyIdeas[index],
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickHints() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('🧠', 'QUICK HINTS'),
          const SizedBox(height: 12),
          ...content.hints.map(
            (hint) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_right_rounded,
                      color: widget.accentColor, size: 22),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      hint,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _knowledgePanel() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('⚡', 'KNOWLEDGE CHECK'),
          const SizedBox(height: 14),
          Text(
            'Before starting the assessment, make sure you can explain the core idea in your own words.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: widget.accentColor.withValues(alpha: 0.05),
            ),
            child: Text(
              content.checkpoint,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _keywords() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('🔑', 'KEYWORDS'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: content.keywords
                .map(
                  (keyword) => Material(
                    color: Colors.transparent,
                    child: ActionChip(
                      label: Text(keyword),
                      onPressed: () {},
                      backgroundColor:
                          widget.accentColor.withValues(alpha: 0.06),
                      side: BorderSide(
                        color: widget.accentColor.withValues(alpha: 0.45),
                      ),
                      labelStyle: TextStyle(
                        color: widget.accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _complexity() {
    return _card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _metric('Time', content.timeComplexity),
          _metric('Space', content.spaceComplexity),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment:
          label == 'Time' ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: widget.accentColor,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _assessmentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.accentColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LevelQuizScreen(
                level: widget.level,
                accentColor: widget.accentColor,
                theme: widget.theme,
              ),
            ),
          );
        },
        icon: const Icon(Icons.quiz_rounded),
        label: const Text(
          'START 5 QUESTION ASSESSMENT',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class CoreSubjectContent {
  final String title;
  final String subtitle;
  final String challenge;
  final String exampleInput;
  final String exampleOutput;
  final List<String> keyIdeas;
  final List<String> concepts;
  final List<String> hints;
  final List<String> keywords;
  final String checkpoint;
  final String timeComplexity;
  final String spaceComplexity;

  const CoreSubjectContent({
    required this.title,
    required this.subtitle,
    required this.challenge,
    required this.exampleInput,
    required this.exampleOutput,
    required this.keyIdeas,
    required this.concepts,
    required this.hints,
    required this.keywords,
    required this.checkpoint,
    required this.timeComplexity,
    required this.spaceComplexity,
  });

  static CoreSubjectContent forSubject(
    String topic,
    int level,
    String title,
    String subtitle,
  ) {
    final key = topic.trim().toUpperCase();

    if (key == 'DBMS') {
      return _dbms(level, title, subtitle);
    }
    if (key == 'CN' || key == 'COMPUTER NETWORKS') {
      return _cn(level, title, subtitle);
    }
    if (key == 'ML' || key == 'MACHINE LEARNING') {
      return _ml(level, title, subtitle);
    }

    return CoreSubjectContent(
      title: title,
      subtitle: subtitle,
      challenge: 'Understand the core concepts of $title.',
      exampleInput: 'Core concept',
      exampleOutput: 'Correct understanding',
      keyIdeas: const [
        'Identify the main concept.',
        'Understand how its components work together.',
        'Apply the concept to a simple example.',
        'Use the correct terminology.',
      ],
      concepts: [title],
      hints: const [
        'Start with the definition.',
        'Identify the important components.',
        'Connect the concept to a practical example.',
      ],
      keywords: [title],
      checkpoint: 'Explain the concept and one practical use case.',
      timeComplexity: 'Depends',
      spaceComplexity: 'Depends',
    );
  }

  static CoreSubjectContent _dbms(
      int level, String title, String subtitle) {
    const data = [
      (
        'DATABASE FOUNDATIONS',
        'Understand data, databases and DBMS.',
        'Learn why databases are used to store and manage structured information.',
        'Student records stored in a database',
        'Data can be stored, queried and updated',
        ['A database stores organized information.', 'A DBMS provides tools to manage data.', 'Queries retrieve required information.', 'Database systems improve controlled data access.'],
        ['Database', 'DBMS', 'Data', 'Query'],
        ['Think about how student records are stored.', 'Separate data from the software managing it.', 'Remember that queries operate on stored data.'],
        ['Database', 'DBMS', 'Query', 'Data'],
        'Explain the difference between a database and a DBMS.',
        'Depends on operation',
        'Depends on operation',
      ),
      (
        'ER MODEL',
        'Model entities and relationships.',
        'Represent real-world objects and the relationships between them before creating tables.',
        'Student — enrolls in — Course',
        'Entities and relationships are represented clearly',
        ['Entities represent real-world objects.', 'Attributes describe entities.', 'Relationships connect entities.', 'ER models help design databases before implementation.'],
        ['Entity', 'Attribute', 'Relationship', 'ER Diagram'],
        ['Identify objects first.', 'List their important attributes.', 'Then identify how the objects are related.'],
        ['Entity', 'Attribute', 'Relationship', 'Cardinality'],
        'Identify the entities, attributes and relationship in a simple scenario.',
        'Depends',
        'Depends',
      ),
      (
        'RELATIONAL MODEL',
        'Work with tables, keys and constraints.',
        'Understand how relational databases represent data using tables and relationships.',
        'Student(id, name, course_id)',
        'Rows and columns represent structured records',
        ['Tables contain rows and columns.', 'Keys identify records.', 'Constraints protect data integrity.', 'Relationships can connect tables.'],
        ['Table', 'Primary Key', 'Foreign Key', 'Constraint'],
        ['Find the unique identifier.', 'Check how one table references another.', 'Use constraints to protect valid data.'],
        ['Table', 'Primary Key', 'Foreign Key', 'Constraint'],
        'Explain why a primary key is needed.',
        'Depends',
        'Depends',
      ),
      (
        'SQL',
        'Retrieve and manipulate relational data.',
        'Use SQL concepts to select, filter, combine and modify data.',
        'SELECT name FROM Student WHERE marks >= 80',
        'Students satisfying the condition',
        ['SELECT retrieves data.', 'WHERE filters rows.', 'JOIN combines related tables.', 'INSERT, UPDATE and DELETE modify data.'],
        ['SELECT', 'WHERE', 'JOIN', 'Query'],
        ['Read the query from left to right.', 'Identify the table being used.', 'Then identify the required filter or relationship.'],
        ['SELECT', 'WHERE', 'JOIN', 'SQL'],
        'Explain what part of SQL filters rows.',
        'Depends on query',
        'Depends on query',
      ),
      (
        'NORMALIZATION',
        'Reduce redundancy and improve data integrity.',
        'Organize relational tables to reduce unnecessary repetition and update anomalies.',
        'StudentCourse(student, course, instructor)',
        'Decomposed related tables',
        ['Normalization reduces redundancy.', 'Functional dependencies guide decomposition.', 'Normal forms provide design rules.', 'Good design reduces anomalies.'],
        ['1NF', '2NF', '3NF', 'BCNF'],
        ['Look for repeated data.', 'Find dependencies between attributes.', 'Split tables when necessary.'],
        ['1NF', '2NF', '3NF', 'BCNF'],
        'Identify the type of redundancy a normalized design tries to reduce.',
        'Depends',
        'Depends',
      ),
      (
        'TRANSACTIONS',
        'Understand reliable database operations.',
        'Learn how database transactions keep operations consistent and reliable.',
        'Transfer ₹500 from A to B',
        'Either the complete transfer occurs or it does not',
        ['A transaction is a logical unit of work.', 'ACID properties support reliability.', 'Commit makes changes permanent.', 'Rollback cancels incomplete work.'],
        ['Transaction', 'ACID', 'Commit', 'Rollback'],
        ['Think of multiple database operations as one unit.', 'Ask what should happen if one operation fails.', 'Remember commit and rollback.'],
        ['ACID', 'Commit', 'Rollback', 'Transaction'],
        'Explain why rollback is useful.',
        'Depends',
        'Depends',
      ),
      (
        'CONCURRENCY',
        'Manage simultaneous database operations.',
        'Understand how multiple transactions can safely execute at the same time.',
        'Two users update the same record',
        'Controlled and consistent result',
        ['Concurrent operations can conflict.', 'Locks can control access.', 'Serializability preserves correctness.', 'Isolation reduces interference.'],
        ['Lock', 'Concurrency', 'Serializability', 'Isolation'],
        ['Find the shared data item.', 'Identify the possible conflict.', 'Then choose a control mechanism.'],
        ['Lock', 'Concurrency', 'Isolation', 'Serializability'],
        'Explain why concurrent transactions need control.',
        'Depends',
        'Depends',
      ),
      (
        'INDEXING',
        'Speed up database searches.',
        'Understand how indexes improve lookup performance without scanning every row.',
        'Search Student by id',
        'Faster lookup using an index',
        ['An index provides a faster access path.', 'Indexes use additional storage.', 'B-tree indexes support ordered access.', 'Indexes can speed reads but add maintenance cost.'],
        ['Index', 'B-Tree', 'Hashing', 'Lookup'],
        ['Compare an indexed search with scanning every row.', 'Remember the storage trade-off.', 'Choose an index based on the query pattern.'],
        ['Index', 'B-Tree', 'Hash', 'Lookup'],
        'Explain why an index can make a search faster.',
        'Typically O(log n)',
        'O(n) index space',
      ),
      (
        'RECOVERY',
        'Restore a database after failure.',
        'Understand how logs and recovery techniques protect committed database work.',
        'System crash during a transaction',
        'Database returns to a consistent state',
        ['Failures can interrupt transactions.', 'Logs record important changes.', 'Recovery restores consistency.', 'Committed work should be preserved.'],
        ['Recovery', 'Log', 'Failure', 'Checkpoint'],
        ['Identify what was committed.', 'Identify incomplete work.', 'Use the recovery record to restore consistency.'],
        ['Log', 'Recovery', 'Checkpoint', 'Failure'],
        'Explain why database logs are important during recovery.',
        'Depends',
        'Depends',
      ),
      (
        'DBMS MASTER',
        'Combine database concepts into one challenge.',
        'Apply database design, SQL, transactions and performance concepts together.',
        'Design a small college database',
        'Consistent, queryable and efficient database',
        ['Choose a suitable model.', 'Design tables and keys.', 'Use SQL correctly.', 'Consider transactions and performance.'],
        ['Design', 'SQL', 'Transactions', 'Performance'],
        ['Start with requirements.', 'Design the data model.', 'Then consider queries and reliability.'],
        ['DBMS', 'SQL', 'Design', 'ACID'],
        'Explain how multiple DBMS concepts work together in one system.',
        'Depends',
        'Depends',
      ),
    ];
    final d = data[((level - 1).clamp(0, data.length - 1)).toInt()];
    return CoreSubjectContent(
      title: d.$1, subtitle: d.$2, challenge: d.$3,
      exampleInput: d.$4, exampleOutput: d.$5, keyIdeas: d.$6,
      concepts: d.$7, hints: d.$8, keywords: d.$9, checkpoint: d.$10,
      timeComplexity: d.$11, spaceComplexity: d.$12,
    );
  }

  static CoreSubjectContent _cn(
      int level, String title, String subtitle) {
    const data = [
      ('NETWORKING BASICS','Understand how devices communicate.','Learn how connected devices exchange data using communication rules and protocols.','Client → Network → Server','Data delivered between connected devices',['A network connects devices.','Data is transmitted between endpoints.','Protocols define communication rules.','The receiver interprets data using the same rules.'],['Network','Protocol','Packet','Client / Server'],['Identify the sender and receiver.','Think about the path data takes.','Remember that protocols define the rules.'],['Network','Protocol','Packet','Client / Server'],'Explain why devices need communication protocols.','Depends','Depends'),
      ('OSI MODEL','Understand the seven layers of networking.','Use the OSI model to organize networking responsibilities into layers.','Application → Presentation → Session → Transport → Network → Data Link → Physical','Seven layers with separate responsibilities',['Each layer has a defined responsibility.','Layers communicate with adjacent layers.','The model helps troubleshoot networks.','Data moves through multiple layers.'],['OSI','Layers','Encapsulation','Protocol'],['Start at the application and physical ends.','Match a networking task to its layer.','Think about what each layer is responsible for.'],['OSI','Layer','Encapsulation','Protocol'],'Identify the layer responsible for logical addressing.','Depends','Depends'),
      ('TCP/IP','Understand the Internet protocol suite.','Learn how TCP, UDP and IP cooperate to deliver data across networks.','Application data → TCP/UDP → IP','Data is addressed and transported across networks',['IP handles addressing and routing.','TCP provides reliable delivery.','UDP is lightweight and connectionless.','Protocols work together in a stack.'],['TCP','UDP','IP','Port'],['Separate addressing from transport.','Compare TCP and UDP behavior.','Remember that ports identify application endpoints.'],['TCP','UDP','IP','Port'],'Explain one difference between TCP and UDP.','Depends','Depends'),
      ('DATA LINK LAYER','Understand local network delivery.','Learn how frames and MAC addresses support communication on a local network.','Frame → Switch → Destination','Frame delivered on the local link',['Frames carry local network data.','MAC addresses identify network interfaces.','Switches forward frames.','Error detection can occur at this layer.'],['Frame','MAC','Switch','Ethernet'],['Think about local delivery first.','Differentiate MAC from IP addressing.','Remember that switches operate using local addresses.'],['Frame','MAC','Switch','Ethernet'],'Explain the role of a MAC address.','Depends','Depends'),
      ('ROUTING','Find paths between networks.','Understand how routers choose paths for packets to reach different networks.','Source → Router → Router → Destination','Packet reaches the destination network',['Routers connect networks.','Routing tables contain path information.','Algorithms can choose efficient routes.','Packets may cross multiple routers.'],['Router','Routing Table','Path','Packet'],['Identify source and destination networks.','Check the routing table.','Think about the next hop.'],['Router','Route','Next Hop','Packet'],'Explain what a router does with a packet.','Depends','Depends'),
      ('TRANSPORT LAYER','Deliver data between applications.','Understand transport services such as reliability, ports and flow control.','Application A → Transport → Application B','Data delivered to the correct application',['Ports identify application endpoints.','TCP supports reliable delivery.','Flow control manages transmission rate.','Transport sits above IP.'],['Port','TCP','UDP','Flow Control'],['Separate host addressing from application addressing.','Think about reliability requirements.','Use ports to identify applications.'],['Port','TCP','UDP','Flow Control'],'Why are port numbers needed?','Depends','Depends'),
      ('APPLICATION LAYER','Understand network services used by applications.','Learn how application protocols support common Internet services.','Browser → HTTP → Web Server','Web response returned to browser',['HTTP supports web communication.','DNS maps names to addresses.','FTP supports file transfer.','Applications use protocols to communicate.'],['HTTP','DNS','FTP','Application'],['Identify the application service.','Match the service to its protocol.','Think about what the client is requesting.'],['HTTP','DNS','FTP','Web'],'Match DNS with its main purpose.','Depends','Depends'),
      ('NETWORK SECURITY','Protect data and communication.','Understand basic techniques used to protect networks and transmitted information.','Client → Secure Channel → Server','Protected communication',['Encryption protects confidentiality.','Authentication verifies identity.','Firewalls control network traffic.','Security uses multiple layers of protection.'],['Encryption','Authentication','Firewall','Security'],['Ask what needs protection.','Separate identity verification from encryption.','Think about controlling unwanted traffic.'],['Encryption','Authentication','Firewall','Security'],'Explain what encryption protects.','Depends','Depends'),
      ('WIRELESS NETWORKS','Understand wireless communication.','Learn how devices communicate without physical cables using wireless technologies.','Phone → Wi-Fi Access Point → Internet','Wireless data transmission',['Wi-Fi uses radio communication.','Access points connect wireless devices.','Signal quality affects communication.','Wireless networks need security controls.'],['Wi-Fi','Access Point','Signal','Wireless'],['Identify the access point.','Think about radio-based communication.','Consider signal and security.'],['Wi-Fi','Access Point','Signal','Wireless'],'What role does an access point play?','Depends','Depends'),
      ('CN MASTER','Combine networking concepts.','Apply layers, protocols, routing and security concepts to a complete network scenario.','Client → LAN → Router → Internet → Server','Successful and secure communication',['Choose the correct layer.','Identify the protocol involved.','Follow the packet path.','Consider reliability and security.'],['Layers','Protocols','Routing','Security'],['Start with the communication goal.','Trace the packet path.','Identify the responsible protocol or layer.'],['OSI','TCP/IP','Routing','Security'],'Explain a complete client-to-server communication path.','Depends','Depends'),
    ];
    final d = data[((level - 1).clamp(0, data.length - 1)).toInt()];
    return CoreSubjectContent(title:d.$1,subtitle:d.$2,challenge:d.$3,exampleInput:d.$4,exampleOutput:d.$5,keyIdeas:d.$6,concepts:d.$7,hints:d.$8,keywords:d.$9,checkpoint:d.$10,timeComplexity:d.$11,spaceComplexity:d.$12);
  }

  static CoreSubjectContent _ml(
      int level, String title, String subtitle) {
    const data = [
      ('ML BASICS','Understand data, features and models.','Learn the basic workflow of machine learning from data to prediction.','Features → Model → Prediction','Model produces a prediction',['Data provides examples.','Features describe observations.','A model learns patterns.','Predictions are produced from learned patterns.'],['Data','Feature','Model','Prediction'],['Identify the input features.','Separate training from prediction.','Think about what pattern the model learns.'],['Data','Feature','Model','Prediction'],'Explain the difference between a feature and a prediction.','Depends','Depends'),
      ('LINEAR REGRESSION','Predict continuous values.','Learn how a regression model estimates a numeric output from input features.','Hours studied → Exam score','Predicted score',['Regression predicts continuous values.','The model learns relationships in training data.','Features influence the prediction.','Error measures help evaluate predictions.'],['Regression','Feature','Target','Prediction'],['Identify the numeric target.','Think about the relationship between feature and target.','Compare predicted and actual values.'],['Regression','Feature','Target','Error'],'What type of output does regression predict?','Depends','Depends'),
      ('LOGISTIC REGRESSION','Perform binary classification.','Use logistic regression to estimate the probability of a class.','Features → Probability → Class','Pass / Fail classification',['Classification predicts categories.','The model can produce probabilities.','A threshold converts probability to a class.','Training learns model parameters.'],['Classification','Probability','Threshold','Class'],['Identify the classes.','Think about probability first.','Then apply a threshold.'],['Classification','Probability','Threshold','Logistic'],'Why is a threshold used in binary classification?','Depends','Depends'),
      ('DECISION TREES','Classify using decision rules.','Understand how a tree splits data into smaller groups using feature-based decisions.','Age > 18? → Branch','Predicted class',['Nodes contain decisions.','Branches represent outcomes.','Leaves contain predictions.','Splits aim to separate examples effectively.'],['Node','Split','Branch','Leaf'],['Start at the root.','Follow the condition matching the sample.','The leaf gives the prediction.'],['Tree','Split','Branch','Leaf'],'What does a leaf represent in a decision tree?','Depends','Depends'),
      ('KNN','Classify using nearby examples.','Understand how K-nearest neighbors uses the closest training examples to make predictions.','New point → nearest K points','Predicted class',['K controls the number of neighbors.','Distance determines closeness.','Classification can use majority voting.','Scaling can affect distance.'],['K','Distance','Neighbor','Voting'],['Find the nearest points.','Count their classes.','Use the majority for classification.'],['KNN','Distance','Neighbor','Majority'],'Why does the value of K matter?','O(n) per simple query','O(n)'),
      ('CLUSTERING','Group similar observations.','Understand unsupervised learning by grouping examples without predefined labels.','Data points → clusters','Groups of similar points',['Clustering does not require class labels.','K-Means assigns points to clusters.','Centroids represent cluster centers.','Similarity depends on the chosen distance measure.'],['Cluster','Centroid','K-Means','Distance'],['Look for similarity between points.','Assign points to a cluster.','Update the cluster center.'],['Cluster','Centroid','K-Means','Distance'],'What makes two points belong to the same cluster?','Depends','Depends'),
      ('MODEL EVALUATION','Measure model performance.','Learn how evaluation metrics describe how well a model performs on unseen data.','Actual vs Predicted','Performance metrics',['Accuracy measures overall correct predictions.','Precision focuses on predicted positives.','Recall focuses on detected positives.','Evaluation should use appropriate data.'],['Accuracy','Precision','Recall','Metric'],['Start with actual and predicted values.','Count correct and incorrect outcomes.','Choose the metric matching the goal.'],['Accuracy','Precision','Recall','F1'],'When is recall especially important?','O(n)','O(1)'),
      ('FEATURE ENGINEERING','Prepare useful model inputs.','Transform and select input features so models can learn useful patterns.','Raw data → Clean features','Model-ready features',['Features should contain useful information.','Categorical data may need encoding.','Scaling can help distance-based models.','Irrelevant features can add noise.'],['Feature','Encoding','Scaling','Preprocessing'],['Inspect the raw feature.','Choose an appropriate transformation.','Avoid leaking target information.'],['Feature','Encoding','Scaling','Preprocessing'],'Why might a categorical feature need encoding?','Depends','Depends'),
      ('ENSEMBLE MODELS','Combine multiple models.','Understand how ensembles combine several learners to improve predictive performance.','Multiple learners → Ensemble','Combined prediction',['Ensembles combine multiple models.','Random forests combine decision trees.','Boosting builds models sequentially.','Combining models can improve robustness.'],['Ensemble','Random Forest','Boosting','Tree'],['Think about why several models can outperform one.','Compare parallel and sequential learning.','Consider bias and variance.'],['Ensemble','Random Forest','Boosting','Variance'],'What is the main idea behind an ensemble?','Depends','Depends'),
      ('ML MASTER','Combine the complete ML workflow.','Apply data preparation, model selection, training and evaluation to a complete problem.','Dataset → Features → Model → Evaluation','Validated prediction system',['Start with a clear target.','Prepare features carefully.','Train an appropriate model.','Evaluate on suitable data.'],['Dataset','Features','Model','Evaluation'],['Define the problem first.','Prepare the data.', 'Choose and train the model.', 'Evaluate before trusting predictions.'],['Dataset','Feature','Training','Evaluation'],'Explain the major stages of an ML workflow.','Depends','Depends'),
    ];
    final d = data[((level - 1).clamp(0, data.length - 1)).toInt()];
    return CoreSubjectContent(title:d.$1,subtitle:d.$2,challenge:d.$3,exampleInput:d.$4,exampleOutput:d.$5,keyIdeas:d.$6,concepts:d.$7,hints:d.$8,keywords:d.$9,checkpoint:d.$10,timeComplexity:d.$11,spaceComplexity:d.$12);
  }
}
