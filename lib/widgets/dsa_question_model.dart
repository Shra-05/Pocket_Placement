class DSAQuestion {
  final String topic;
  final String question;
  final String input;
  final String output;
  final String hint;
  final String code;
  final List<String> keywords;
  final List<String> correctAnswers;

  DSAQuestion({
    required this.topic,
    required this.question,
    required this.input,
    required this.output,
    required this.hint,
    required this.code,
    required this.keywords,
    required this.correctAnswers,
  });
}