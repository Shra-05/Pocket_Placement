import 'dsa_question_model.dart';

final List<DSAQuestion> dsaQuestions = [
  DSAQuestion(
    topic: "Arrays",

    question:
        "Given an array of integers, find the maximum element in the array.",

    input:
        "[3, 7, 2, 9, 4]",

    output:
        "9",

    hint:
        "Start with the first element as the maximum and compare every remaining element with it.",

    code: '''
int max = ________;

for (int i = 1; i < arr.length; i++) {

  if (arr[i] > ________) {
    max = arr[i];
  }
}

return ________;
''',

    keywords: [
      "arr[0]",
      "max",
      "i",
      "arr.length",
    ],

    correctAnswers: [
      "arr[0]",
      "max",
      "max",
    ],
  ),
];