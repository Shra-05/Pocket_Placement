import 'package:flutter/material.dart';
import 'theme_selection_screen.dart';
import 'core_subject_level_screen.dart';

class CNCoreLevelScreen extends StatelessWidget {
  final int level;
  final String title;
  final String subtitle;
  final String topic;
  final Color accentColor;
  final AppTheme theme;

  const CNCoreLevelScreen({
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
      subject: 'CN',
      title: title.isEmpty ? data.$1 : title,
      subtitle: subtitle.isEmpty ? data.$2 : subtitle,
      accentColor: accentColor,
      questions: data.$3,
      nextTitle: level < _levels.length ? 'Level ${level + 1}' : 'Complete',
    );
  }

  static const List<(String, String, List<CoreLearningQuestion>)> _levels = <(String, String, List<CoreLearningQuestion>)>[
    ("NETWORKING BASICS", "OSI • Data Representation", [ CoreLearningQuestion(
      title: "OSI Presentation Layer", concept: "OSI Presentation Layer", type: 'mcq',
      question: "At which OSI layer do encryption, decryption, compression, and data representation conversion take place?", options: ["Application Layer (7)", "Presentation Layer (6)", "Session Layer (5)", "Transport Layer (4)"], correctOption: 1,
      explanation: "The Presentation layer acts as a data translator and handles representation, compression, and traditionally mapped encryption responsibilities.", animationTitle: "OSI Presentation Layer",
      animationSteps: ["Application", "Presentation", "Translation", "Data Ready"],
    )]),
    ("TCP VS UDP", "Transport • Reliability", [ CoreLearningQuestion(
      title: "TCP Header", concept: "TCP Header", type: 'mcq',
      question: "Which field is present in the TCP header but not in the UDP header?", options: ["Source Port", "Destination Port", "Sequence Number", "Checksum"], correctOption: 2,
      explanation: "TCP uses sequence numbers for ordered, reliable delivery. UDP has a minimal header without a sequence number.", animationTitle: "TCP Header",
      animationSteps: ["TCP", "Sequence Number", "Ordered Bytes", "UDP"],
    )]),
    ("IP ADDRESSING", "Subnetting • CIDR", [ CoreLearningQuestion(
      title: "Subnet for 28 Hosts", concept: "Subnet for 28 Hosts", type: 'mcq',
      question: "For a subnet starting at 192.168.1.0 that requires 28 usable host addresses with minimal waste, which block is appropriate?", options: ["192.168.1.0/27", "192.168.1.0/28", "192.168.1.0/29", "192.168.1.0/26"], correctOption: 0,
      explanation: "/27 provides 32 total addresses, with 30 usable host addresses after reserving the network and broadcast addresses.", animationTitle: "Subnet for 28 Hosts",
      animationSteps: ["Requirement: 28", "/28 Too Small", "/27 = 30 Usable", "Minimal Waste"],
    )]),
    ("ARP", "LAN • MAC Address", [ CoreLearningQuestion(
      title: "Address Resolution Protocol", concept: "Address Resolution Protocol", type: 'mcq',
      question: "What is the primary purpose of ARP in a LAN?", options: ["Dynamically allocate IP addresses.", "Translate domain names to IP addresses.", "Map a known IP address to a Layer 2 MAC address.", "Select optimal inter-network routes."], correctOption: 2,
      explanation: "ARP resolves a known Layer 3 IP address to the corresponding physical Layer 2 MAC address on the local network.", animationTitle: "Address Resolution Protocol",
      animationSteps: ["IP Address", "ARP Request", "MAC Address", "Frame"],
    )]),
    ("TLS HANDSHAKE", "Public Key • Session Key", [ CoreLearningQuestion(
      title: "TLS 1.2 Session Key", concept: "TLS 1.2 Session Key", type: 'mcq',
      question: "In the TLS 1.2 handshake described in the source, when is the symmetric session key derived?", options: ["During ClientHello using pre-shared passwords.", "After certificate verification and exchange of the encrypted Pre-Master Secret, after which both sides independently derive the session key.", "The server encrypts it with its private key and sends it.", "The CA generates and delivers it."], correctOption: 1,
      explanation: "TLS uses asymmetric cryptography to establish a shared secret, then both sides derive the symmetric session key for efficient data transfer.", animationTitle: "TLS 1.2 Session Key",
      animationSteps: ["Certificate", "Pre-Master Secret", "Key Derivation", "Session Key"],
    )]),
    ("DNS RESOLUTION", "Hostname • IP Lookup", [ CoreLearningQuestion(
      title: "Hostname Diagnostic", concept: "Hostname Diagnostic", type: 'code',
      question: "Fill the blanks to resolve a domain and inspect the local hostname/IP.", code: "import socket\n\nip_addresses = socket.____(\"example.com\")\nlocal_hostname = socket.____()\nlocal_ip = socket.____(local_hostname)\n", answers: ["gethostbyname_ex", "gethostname", "gethostbyname"],
      explanation: "The source uses gethostbyname_ex for domain resolution, gethostname for the local machine name, and gethostbyname to resolve that hostname.", animationTitle: "Hostname Diagnostic",
      animationSteps: ["Domain", "DNS Lookup", "Hostname", "Local IP"],
    )]),
    ("TCP CLIENT-SERVER", "Socket • Bind • Listen", [ CoreLearningQuestion(
      title: "TCP Server Setup", concept: "TCP Server Setup", type: 'code',
      question: "Fill the blanks for the basic TCP server setup.", code: "import socket\n\nwith socket.socket(socket.AF_INET, socket.____) as server_socket:\n    server_socket.____((host, port))\n    server_socket.____(1)\n    conn, addr = server_socket.accept()\n", answers: ["SOCK_STREAM", "bind", "listen"],
      explanation: "The source creates an IPv4 stream socket, binds it to an address, and listens for incoming TCP connections.", animationTitle: "TCP Server Setup",
      animationSteps: ["Socket", "Bind", "Listen", "Accept"],
    )]),
    ("CONCURRENT SERVER", "Threads • Connections", [ CoreLearningQuestion(
      title: "Concurrent TCP Server", concept: "Concurrent TCP Server", type: 'code',
      question: "Fill the blanks to accept clients and handle each client in a new thread.", code: "conn, addr = server_socket.____()\n\nclient_thread = threading.____(\n    target=handle_client,\n    args=(conn, addr)\n)\nclient_thread.start()\n", answers: ["accept", "Thread"],
      explanation: "The concurrent server accepts a connection and creates a threading.Thread running handle_client for that client.", animationTitle: "Concurrent TCP Server",
      animationSteps: ["Server", "Accept Client", "New Thread", "Handle Client"],
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
